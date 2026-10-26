import '../services/api/api_endpoints.dart';

/// Helper function to convert relative upload path to full URL
String _resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  final base = ApiEndpoints.baseUrl.endsWith('/')
      ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
      : ApiEndpoints.baseUrl;
  final relative = path.startsWith('/') ? path : '/$path';
  return '$base$relative';
}

/// Country banner model
class ExploreCountryBanner {
  final String id;
  final String url;

  ExploreCountryBanner({
    required this.id,
    required this.url,
  });

  /// Full absolute URL resolved against API base URL
  String get fullUrl => _resolveMediaUrl(url);

  factory ExploreCountryBanner.fromJson(Map<String, dynamic> json) =>
      ExploreCountryBanner(
        id: json['id'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
      };
}

/// City banner model (can be null for some cities)
class ExploreCountryCityBanner {
  final String id;
  final String url;

  ExploreCountryCityBanner({
    required this.id,
    required this.url,
  });

  /// Full absolute URL resolved against API base URL
  String get fullUrl => _resolveMediaUrl(url);

  factory ExploreCountryCityBanner.fromJson(Map<String, dynamic> json) =>
      ExploreCountryCityBanner(
        id: json['id'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
      };
}

/// Emergency number associated with a country
class ExploreCountryEmergencyNumber {
  final String id;
  final String title;
  final String number;

  ExploreCountryEmergencyNumber({
    required this.id,
    required this.title,
    required this.number,
  });

  factory ExploreCountryEmergencyNumber.fromJson(Map<String, dynamic> json) =>
      ExploreCountryEmergencyNumber(
        id: json['id'] as String? ?? '',
        title: (json['title'] as String? ?? '').trim(),
        number: (json['number'] as String? ?? '').trim(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'number': number,
      };
}

/// Popular city belonging to a country
class ExploreCountryPopularCity {
  final String id;
  final String name;
  final ExploreCountryCityBanner? banner;

  ExploreCountryPopularCity({
    required this.id,
    required this.name,
    this.banner,
  });

  /// Full banner URL if available
  String? get bannerUrl => banner?.fullUrl;

  factory ExploreCountryPopularCity.fromJson(Map<String, dynamic> json) =>
      ExploreCountryPopularCity(
        id: json['id'] as String? ?? '',
        name: (json['name'] as String? ?? '').trim(),
        banner: json['banner'] != null
            ? ExploreCountryCityBanner.fromJson(
                json['banner'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'banner': banner?.toJson(),
      };
}

/// Collection counts returned in the paginated list endpoint
class ExploreCountryCount {
  final int emergencyNumbers;
  final int popularCities;

  ExploreCountryCount({
    required this.emergencyNumbers,
    required this.popularCities,
  });

  factory ExploreCountryCount.fromJson(Map<String, dynamic> json) =>
      ExploreCountryCount(
        emergencyNumbers: json['emergencyNumbers'] as int? ?? 0,
        popularCities: json['popularCities'] as int? ?? 0,
      );

  factory ExploreCountryCount.empty() => ExploreCountryCount(
        emergencyNumbers: 0,
        popularCities: 0,
      );

  Map<String, dynamic> toJson() => {
        'emergencyNumbers': emergencyNumbers,
        'popularCities': popularCities,
      };
}

/// Main ExploreCountry model
class ExploreCountry {
  final String id;
  final String name;
  final String population;
  final String language;
  final String currency;
  final String capital;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ExploreCountryBanner? banner;
  final ExploreCountryCount? count;
  final List<ExploreCountryEmergencyNumber> emergencyNumbers;
  final List<ExploreCountryPopularCity> popularCities;

  ExploreCountry({
    required this.id,
    required this.name,
    required this.population,
    required this.language,
    required this.currency,
    required this.capital,
    required this.createdAt,
    required this.updatedAt,
    this.banner,
    this.count,
    this.emergencyNumbers = const [],
    this.popularCities = const [],
  });

  /// Full banner URL if available
  String? get bannerUrl => banner?.fullUrl;

  /// Effective count of emergency numbers
  int get emergencyCount =>
      emergencyNumbers.isNotEmpty ? emergencyNumbers.length : (count?.emergencyNumbers ?? 0);

  /// Effective count of popular cities
  int get citiesCount =>
      popularCities.isNotEmpty ? popularCities.length : (count?.popularCities ?? 0);

  /// Formatted population string with commas (e.g., "40,769,890")
  String get formattedPopulation {
    final cleaned = population.trim();
    if (cleaned.isEmpty) return 'N/A';
    final parsed = int.tryParse(cleaned);
    if (parsed == null) return cleaned;
    // Format with commas
    return cleaned.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  factory ExploreCountry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val)?.toLocal() ?? DateTime.now();
      }
      return DateTime.now();
    }

    final emergencyList = (json['emergencyNumbers'] as List<dynamic>? ?? [])
        .map((e) =>
            ExploreCountryEmergencyNumber.fromJson(e as Map<String, dynamic>))
        .toList();

    final citiesList = (json['popularCities'] as List<dynamic>? ?? [])
        .map((e) =>
            ExploreCountryPopularCity.fromJson(e as Map<String, dynamic>))
        .toList();

    final countObj = json['_count'] != null
        ? ExploreCountryCount.fromJson(json['_count'] as Map<String, dynamic>)
        : null;

    final bannerObj = json['banner'] != null
        ? ExploreCountryBanner.fromJson(json['banner'] as Map<String, dynamic>)
        : null;

    // Prisma converts BigInt to string, handle both String and num defensively
    final popRaw = json['population'];
    final popStr = popRaw != null ? popRaw.toString() : '';

    return ExploreCountry(
      id: json['id'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      population: popStr,
      language: (json['language'] as String? ?? '').trim(),
      currency: (json['currency'] as String? ?? '').trim(),
      capital: (json['capital'] as String? ?? '').trim(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      banner: bannerObj,
      count: countObj,
      emergencyNumbers: emergencyList,
      popularCities: citiesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'population': population,
        'language': language,
        'currency': currency,
        'capital': capital,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'banner': banner?.toJson(),
        if (count != null) '_count': count?.toJson(),
        if (emergencyNumbers.isNotEmpty)
          'emergencyNumbers': emergencyNumbers.map((e) => e.toJson()).toList(),
        if (popularCities.isNotEmpty)
          'popularCities': popularCities.map((e) => e.toJson()).toList(),
      };

  ExploreCountry copyWith({
    String? id,
    String? name,
    String? population,
    String? language,
    String? currency,
    String? capital,
    DateTime? createdAt,
    DateTime? updatedAt,
    ExploreCountryBanner? banner,
    ExploreCountryCount? count,
    List<ExploreCountryEmergencyNumber>? emergencyNumbers,
    List<ExploreCountryPopularCity>? popularCities,
  }) =>
      ExploreCountry(
        id: id ?? this.id,
        name: name ?? this.name,
        population: population ?? this.population,
        language: language ?? this.language,
        currency: currency ?? this.currency,
        capital: capital ?? this.capital,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        banner: banner ?? this.banner,
        count: count ?? this.count,
        emergencyNumbers: emergencyNumbers ?? this.emergencyNumbers,
        popularCities: popularCities ?? this.popularCities,
      );
}

/// Pagination metadata returned by GET /explore-country
class ExploreCountryPaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  ExploreCountryPaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  factory ExploreCountryPaginationMeta.fromJson(Map<String, dynamic> json) =>
      ExploreCountryPaginationMeta(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 10,
        totalPages: json['totalPages'] as int? ?? 0,
      );

  factory ExploreCountryPaginationMeta.empty() => ExploreCountryPaginationMeta(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      );

  Map<String, dynamic> toJson() => {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
      };
}

/// Response wrapper for GET /explore-country
class ExploreCountryListResponse {
  final List<ExploreCountry> data;
  final ExploreCountryPaginationMeta meta;

  ExploreCountryListResponse({
    required this.data,
    required this.meta,
  });

  factory ExploreCountryListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ExploreCountry.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] != null
        ? ExploreCountryPaginationMeta.fromJson(
            json['meta'] as Map<String, dynamic>)
        : ExploreCountryPaginationMeta.empty();
    return ExploreCountryListResponse(data: list, meta: meta);
  }
}
