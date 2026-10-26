import '../services/api/api_endpoints.dart';
import 'property_model.dart';
import 'user_model.dart';

String _normalizeUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return '';
  final trimmed = rawUrl.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  // Local file path from image picker
  if (trimmed.startsWith('/data/') ||
      trimmed.startsWith('/storage/') ||
      trimmed.startsWith('file://') ||
      trimmed.contains(r':\') ||
      trimmed.contains(r':/')) {
    return trimmed;
  }
  final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
      ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
      : ApiEndpoints.baseUrl;
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$baseUrl$path';
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final String time;
  final String price;
  final String imageUrl;
  final String organizerName;
  final String organizerAvatar;
  final String? organizerId;
  final int attendeesCount;
  final bool isInterested;
  final bool isFeatured;
  final String filterCategory;
  final List<String> whatToExpect;
  final DateTime? endDate;
  final String? endTime;
  final int? maxAttendees;
  final bool isOnline;

  static const List<String> defaultWhatToExpect = [
    'Delicious Dinner',
    'Kids Activities',
    'Cultural Programs',
    'Meet & Greet',
  ];

  static List<String> defaultWhatToExpectFor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('sport') || cat.contains('cricket') || cat.contains('football')) {
      return const [
        'Live Match & Tournament',
        'Refreshments & Snacks',
        'Team Meet & Greet',
        'Trophy & Awards',
      ];
    } else if (cat.contains('food') || cat.contains('dining')) {
      return const [
        'Authentic Desi Cuisine',
        'Live Food Stalls & Tasting',
        'Desserts & Chai Corner',
        'Family & Community Dining',
      ];
    } else if (cat.contains('music')) {
      return const [
        'Live Music Performances',
        'Acoustic & Classical Sets',
        'Meet the Artists',
        'Refreshments & Vibes',
      ];
    } else if (cat.contains('educat') || cat.contains('work')) {
      return const [
        'Keynote & Expert Sessions',
        'Interactive Q&A',
        'Networking Opportunities',
        'Resource & Study Materials',
      ];
    } else if (cat.contains('business')) {
      return const [
        'Professional Networking',
        'Business Pitch & Showcase',
        'Panel Discussions',
        'Partnership Opportunities',
      ];
    } else if (cat.contains('relig') || cat.contains('prayer')) {
      return const [
        'Spiritual Gathering & Prayer',
        'Community Discourse',
        'Community Feast & Refreshments',
        'Family & Children Welcome',
      ];
    } else if (cat.contains('fest') || cat.contains('celebrat') || cat.contains('eid') || cat.contains('diwali')) {
      return const [
        'Cultural Celebrations & Decor',
        'Traditional Food & Stalls',
        'Kids & Family Activities',
        'Photo Booth & Festive Fun',
      ];
    }
    return defaultWhatToExpect;
  }

  int get interestedCount => attendeesCount;

  bool get isFree {
    final clean = price.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    return clean.isEmpty || clean == '0' || price.toLowerCase().contains('free');
  }

  String get displayPrice {
    final clean = price.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    if (clean.isEmpty || clean == '0' || price.toLowerCase().contains('free')) {
      return 'Free Entry';
    }
    if (price.startsWith('€') || price.startsWith(r'$')) {
      return '$price / ticket';
    }
    return '€$clean / ticket';
  }

  String get displayTime {
    if (endTime != null && endTime!.isNotEmpty && endTime != time) {
      return '$time - $endTime';
    }
    return time;
  }

  String get month {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  String get day => date.day.toString().padLeft(2, '0');

  String get fullDate {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.price,
    required this.imageUrl,
    required this.organizerName,
    required this.organizerAvatar,
    this.organizerId,
    this.attendeesCount = 0,
    this.isInterested = false,
    this.isFeatured = false,
    String? filterCategory,
    List<String>? whatToExpect,
    this.endDate,
    this.endTime,
    this.maxAttendees,
    this.isOnline = false,
  })  : filterCategory = filterCategory ?? category,
        whatToExpect = (whatToExpect != null && whatToExpect.isNotEmpty)
            ? whatToExpect
            : defaultWhatToExpectFor(category);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // 1. Safe Date Parsing
    final dateRaw = json['date'] ?? json['startDate'] ?? json['eventDate'];
    final parsedDate = dateRaw != null
        ? DateTime.tryParse(dateRaw.toString()) ?? DateTime.now()
        : DateTime.now();

    final endDateRaw = json['endDate'];
    final parsedEndDate = endDateRaw != null
        ? DateTime.tryParse(endDateRaw.toString())
        : null;

    // 2. Safe Time Parsing
    final parsedTime = (json['time'] ?? json['startTime'] ?? json['start_time'])?.toString() ?? '18:00';
    final parsedEndTime = (json['endTime'] ?? json['end_time'])?.toString();

    // 3. Safe Price Parsing (handles int, double, String, null)
    final resolvedPrice = () {
      final raw = json['price'] ?? json['ticketPrice'];
      if (raw == null) return 'Free';
      final str = raw.toString().trim();
      if (str.isEmpty || str == '0' || str == '0.0' || str.toLowerCase() == 'free') {
        return 'Free';
      }
      if (str.startsWith('€') || str.startsWith(r'$')) {
        return str;
      }
      return '€$str';
    }();

    // 4. Safe Category Parsing
    final parsedCategory = (json['category'] ?? json['type'] ?? json['eventType'])?.toString() ?? 'General';

    // 5. Safe Image Resolution
    final resolvedImageUrl = () {
      final directKeys = [
        'imageUrl',
        'coverPhotoUrl',
        'bannerUrl',
        'photoUrl',
        'coverPhoto',
        'coverImage',
        'banner',
        'image',
        'photo',
        'url',
      ];
      for (final key in directKeys) {
        final val = json[key];
        if (val is String && val.trim().isNotEmpty) {
          return _normalizeUrl(val.trim());
        }
      }

      final mapKeys = ['coverPhoto', 'banner', 'image', 'photo', 'coverImage'];
      for (final key in mapKeys) {
        final val = json[key];
        if (val is Map) {
          final url = (val['url'] ?? val['path'] ?? val['link'])?.toString();
          if (url != null && url.trim().isNotEmpty) {
            return _normalizeUrl(url.trim());
          }
        }
      }

      final listKeys = ['photos', 'images', 'gallery', 'eventPhotos'];
      for (final key in listKeys) {
        final val = json[key];
        if (val is List && val.isNotEmpty) {
          final first = val.first;
          if (first is String && first.trim().isNotEmpty) {
            return _normalizeUrl(first.trim());
          } else if (first is Map) {
            final url = (first['url'] ?? first['path'] ?? first['link'])?.toString();
            if (url != null && url.trim().isNotEmpty) {
              return _normalizeUrl(url.trim());
            }
          }
        }
      }

      return 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=600';
    }();

    // 6. Safe Organizer Parsing
    String resolvedOrganizerName = 'Community Organizer';
    String resolvedOrganizerAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200';
    String? resolvedOrganizerId;

    final organizer = json['organizer'] ?? json['user'] ?? json['creator'];
    if (organizer is Map) {
      resolvedOrganizerId = organizer['id']?.toString() ?? organizer['_id']?.toString();
      final firstName = organizer['firstName']?.toString() ?? '';
      final lastName = organizer['lastName']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();
      final orgName = organizer['name']?.toString() ?? organizer['organizerName']?.toString();
      if (orgName != null && orgName.isNotEmpty) {
        resolvedOrganizerName = orgName;
      } else if (fullName.isNotEmpty) {
        resolvedOrganizerName = fullName;
      }
      final avatar = organizer['profilePhoto'] ?? organizer['avatar'] ?? organizer['photo'];
      if (avatar is String && avatar.isNotEmpty) {
        resolvedOrganizerAvatar = _normalizeUrl(avatar);
      } else if (avatar is Map && avatar['url'] is String) {
        resolvedOrganizerAvatar = _normalizeUrl(avatar['url']);
      }
    } else if (json['organizerName'] != null) {
      resolvedOrganizerName = json['organizerName'].toString();
    }

    if (resolvedOrganizerId == null || resolvedOrganizerId.isEmpty) {
      resolvedOrganizerId = json['organizerId']?.toString() ??
          json['userId']?.toString() ??
          json['creatorId']?.toString() ??
          json['authorId']?.toString();
    }

    if (json['organizerAvatar'] is String && (json['organizerAvatar'] as String).isNotEmpty) {
      resolvedOrganizerAvatar = _normalizeUrl(json['organizerAvatar'] as String);
    }

    // 7. Safe Attendees Count
    final count = int.tryParse(
          (json['attendeesCount'] ??
                  json['attendees'] ??
                  json['interestedCount'] ??
                  json['likesCount'])
              ?.toString() ??
              '0',
        ) ??
        0;

    // 8. Safe What To Expect
    List<String>? whatToExpect;
    if (json['whatToExpect'] is List) {
      whatToExpect = (json['whatToExpect'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return EventModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: parsedCategory,
      location: (json['location'] ?? json['venue'] ?? json['address'])?.toString() ?? 'Madrid, Spain',
      date: parsedDate,
      time: parsedTime,
      price: resolvedPrice,
      imageUrl: resolvedImageUrl,
      organizerName: resolvedOrganizerName,
      organizerAvatar: resolvedOrganizerAvatar,
      organizerId: resolvedOrganizerId,
      attendeesCount: count,
      isInterested: json['isInterested'] == true,
      isFeatured: json['isFeatured'] == true,
      filterCategory: json['filterCategory']?.toString(),
      whatToExpect: whatToExpect,
      endDate: parsedEndDate,
      endTime: parsedEndTime,
      maxAttendees: int.tryParse(json['maxAttendees']?.toString() ?? ''),
      isOnline: json['isOnline'] == true || json['location'] == 'Online',
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? date,
    String? time,
    String? price,
    String? imageUrl,
    String? organizerName,
    String? organizerAvatar,
    String? organizerId,
    int? attendeesCount,
    bool? isInterested,
    bool? isFeatured,
    String? filterCategory,
    List<String>? whatToExpect,
    DateTime? endDate,
    String? endTime,
    int? maxAttendees,
    bool? isOnline,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerName: organizerName ?? this.organizerName,
      organizerAvatar: organizerAvatar ?? this.organizerAvatar,
      organizerId: organizerId ?? this.organizerId,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      isInterested: isInterested ?? this.isInterested,
      isFeatured: isFeatured ?? this.isFeatured,
      filterCategory: filterCategory ?? this.filterCategory,
      whatToExpect: whatToExpect ?? this.whatToExpect,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'price': price,
      'imageUrl': imageUrl,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      if (organizerId != null) 'organizerId': organizerId,
      'attendeesCount': attendeesCount,
      'isInterested': isInterested,
      'isFeatured': isFeatured,
      'filterCategory': filterCategory,
      'whatToExpect': whatToExpect,
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (endTime != null) 'endTime': endTime,
      if (maxAttendees != null) 'maxAttendees': maxAttendees,
      'isOnline': isOnline,
    };
  }

  /// Resolves the organizer into a [PropertyOwner] for navigation to [PublicProfileView].
  PropertyOwner resolveOwner({UserModel? currentUser}) {
    final bool isUserMatch = currentUser != null &&
        ((organizerId != null &&
                organizerId!.isNotEmpty &&
                organizerId == currentUser.id) ||
            (organizerName.isNotEmpty &&
                (organizerName.toLowerCase() ==
                        currentUser.username.toLowerCase() ||
                    organizerName.toLowerCase() ==
                        currentUser.fullName.toLowerCase() ||
                    organizerName == 'Personal Event')));

    final resolvedId = (organizerId != null && organizerId!.isNotEmpty)
        ? organizerId!
        : (isUserMatch ? currentUser.id : '');

    final resolvedName = isUserMatch
        ? (currentUser.fullName.trim().isNotEmpty
            ? currentUser.fullName.trim()
            : (currentUser.username.trim().isNotEmpty
                ? currentUser.username.trim()
                : 'Event Host'))
        : (organizerName.trim().isNotEmpty
            ? organizerName.trim()
            : 'Event Host');

    final nameParts = resolvedName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : resolvedName;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    final resolvedAvatar = isUserMatch
        ? (currentUser.profilePhotoUrl ?? organizerAvatar)
        : organizerAvatar;

    return PropertyOwner(
      id: resolvedId,
      firstName: firstName,
      lastName: lastName,
      profilePhotoUrl: resolvedAvatar.isNotEmpty ? resolvedAvatar : null,
      createdAt: isUserMatch && currentUser.createdAt != null
          ? currentUser.createdAt!
          : date.toIso8601String(),
      phoneNumber: isUserMatch ? currentUser.phoneNumber : null,
      email: isUserMatch ? currentUser.email : null,
    );
  }
}

