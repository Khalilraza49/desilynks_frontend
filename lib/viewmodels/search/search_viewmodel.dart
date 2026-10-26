import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/job_model.dart';
import '../../models/worker_profile_model.dart';
import '../../models/search_result_model.dart';
import '../../repositories/search_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository;

  SearchViewModel(this._repository);

  final TextEditingController searchController = TextEditingController();

  final List<String> _recentSearches = [
    'Delivery Driver',
    'Private room barcelona',
    'iphone 14',
    'electricity madrid',
  ];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    notifyListeners();
  }

  // ─── Popular Searches ───
  static const List<Map<String, String>> _popularSearches = [
    {'emoji': '🏡', 'label': 'room for rent'},
    {'emoji': '💼', 'label': 'jobs in madrid'},
    {'emoji': '🔧', 'label': 'plumber'},
    {'emoji': '⏰', 'label': 'part time'},
    {'emoji': '🏡', 'label': 'house for rent'},
    {'emoji': '👨‍🍳', 'label': 'chef barcelona'},
  ];
  List<Map<String, String>> get popularSearches => _popularSearches;

  Future<void> performSearch(String query) async {
    final trimmed = query.trim();
    searchController.text = trimmed;
    if (trimmed.isNotEmpty) {
      addRecentSearch(trimmed);
    }
    _hasSearched = true;
    clearSuggestions();
    await search(trimmed);
  }

  void cancelSearch() {
    searchController.clear();
    clearSuggestions();
    _hasSearched = false;
    _currentQuery = '';
    notifyListeners();
  }

  String formatAdsSubtitle(int count) =>
      '$count Active Listing${count == 1 ? '' : 's'}';

  String formatFavsSubtitle(int count) =>
      '$count Saved Item${count == 1 ? '' : 's'}';

  String formatJobsSubtitle(int count) =>
      '$count Posted Job${count == 1 ? '' : 's'}';

  String formatPostsSubtitle(int count) =>
      '$count Community Post${count == 1 ? '' : 's'}';

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─── Suggestions State ───
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;

  Timer? _debounceTimer;
  String _lastSuggestQuery = '';

  // ─── Search Results State ───
  /// 0 = Properties, 1 = Jobs, 2 = Worker Profiles
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  List<PropertyModel> _propertyResults = [];
  List<PropertyModel> get propertyResults => _propertyResults;

  List<JobModel> _jobResults = [];
  List<JobModel> get jobResults => _jobResults;

  List<WorkerProfileModel> _workerResults = [];
  List<WorkerProfileModel> get workerResults => _workerResults;

  SearchMeta? _searchMeta;
  SearchMeta? get searchMeta => _searchMeta;

  SearchHealthModel? _healthStatus;
  SearchHealthModel? get healthStatus => _healthStatus;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  String get currentSuggestIndex {
    switch (_selectedTabIndex) {
      case 0:
        return 'properties';
      case 1:
        return 'jobs';
      case 2:
        return 'worker_profiles';
      default:
        return 'properties';
    }
  }

  String get currentSuggestField {
    switch (_selectedTabIndex) {
      case 0:
        return 'title';
      case 1:
        return 'title';
      case 2:
        return 'service';
      default:
        return 'title';
    }
  }

  int get currentResultsCount {
    switch (_selectedTabIndex) {
      case 0:
        return (_searchMeta != null && _searchMeta!.total > _propertyResults.length)
            ? _searchMeta!.total
            : _propertyResults.length;
      case 1:
        return (_searchMeta != null && _searchMeta!.total > _jobResults.length)
            ? _searchMeta!.total
            : _jobResults.length;
      case 2:
        return (_searchMeta != null && _searchMeta!.total > _workerResults.length)
            ? _searchMeta!.total
            : _workerResults.length;
      default:
        return 0;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedTab(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
    search(searchController.text.trim());
  }

  // ─── Sub-filters for Properties (ROOM, APARTMENT, HOUSE) ───
  String? _selectedPropertyType;
  String? get selectedPropertyType => _selectedPropertyType;

  void setSelectedPropertyType(String? type) {
    if (_selectedPropertyType == type) return;
    _selectedPropertyType = type;
    notifyListeners();
    search(searchController.text.trim());
  }

  // ─── Sub-filters for Jobs (FULL_TIME, PART_TIME, CONTRACT, REMOTE) ───
  String? _selectedJobType;
  String? get selectedJobType => _selectedJobType;

  String? _selectedWorkMode;
  String? get selectedWorkMode => _selectedWorkMode;

  void setSelectedJobType(String? type) {
    if (_selectedJobType == type) return;
    _selectedJobType = type;
    notifyListeners();
    search(searchController.text.trim());
  }

  void setSelectedWorkMode(String? mode) {
    if (_selectedWorkMode == mode) return;
    _selectedWorkMode = mode;
    notifyListeners();
    search(searchController.text.trim());
  }

  // ─── Sub-filters for Workers (ELECTRICIAN, PLUMBER, etc.) ───
  String? _selectedWorkerService;
  String? get selectedWorkerService => _selectedWorkerService;

  bool _selectedWorkerAvailableToday = false;
  bool get selectedWorkerAvailableToday => _selectedWorkerAvailableToday;

  void setSelectedWorkerService(String? service) {
    if (_selectedWorkerService == service) return;
    _selectedWorkerService = service;
    notifyListeners();
    search(searchController.text.trim());
  }

  void toggleWorkerAvailableToday() {
    _selectedWorkerAvailableToday = !_selectedWorkerAvailableToday;
    notifyListeners();
    search(searchController.text.trim());
  }

  // ─── Suggestions with debounce ───

  /// Called on every keystroke. Debounces by 300ms before calling the API.
  void fetchSuggestions(
    String query, {
    String? index,
    String? field,
  }) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _suggestions = [];
      _lastSuggestQuery = '';
      notifyListeners();
      return;
    }

    final targetIndex = index ?? currentSuggestIndex;
    final targetField = field ?? currentSuggestField;

    if (query == _lastSuggestQuery) return;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _lastSuggestQuery = query;
      try {
        final results = await _repository.getSuggestions(
          query: query,
          index: targetIndex,
          field: targetField,
        );
        _suggestions = results;
        notifyListeners();
      } catch (e) {
        // Silently fail on suggestions — not critical
        debugPrint('Suggestions error: $e');
      }
    });
  }

  void clearSuggestions() {
    _suggestions = [];
    _lastSuggestQuery = '';
    _debounceTimer?.cancel();
    notifyListeners();
  }

  // ─── Search Methods ───

  Future<T?> _runSearch<T>(Future<T> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProperties({
    String? query,
    String? type,
    String? status,
    String? contactPreference,
    double? minRent,
    double? maxRent,
    int? minBedrooms,
    int? minBathrooms,
    bool? billsIncluded,
    String? location,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    _currentQuery = query ?? '';
    final result = await _runSearch(
      () => _repository.searchProperties(
        query: query,
        type: type,
        status: status,
        contactPreference: contactPreference,
        minRent: minRent,
        maxRent: maxRent,
        minBedrooms: minBedrooms,
        minBathrooms: minBathrooms,
        billsIncluded: billsIncluded,
        location: location,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ),
    );
    if (result != null) {
      if (page == 1) {
        _propertyResults = result.data;
      } else {
        _propertyResults.addAll(result.data);
      }
      _searchMeta = result.meta;
      _selectedTabIndex = 0;
      notifyListeners();
    }
  }

  Future<void> searchJobs({
    String? query,
    String? category,
    String? type,
    String? workMode,
    String? experience,
    String? education,
    String? salaryPeriod,
    String? status,
    double? minSalary,
    double? maxSalary,
    String? location,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    _currentQuery = query ?? '';
    final result = await _runSearch(
      () => _repository.searchJobs(
        query: query,
        category: category,
        type: type,
        workMode: workMode,
        experience: experience,
        education: education,
        salaryPeriod: salaryPeriod,
        status: status,
        minSalary: minSalary,
        maxSalary: maxSalary,
        location: location,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ),
    );
    if (result != null) {
      if (page == 1) {
        _jobResults = result.data;
      } else {
        _jobResults.addAll(result.data);
      }
      _searchMeta = result.meta;
      _selectedTabIndex = 1;
      notifyListeners();
    }
  }

  Future<void> searchWorkerProfiles({
    String? query,
    String? service,
    bool? isAvailableToday,
    bool? ownVehicle,
    bool? ownTools,
    double? maxHourlyRate,
    double? maxDailyRate,
    int? minExperienceYears,
    String? areaCovered,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    _currentQuery = query ?? '';
    final result = await _runSearch(
      () => _repository.searchWorkerProfiles(
        query: query,
        service: service,
        isAvailableToday: isAvailableToday,
        ownVehicle: ownVehicle,
        ownTools: ownTools,
        maxHourlyRate: maxHourlyRate,
        maxDailyRate: maxDailyRate,
        minExperienceYears: minExperienceYears,
        areaCovered: areaCovered,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ),
    );
    if (result != null) {
      if (page == 1) {
        _workerResults = result.data;
      } else {
        _workerResults.addAll(result.data);
      }
      _searchMeta = result.meta;
      _selectedTabIndex = 2;
      notifyListeners();
    }
  }

  /// Check Elasticsearch cluster status and document counts.
  Future<SearchHealthModel?> checkHealth() async {
    final health = await _runSearch(() => _repository.getHealth());
    if (health != null) {
      _healthStatus = health;
      notifyListeners();
    }
    return health;
  }

  /// Quick universal search — dispatches to the correct search based on selectedTabIndex.
  Future<void> search(String query, {int page = 1}) async {
    _currentQuery = query;
    _hasSearched = true;
    clearSuggestions();

    final q = query.trim().isEmpty ? null : query.trim();

    switch (_selectedTabIndex) {
      case 0:
        await searchProperties(
          query: q,
          type: _selectedPropertyType,
          page: page,
        );
        break;
      case 1:
        await searchJobs(
          query: q,
          type: _selectedJobType,
          workMode: _selectedWorkMode,
          page: page,
        );
        break;
      case 2:
        await searchWorkerProfiles(
          query: q,
          service: _selectedWorkerService,
          isAvailableToday: _selectedWorkerAvailableToday ? true : null,
          page: page,
        );
        break;
    }
  }

  bool get hasMorePages =>
      _searchMeta != null && _searchMeta!.page < _searchMeta!.totalPages;

  Future<void> loadMore() async {
    if (_isLoading || !hasMorePages) return;
    await search(_currentQuery, page: _searchMeta!.page + 1);
  }

  void clearSearch() {
    _currentQuery = '';
    _hasSearched = false;
    searchController.clear();
    _suggestions = [];
    _propertyResults = [];
    _jobResults = [];
    _workerResults = [];
    _searchMeta = null;
    _errorMessage = null;
    _selectedPropertyType = null;
    _selectedJobType = null;
    _selectedWorkMode = null;
    _selectedWorkerService = null;
    _selectedWorkerAvailableToday = false;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
