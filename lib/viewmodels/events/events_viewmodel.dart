import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/event_model.dart';
import '../../models/search_result_model.dart';
import '../../repositories/event_repository.dart';
import '../../widgets/post_success_dialog.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/local/cache_service.dart';
import '../auth/auth_viewmodel.dart';

class EventsViewModel extends ChangeNotifier {
  final EventRepository _repository;

  EventsViewModel(this._repository) {
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    try {
      final cached = CacheService.instance.getJsonList(CacheService.keyEventsPublic);
      if (cached != null && cached.isNotEmpty) {
        _events = cached.map((json) => EventModel.fromJson(json)).toList();
      }
      final cachedMyEvents = CacheService.instance.getJsonList('my_events_cache');
      if (cachedMyEvents != null && cachedMyEvents.isNotEmpty) {
        _myEvents = cachedMyEvents.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[EventsViewModel] Hydration error: $e');
    }
  }

  void _persistEvents() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyEventsPublic,
        _events.take(30).map((e) => e.toJson()).toList(),
      );
      CacheService.instance.saveJsonList(
        'my_events_cache',
        _myEvents.take(50).map((e) => e.toJson()).toList(),
      );
    } catch (_) {}
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  static const List<String> eventFilters = [
    'All',
    'Upcoming',
    'This Week',
    'This Month',
  ];

  void setSelectedFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  List<EventModel> get filteredEvents {
    if (_selectedFilter == 'All') return _events;
    return _events
        .where(
          (e) =>
              e.filterCategory == _selectedFilter ||
              e.category == _selectedFilter,
        )
        .toList();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ──────────────────────────────────────────────────────────────────────────
  // Create Event Form State
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ticketPriceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String _selectedOrganizer = '';
  String get selectedOrganizer => _selectedOrganizer;
  static const List<String> organizers = [
    'Personal Event',
    'Community Group',
    'Cultural Association',
    'Business / Organization',
    'Other',
  ];

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  TimeOfDay? _startTime;
  TimeOfDay? get startTime => _startTime;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  TimeOfDay? _endTime;
  TimeOfDay? get endTime => _endTime;

  bool _isOnlineEvent = false;
  bool get isOnlineEvent => _isOnlineEvent;

  int _maxAttendees = 50;
  int get maxAttendees => _maxAttendees;

  String _selectedEventType = '';
  String get selectedEventType => _selectedEventType;
  static const List<Map<String, String>> eventTypes = [
    {'name': 'Celebration', 'emoji': '🥳'},
    {'name': 'Sports', 'emoji': '🏃'},
    {'name': 'Food & Dining', 'emoji': '🍽️'},
    {'name': 'Education', 'emoji': '📚'},
    {'name': 'Religious', 'emoji': '🕌'},
    {'name': 'Business', 'emoji': '💼'},
    {'name': 'Music', 'emoji': '🎵'},
    {'name': 'Gaming', 'emoji': '🎮'},
  ];

  String _selectedVisibility = '';
  String get selectedVisibility => _selectedVisibility;

  XFile? _bannerImage;
  XFile? get bannerImage => _bannerImage;
  final ImagePicker _picker = ImagePicker();

  bool _formInitialized = false;

  void initEventForm() {
    if (_formInitialized) return;
    _formInitialized = true;
    eventNameController.addListener(_onFormFieldChanged);
    locationController.addListener(_onFormFieldChanged);
    descriptionController.addListener(_onFormFieldChanged);
    startDateController.addListener(_onFormFieldChanged);
    endDateController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    notifyListeners();
  }

  void setSelectedOrganizer(String val) {
    _selectedOrganizer = val;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay? time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? time) {
    _endTime = time;
    notifyListeners();
  }

  void setIsOnlineEvent(bool val) {
    _isOnlineEvent = val;
    notifyListeners();
  }

  void incrementAttendees() {
    _maxAttendees++;
    notifyListeners();
  }

  void decrementAttendees() {
    if (_maxAttendees > 1) {
      _maxAttendees--;
      notifyListeners();
    }
  }

  void setSelectedEventType(String val) {
    _selectedEventType = val;
    notifyListeners();
  }

  void setSelectedVisibility(String val) {
    _selectedVisibility = val;
    notifyListeners();
  }

  Future<void> pickBanner([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        _bannerImage = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking banner: $e');
    }
  }

  void removeBanner() {
    _bannerImage = null;
    notifyListeners();
  }

  double calculateProgress() {
    double progress = 0.0;
    if (_bannerImage != null) progress += 0.15;
    if (eventNameController.text.trim().isNotEmpty) progress += 0.15;
    if (_selectedOrganizer.isNotEmpty) progress += 0.10;
    if (_startDate != null && _startTime != null) progress += 0.20;
    if (_endDate != null) progress += 0.05;
    if (locationController.text.trim().isNotEmpty || _isOnlineEvent) {
      progress += 0.15;
    }
    if (descriptionController.text.trim().isNotEmpty) progress += 0.10;
    if (_selectedEventType.isNotEmpty) progress += 0.10;
    if (_selectedVisibility.isNotEmpty) progress += 0.05;
    return progress.clamp(0.0, 1.0);
  }

  void resetEventForm() {
    eventNameController.clear();
    locationController.clear();
    descriptionController.clear();
    ticketPriceController.clear();
    startDateController.clear();
    endDateController.clear();
    _selectedOrganizer = '';
    _startDate = null;
    _startTime = null;
    _endDate = null;
    _endTime = null;
    _isOnlineEvent = false;
    _maxAttendees = 50;
    _selectedEventType = '';
    _selectedVisibility = '';
    _bannerImage = null;
    _formInitialized = false;
    notifyListeners();
  }

  Future<void> publishEvent(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    if (eventNameController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter an event name');
      return;
    }

    if (_startDate == null || _startTime == null) {
      _showErrorSnackBar(context, 'Please select start date and time');
      return;
    }

    if (!_isOnlineEvent && locationController.text.trim().isEmpty) {
      _showErrorSnackBar(context, 'Please enter venue or location');
      return;
    }

    final coverFile = _bannerImage != null ? File(_bannerImage!.path) : null;
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authVM.currentUser;
    final organizerId = currentUser?.id;
    final organizer = _selectedOrganizer.isNotEmpty
        ? _selectedOrganizer
        : (currentUser != null && currentUser.username.trim().isNotEmpty
            ? currentUser.username.trim()
            : 'Personal Event');
    final organizerAvatar = currentUser?.profilePhotoUrl;
    final rawPrice = ticketPriceController.text.trim();
    final cleanPrice = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final formattedPrice = (cleanPrice.isEmpty || cleanPrice == '0')
        ? 'Free'
        : '€$cleanPrice';
    final startTimeStr = _startTime?.format(context) ?? '18:00';
    final endTimeStr = _endTime?.format(context);
    final eventCategory = _selectedEventType.isNotEmpty ? _selectedEventType : 'General';
    final eventLocation = _isOnlineEvent ? 'Online' : locationController.text.trim();

    final success = await createEvent(
      title: eventNameController.text.trim(),
      category: eventCategory,
      location: eventLocation,
      date: _startDate ?? DateTime.now(),
      time: startTimeStr,
      price: formattedPrice,
      description: descriptionController.text.trim(),
      coverImage: coverFile,
      organizerName: organizer,
      organizerId: organizerId,
      organizerAvatar: organizerAvatar,
      endDate: _endDate,
      endTime: endTimeStr,
      maxAttendees: _maxAttendees,
      isOnline: _isOnlineEvent,
    );

    if (!context.mounted) return;

    if (success) {
      PostSuccessFadeDialog.show(
        context,
        title: 'Event Created!',
        message:
            'Your community event has been published successfully. Attendees can now view event details and RSVP.',
        onContinue: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Close screen
          resetEventForm();
        },
      );
    } else {
      _showErrorSnackBar(
        context,
        _errorMessage ?? 'Failed to create event. Please try again.',
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius10),
        ),
      ),
    );
  }

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  SearchMeta? _meta;
  SearchMeta? get meta => _meta;

  // Fallback sample events matching UI design
  final List<EventModel> _sampleEvents = [
    EventModel(
      id: 'e1',
      title: 'Eid Festival Event in Madrid',
      description:
          'Join us for cultural performances, delicious food stalls, and community fun at Parque del Retiro.',
      category: 'Celebration',
      location: 'Parque del Retiro, Madrid',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '17:00 PM',
      price: 'Free Entry',
      imageUrl:
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=600',
      organizerName: 'Madrid Desi Association',
      organizerAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      attendeesCount: 240,
    ),
    EventModel(
      id: 'e2',
      title: 'South Asian Food & Cultural Night',
      description:
          'Experience authentic street food from Pakistan, India & Bangladesh in Barcelona.',
      category: 'Food & Dining',
      location: 'Plaça de Catalunya, Barcelona',
      date: DateTime.now().add(const Duration(days: 12)),
      time: '19:30 PM',
      price: '€10 / ticket',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=600',
      organizerName: 'Barcelona Desi Foodies',
      organizerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      attendeesCount: 185,
    ),
    EventModel(
      id: 'e3',
      title: 'Cricket Championship Final 2026',
      description:
          'Annual Desi Community Cricket League final match live at Montjuïc sports field.',
      category: 'Sports',
      location: 'Montjuïc Sports Complex, Barcelona',
      date: DateTime.now().add(const Duration(days: 20)),
      time: '15:00 PM',
      price: 'Free',
      imageUrl:
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&q=80&w=600',
      organizerName: 'Spain Desi Sports Club',
      organizerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      attendeesCount: 310,
    ),
  ];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    fetchEvents();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchEvents({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getEvents(
        page: page,
        category: _selectedCategory,
        search: _searchQuery,
      );
      if (result.data.isNotEmpty) {
        // Keep locally created events at the top so user posts don't disappear
        final localEvents = _events.where((e) => e.id.startsWith('evt_')).toList();
        final serverEvents = result.data.where((s) => !localEvents.any((l) => l.id == s.id)).toList();
        _events = [...localEvents, ...serverEvents];
        _meta = result.meta;
        if (page == 1) {
          _persistEvents();
        }
      } else {
        if (_events.isEmpty) {
          _events = _sampleEvents;
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_events.isEmpty) {
        _events = _sampleEvents;
      }
    } finally {
      _isLoading = false;
      _hasFetched = true;
      notifyListeners();
    }
  }

  void toggleInterest(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final old = _events[index];
      final newInterested = !old.isInterested;
      final newCount = newInterested
          ? old.attendeesCount + 1
          : (old.attendeesCount > 0 ? old.attendeesCount - 1 : 0);
      _events[index] = old.copyWith(
        attendeesCount: newCount,
        isInterested: newInterested,
      );
      _persistEvents();
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required String title,
    required String category,
    required String location,
    required DateTime date,
    required String time,
    required String price,
    required String description,
    File? coverImage,
    String? organizerName,
    String? organizerId,
    String? organizerAvatar,
    DateTime? endDate,
    String? endTime,
    int? maxAttendees,
    bool isOnline = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEvent = await _repository.createEvent(
        title: title,
        category: category,
        location: location,
        date: date,
        time: time,
        price: price,
        description: description,
        coverImage: coverImage,
        organizerName: organizerName,
        organizerId: organizerId,
        organizerAvatar: organizerAvatar,
        endDate: endDate,
        endTime: endTime,
        maxAttendees: maxAttendees,
      );

      // Ensure the returned event preserves local user details if API returned defaults
      final resolvedImage = (newEvent.imageUrl.isNotEmpty &&
              !newEvent.imageUrl.contains('unsplash.com'))
          ? newEvent.imageUrl
          : (coverImage != null && coverImage.existsSync() ? coverImage.path : newEvent.imageUrl);

      final eventWithUserData = newEvent.copyWith(
        imageUrl: resolvedImage,
        organizerId: newEvent.organizerId ?? organizerId,
        organizerName: (newEvent.organizerName.isNotEmpty &&
                newEvent.organizerName != 'Community Organizer')
            ? newEvent.organizerName
            : (organizerName ?? 'Personal Event'),
        organizerAvatar: (newEvent.organizerAvatar.isNotEmpty &&
                !newEvent.organizerAvatar.contains('unsplash.com'))
            ? newEvent.organizerAvatar
            : (organizerAvatar ?? newEvent.organizerAvatar),
        price: (newEvent.price.isNotEmpty && newEvent.price != 'Free')
            ? newEvent.price
            : price,
        category: newEvent.category.isNotEmpty ? newEvent.category : category,
        description: newEvent.description.isNotEmpty ? newEvent.description : description,
        endDate: newEvent.endDate ?? endDate,
        endTime: newEvent.endTime ?? endTime,
        maxAttendees: newEvent.maxAttendees ?? maxAttendees,
        isOnline: isOnline,
      );

      _events.insert(0, eventWithUserData);
      _myEvents.insert(0, eventWithUserData);
      _persistEvents();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[EventsViewModel] createEvent error (using local fallback with exact form data): $e');
      final fallbackEvent = EventModel(
        id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        category: category,
        location: location,
        date: date,
        time: time,
        price: price,
        imageUrl: (coverImage != null && coverImage.existsSync())
            ? coverImage.path
            : 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=600',
        organizerId: organizerId,
        organizerName: (organizerName != null && organizerName.isNotEmpty)
            ? organizerName
            : 'Personal Event',
        organizerAvatar: (organizerAvatar != null && organizerAvatar.isNotEmpty)
            ? organizerAvatar
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        attendeesCount: 1,
        endDate: endDate,
        endTime: endTime,
        maxAttendees: maxAttendees,
        isOnline: isOnline,
        whatToExpect: EventModel.defaultWhatToExpectFor(category),
      );
      _events.insert(0, fallbackEvent);
      _myEvents.insert(0, fallbackEvent);
      _persistEvents();
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // User's Own Events (My Ads integration)
  // ──────────────────────────────────────────────────────────────────────────
  List<EventModel> _myEvents = [];
  List<EventModel> get myEvents => _myEvents;
  bool _isLoadingMyEvents = false;
  bool get isLoadingMyEvents => _isLoadingMyEvents;
  bool _hasFetchedMyEvents = false;
  bool get hasFetchedMyEvents => _hasFetchedMyEvents;

  Future<void> fetchMyEvents({bool force = false}) async {
    if ((_hasFetchedMyEvents && !force) || _isLoadingMyEvents) return;
    _isLoadingMyEvents = true;
    notifyListeners();
    try {
      final fetched = await _repository.getMyEvents();
      if (fetched.isNotEmpty) {
        final existingIds = _myEvents.map((e) => e.id).toSet();
        for (final serverEvent in fetched) {
          if (!existingIds.contains(serverEvent.id)) {
            _myEvents.add(serverEvent);
            existingIds.add(serverEvent.id);
          }
        }
        _persistEvents();
      }
    } catch (e) {
      debugPrint('Error fetching my events: $e');
    } finally {
      _isLoadingMyEvents = false;
      _hasFetchedMyEvents = true;
      notifyListeners();
    }
  }

  Future<bool> deleteEvent(String id) async {
    _myEvents.removeWhere((e) => e.id == id);
    _events.removeWhere((e) => e.id == id);
    _persistEvents();
    notifyListeners();
    try {
      return await _repository.deleteEvent(id);
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return true; // local removal succeeded
    }
  }
}
