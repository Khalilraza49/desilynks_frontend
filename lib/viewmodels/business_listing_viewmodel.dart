import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/business_listing_model.dart';
import '../models/search_result_model.dart';
import '../repositories/business_listing_repository.dart';

class BusinessListingViewModel extends ChangeNotifier {
  final BusinessListingRepository _repository;

  BusinessListingViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ─── State ───
  List<BusinessListingModel> _myListings = [];
  List<BusinessListingModel> get myListings => _myListings;
  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  bool _hasFetchedAll = false;
  bool get hasFetchedAll => _hasFetchedAll;

  List<BusinessListingModel> _allListings = [];
  List<BusinessListingModel> get allListings => _allListings;

  BusinessListingModel? _currentListing;
  BusinessListingModel? get currentListing => _currentListing;

  BusinessAnalyticsModel? _currentAnalytics;
  BusinessAnalyticsModel? get currentAnalytics => _currentAnalytics;

  SearchMeta? _meta;
  SearchMeta? get meta => _meta;

  // ─── Filter & Search State for Local Businesses ───
  int _selectedTab = 0; // 0 = All Businesses, 1 = My Businesses
  int get selectedTab => _selectedTab;

  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedCategoryFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;

  void setSelectedTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  void setSelectedCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    searchController.clear();
    _searchQuery = '';
    _selectedCategoryFilter = null;
    notifyListeners();
  }

  List<BusinessListingModel> get displayedListings {
    final base = _allListings;
    return base.where((biz) {
      // Category filter
      if (_selectedCategoryFilter != null &&
          _selectedCategoryFilter!.isNotEmpty &&
          _selectedCategoryFilter != 'All') {
        final filterLower = _selectedCategoryFilter!.toLowerCase();
        final catMatch = biz.category.toLowerCase() == filterLower ||
            (biz.categoryId != null &&
                biz.categoryId!.toLowerCase() == filterLower);
        if (!catMatch) return false;
      }
      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatch = biz.name.toLowerCase().contains(q);
        final addrMatch = biz.address.toLowerCase().contains(q);
        final descMatch = biz.description.toLowerCase().contains(q);
        final phoneMatch = biz.phone.toLowerCase().contains(q);
        final catMatch = biz.category.toLowerCase().contains(q);
        return nameMatch || addrMatch || descMatch || phoneMatch || catMatch;
      }
      return true;
    }).toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<T?> _runAsync<T>(Future<T> Function() action) async {
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

  // ─── 1. Create Listing ───
  Future<bool> createBusinessListing({
    required String name,
    required String category,
    required String address,
    required String phone,
    String? whatsApp,
    String? website,
    required String description,
    required String monToFriStartTime,
    required String monToFriEndTime,
    required String saturdayStartTime,
    required String saturdayEndTime,
    String? sundayStartTime,
    String? sundayEndTime,
    required bool isClosedOnSunday,
    File? logo,
    File? coverPhoto,
    List<File>? gallery,
  }) async {
    final listing = await _runAsync(
      () => _repository.createBusinessListing(
        name: name,
        category: category,
        address: address,
        phone: phone,
        whatsApp: whatsApp,
        website: website,
        description: description,
        monToFriStartTime: monToFriStartTime,
        monToFriEndTime: monToFriEndTime,
        saturdayStartTime: saturdayStartTime,
        saturdayEndTime: saturdayEndTime,
        sundayStartTime: sundayStartTime,
        sundayEndTime: sundayEndTime,
        isClosedOnSunday: isClosedOnSunday,
        logo: logo,
        coverPhoto: coverPhoto,
        gallery: gallery,
      ),
    );

    if (listing != null) {
      _currentListing = listing;
      _myListings.removeWhere((l) => l.id == listing.id);
      _myListings.insert(0, listing);
      _allListings.removeWhere((l) => l.id == listing.id);
      _allListings.insert(0, listing);
      _successMessage = 'Business listing created successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 2. Fetch User Listings ───
  Future<void> fetchMyListings({
    int page = 1,
    String? status,
    String? category,
    bool force = false,
  }) async {
    if ((_hasFetched && !force && page == 1) || _isLoading) return;
    final result = await _runAsync(
      () => _repository.getMyListings(
        page: page,
        status: status,
        category: category,
      ),
    );

    _hasFetched = true;
    if (result != null) {
      if (page == 1) {
        final fetchedIds = result.data.map((l) => l.id).toSet();
        final localFresh =
            _myListings.where((l) => !fetchedIds.contains(l.id)).toList();
        _myListings = [...localFresh, ...result.data];
      } else {
        final existingIds = _myListings.map((l) => l.id).toSet();
        _myListings.addAll(
          result.data.where((l) => !existingIds.contains(l.id)),
        );
      }
      _meta = result.meta;
      notifyListeners();
    }
  }

  // ─── 3. Fetch All Listings ───
  Future<void> fetchAllListings({
    int page = 1,
    String? category,
    bool force = false,
  }) async {
    if ((_hasFetchedAll && !force && page == 1 && category == null) || _isLoading) return;
    final result = await _runAsync(
      () => _repository.getAllListings(page: page, category: category),
    );

    if (category == null && page == 1) {
      _hasFetchedAll = true;
    }

    if (result != null) {
      if (page == 1) {
        final fetchedIds = result.data.map((l) => l.id).toSet();
        final localFresh =
            _allListings.where((l) => !fetchedIds.contains(l.id)).toList();
        _allListings = [...localFresh, ...result.data];
      } else {
        final existingIds = _allListings.map((l) => l.id).toSet();
        _allListings.addAll(
          result.data.where((l) => !existingIds.contains(l.id)),
        );
      }
      _meta = result.meta;
      notifyListeners();
    }
  }

  // ─── Refresh All ───
  Future<void> refreshAll() async {
    await Future.wait([
      fetchAllListings(page: 1, force: true),
      fetchMyListings(page: 1, force: true),
    ]);
  }

  // ─── 4. Fetch Listing Analytics ───
  Future<void> fetchListingAnalytics(
    String id, {
    String period = 'THIS_MONTH',
  }) async {
    final analytics = await _runAsync(
      () => _repository.getListingAnalytics(id, period: period),
    );

    if (analytics != null) {
      _currentAnalytics = analytics;
      notifyListeners();
    }
  }

  // ─── 5. Fetch Listing By ID ───
  Future<void> fetchListingById(String id) async {
    final listing = await _runAsync(() => _repository.getListingById(id));
    if (listing != null) {
      _currentListing = listing;
      notifyListeners();
    }
  }

  // ─── 6. Update Listing Details ───
  Future<bool> updateListingDetails(
    String id, {
    String? name,
    String? category,
    String? address,
    String? phone,
    String? whatsApp,
    String? website,
    String? description,
    String? monToFriStartTime,
    String? monToFriEndTime,
    String? saturdayStartTime,
    String? saturdayEndTime,
    String? sundayStartTime,
    String? sundayEndTime,
    bool? isClosedOnSunday,
  }) async {
    final listing = await _runAsync(
      () => _repository.updateListingDetails(
        id,
        name: name,
        category: category,
        address: address,
        phone: phone,
        whatsApp: whatsApp,
        website: website,
        description: description,
        monToFriStartTime: monToFriStartTime,
        monToFriEndTime: monToFriEndTime,
        saturdayStartTime: saturdayStartTime,
        saturdayEndTime: saturdayEndTime,
        sundayStartTime: sundayStartTime,
        sundayEndTime: sundayEndTime,
        isClosedOnSunday: isClosedOnSunday,
      ),
    );

    if (listing != null) {
      _currentListing = listing;
      final idx = _myListings.indexWhere((l) => l.id == id);
      if (idx != -1) _myListings[idx] = listing;
      final allIdx = _allListings.indexWhere((l) => l.id == id);
      if (allIdx != -1) _allListings[allIdx] = listing;
      _successMessage = 'Business listing details updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 7. Update Listing Status ───
  Future<bool> updateListingStatus(String id, String status) async {
    final listing = await _runAsync(
      () => _repository.updateListingStatus(id, status),
    );
    if (listing != null) {
      _currentListing = listing;
      final idx = _myListings.indexWhere((l) => l.id == id);
      if (idx != -1) _myListings[idx] = listing;
      final allIdx = _allListings.indexWhere((l) => l.id == id);
      if (allIdx != -1) _allListings[allIdx] = listing;
      _successMessage = 'Listing status updated to $status!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 8. Update Logo ───
  Future<bool> updateLogo(String id, File logoFile) async {
    final listing = await _runAsync(() => _repository.updateLogo(id, logoFile));
    if (listing != null) {
      _currentListing = listing;
      final idx = _myListings.indexWhere((l) => l.id == id);
      if (idx != -1) _myListings[idx] = listing;
      final allIdx = _allListings.indexWhere((l) => l.id == id);
      if (allIdx != -1) _allListings[allIdx] = listing;
      _successMessage = 'Business logo updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 9. Update Cover Photo ───
  Future<bool> updateCoverPhoto(String id, File coverFile) async {
    final listing = await _runAsync(
      () => _repository.updateCoverPhoto(id, coverFile),
    );
    if (listing != null) {
      _currentListing = listing;
      final idx = _myListings.indexWhere((l) => l.id == id);
      if (idx != -1) _myListings[idx] = listing;
      final allIdx = _allListings.indexWhere((l) => l.id == id);
      if (allIdx != -1) _allListings[allIdx] = listing;
      _successMessage = 'Business cover photo updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 10. Update Gallery ───
  Future<bool> updateGallery(
    String id, {
    List<String>? photosToRemove,
    List<File>? newPhotos,
  }) async {
    final listing = await _runAsync(
      () => _repository.updateGallery(
        id,
        photosToRemove: photosToRemove,
        newPhotos: newPhotos,
      ),
    );

    if (listing != null) {
      _currentListing = listing;
      final idx = _myListings.indexWhere((l) => l.id == id);
      if (idx != -1) _myListings[idx] = listing;
      final allIdx = _allListings.indexWhere((l) => l.id == id);
      if (allIdx != -1) _allListings[allIdx] = listing;
      _successMessage = 'Gallery updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── 11. Record Click ───
  Future<void> recordClick(String id) async {
    try {
      await _repository.recordClick(id);
    } catch (_) {}
  }

  // ─── 12. Delete Listing ───
  Future<bool> deleteListing(String id) async {
    final result = await _runAsync(() async {
      await _repository.deleteListing(id);
      return true;
    });

    if (result == true) {
      _myListings.removeWhere((l) => l.id == id);
      _allListings.removeWhere((l) => l.id == id);
      _successMessage = 'Business listing deleted successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Post Business Listing Form State ───
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  XFile? _coverPhoto;
  XFile? get coverPhoto => _coverPhoto;

  final List<XFile> _galleryPhotos = [];
  List<XFile> get galleryPhotos => _galleryPhotos;

  TimeOfDay _monFriStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get monFriStart => _monFriStart;

  TimeOfDay _monFriEnd = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay get monFriEnd => _monFriEnd;

  TimeOfDay _satStart = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get satStart => _satStart;

  TimeOfDay _satEnd = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay get satEnd => _satEnd;

  bool _isSundayOpen = false;
  bool get isSundayOpen => _isSundayOpen;

  TimeOfDay _sunStart = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get sunStart => _sunStart;

  TimeOfDay _sunEnd = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay get sunEnd => _sunEnd;

  void setSelectedCategory(String category, {String? categoryId}) {
    _selectedCategory = category;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setCoverPhoto(XFile? photo) {
    _coverPhoto = photo;
    notifyListeners();
  }

  void addGalleryPhotos(List<XFile> photos) {
    final remaining = 10 - _galleryPhotos.length;
    if (remaining > 0) {
      _galleryPhotos.addAll(photos.take(remaining));
      notifyListeners();
    }
  }

  void removeGalleryPhoto(int index) {
    if (index >= 0 && index < _galleryPhotos.length) {
      _galleryPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void setMonFriStart(TimeOfDay t) {
    _monFriStart = t;
    notifyListeners();
  }

  void setMonFriEnd(TimeOfDay t) {
    _monFriEnd = t;
    notifyListeners();
  }

  void setSatStart(TimeOfDay t) {
    _satStart = t;
    notifyListeners();
  }

  void setSatEnd(TimeOfDay t) {
    _satEnd = t;
    notifyListeners();
  }

  void setIsSundayOpen(bool val) {
    _isSundayOpen = val;
    notifyListeners();
  }

  void setSunStart(TimeOfDay t) {
    _sunStart = t;
    notifyListeners();
  }

  void setSunEnd(TimeOfDay t) {
    _sunEnd = t;
    notifyListeners();
  }

  void resetForm() {
    businessNameController.clear();
    addressController.clear();
    phoneController.clear();
    whatsappController.clear();
    descriptionController.clear();
    _selectedCategory = '';
    _selectedCategoryId = null;
    _coverPhoto = null;
    _galleryPhotos.clear();
    _monFriStart = const TimeOfDay(hour: 9, minute: 0);
    _monFriEnd = const TimeOfDay(hour: 21, minute: 0);
    _satStart = const TimeOfDay(hour: 10, minute: 0);
    _satEnd = const TimeOfDay(hour: 20, minute: 0);
    _isSundayOpen = false;
    _sunStart = const TimeOfDay(hour: 10, minute: 0);
    _sunEnd = const TimeOfDay(hour: 18, minute: 0);
    notifyListeners();
  }
}
