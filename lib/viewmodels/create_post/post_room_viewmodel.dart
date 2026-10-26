import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/room_post.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../repositories/property_repository.dart';
import '../../services/api/api_endpoints.dart';
import '../auth/auth_viewmodel.dart';
import '../profile/favourite_ads_viewmodel.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/permissions/app_toast.dart';
import '../../services/local/cache_service.dart';

class PostRoomViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;

  PostRoomViewModel(this._propertyRepository) {
    _hydrateFromCache();
    _loadLikedPropertyIds();
  }

  void _hydrateFromCache() {
    try {
      final cachedPublic = CacheService.instance.getJsonList(CacheService.keyPropertiesPublic);
      if (cachedPublic != null && cachedPublic.isNotEmpty) {
        _publicProperties = cachedPublic.map((json) => PropertyModel.fromJson(json)).toList();
      }
      final cachedUser = CacheService.instance.getJsonList(CacheService.keyPropertiesUser);
      if (cachedUser != null && cachedUser.isNotEmpty) {
        _userProperties = cachedUser.map((json) => PropertyModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[PostRoomViewModel] Hydration error: $e');
    }
  }

  void _persistPublicProperties() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyPropertiesPublic,
        _publicProperties.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _persistUserProperties() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyPropertiesUser,
        _userProperties.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  final Set<String> _likedPropertyIds = {};
  FavouriteAdsViewModel? _favouriteAdsViewModel;
  bool _showAllLocations = false;
  int _detailCarouselIndex = 0;

  void bindFavouriteAdsViewModel(FavouriteAdsViewModel favVM) {
    _favouriteAdsViewModel = favVM;
  }

  Set<String> get likedPropertyIds => _likedPropertyIds;
  bool isPropertyLiked(String id) => _likedPropertyIds.contains(id);
  bool get showAllLocations => _showAllLocations;
  int get detailCarouselIndex => _detailCarouselIndex;

  void toggleShowAllLocations() {
    _showAllLocations = !_showAllLocations;
    notifyListeners();
  }

  void setShowAllLocations(bool value) {
    if (_showAllLocations == value) return;
    _showAllLocations = value;
    notifyListeners();
  }

  void setDetailCarouselIndex(int index) {
    if (_detailCarouselIndex == index) return;
    _detailCarouselIndex = index;
    notifyListeners();
  }

  Future<void> _loadLikedPropertyIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('key_favourited_property_ids');
      if (ids != null) {
        _likedPropertyIds.clear();
        _likedPropertyIds.addAll(ids);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading liked property ids: $e');
    }
  }

  // Local drafts list
  final List<RoomPost> _localDrafts = [];

  // Rooms List State
  final List<RoomPost> _rooms = [
    RoomPost(
      title: 'Room in Madrid',
      location: 'Madrid, Spain',
      price: '350',
      status: 'Active',
      date: '20 May 2024',
      propertyType: 'Room',
      amenities: ['1 Bed', '1 Bath', 'WiFi', 'Furnished'],
      imageUrl:
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    ),
    RoomPost(
      title: 'Shared Room Barcelona',
      location: 'Barcelona, Spain',
      price: '300',
      status: 'Pending',
      date: '20 May 2024',
      propertyType: 'Shared',
      amenities: ['1 Bed', '1 Bath', 'WiFi'],
      imageUrl:
          'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=600&q=80',
    ),
    RoomPost(
      title: 'Single Room Valencia',
      location: 'Valencia, Spain',
      price: '280',
      status: 'Active',
      date: '20 May 2024',
      propertyType: 'Room',
      amenities: ['1 Bed', '1 Bath', 'WiFi'],
      imageUrl:
          'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  String _selectedFilter = 'All';

  List<PropertyModel> _publicProperties = [];
  bool _isLoadingPublic = false;
  bool _hasFetchedPublic = false;
  List<PropertyModel> _userProperties = [];
  bool _isLoadingUserProps = false;
  bool _hasFetchedUserProps = false;

  List<PropertyModel> get publicProperties => _publicProperties
      .where(
        (p) =>
            p.status.toUpperCase() == 'PUBLISHED' ||
            p.status.toUpperCase() == 'ACTIVE',
      )
      .toList();
  bool get isLoadingPublic => _isLoadingPublic;
  bool get hasFetchedPublic => _hasFetchedPublic;
  PropertyModel? _lastCreatedProperty;
  PropertyModel? get lastCreatedProperty => _lastCreatedProperty;

  List<PropertyModel> get userProperties => _userProperties;
  bool get isLoadingUserProps => _isLoadingUserProps;
  bool get hasFetchedUserProps => _hasFetchedUserProps;

  // Filtered lists mapping database properties to local compatibility
  List<PropertyModel> get filteredUserProperties {
    return _userProperties.where((p) {
      final f = _selectedFilter.toLowerCase();
      if (f == 'all') {
        return true;
      } else if (f == 'active') {
        return p.status == 'PUBLISHED';
      } else if (f == 'pending') {
        return p.status == 'DRAFT';
      } else if (f == 'expired') {
        return p.status == 'RENTED' ||
            p.status == 'INACTIVE' ||
            p.status == 'ARCHIVED';
      }
      return true;
    }).toList();
  }

  Future<void> fetchPublicProperties({String? type, bool force = false}) async {
    if (_isLoadingPublic || (_hasFetchedPublic && !force)) return;
    _isLoadingPublic = true;
    notifyListeners();
    try {
      final res = await _propertyRepository.getProperties(type: type);
      final rawList = res['properties'] as List<PropertyModel>;

      final prefs = await SharedPreferences.getInstance();
      final likedIds = prefs.getStringList('key_favourited_property_ids') ?? [];
      _likedPropertyIds.addAll(likedIds);

      // Backend-returned liked properties are synced into liked set
      for (final p in rawList) {
        if (p.isLiked) {
          _likedPropertyIds.add(p.id);
        }
      }

      // Only show ACTIVE (PUBLISHED) rooms on the public rooms screen
      _publicProperties = rawList
          .where((p) {
            final s = p.status.toUpperCase();
            return s == 'PUBLISHED' || s == 'ACTIVE';
          })
          .map((p) {
            final isLiked = _likedPropertyIds.contains(p.id);
            return p.copyWith(isLiked: isLiked);
          })
          .toList();
      if (type == null) {
        _persistPublicProperties();
      }
    } catch (e) {
      debugPrint('Error fetching public properties: $e');
    } finally {
      _hasFetchedPublic = true;
      _isLoadingPublic = false;
      notifyListeners();
    }
  }

  void syncPropertyStatus(String propertyId, String newStatus) {
    final statusUpper = newStatus.toUpperCase();
    if (statusUpper != 'PUBLISHED' && statusUpper != 'ACTIVE') {
      _publicProperties.removeWhere((p) => p.id == propertyId);
      _persistPublicProperties();
      notifyListeners();
    } else {
      final index = _publicProperties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _publicProperties[index] = _publicProperties[index].copyWith(
          status: newStatus,
        );
        _persistPublicProperties();
        notifyListeners();
      } else {
        fetchPublicProperties(force: true);
      }
    }
  }

  Future<void> fetchUserProperties({bool force = false}) async {
    if (_isLoadingUserProps || (_hasFetchedUserProps && !force)) return;
    _isLoadingUserProps = true;
    notifyListeners();
    try {
      final res = await _propertyRepository.getUserProperties();
      _userProperties = res['properties'] as List<PropertyModel>;
      _persistUserProperties();
    } catch (e) {
      debugPrint('Error fetching user properties: $e');
    } finally {
      _hasFetchedUserProps = true;
      _isLoadingUserProps = false;
      notifyListeners();
    }
  }

  void invalidateUserProperties() {
    _hasFetchedUserProps = false;
  }

  Future<PropertyModel> getPropertyDetails(String id) async {
    return await _propertyRepository.getPropertyDetails(id);
  }

  void syncLikedStatus(String propertyId, bool isLiked) {
    if (isLiked) {
      _likedPropertyIds.add(propertyId);
    } else {
      _likedPropertyIds.remove(propertyId);
    }

    final index = _publicProperties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      final p = _publicProperties[index];
      _publicProperties[index] = p.copyWith(
        isLiked: isLiked,
        likesCount: isLiked
            ? p.likesCount + 1
            : (p.likesCount > 0 ? p.likesCount - 1 : 0),
      );
    }

    if (_activeSingleProperty?.id == propertyId) {
      _activeSingleProperty = _activeSingleProperty!.copyWith(
        isLiked: isLiked,
        likesCount: isLiked
            ? _activeSingleProperty!.likesCount + 1
            : (_activeSingleProperty!.likesCount > 0
                ? _activeSingleProperty!.likesCount - 1
                : 0),
      );
    }

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(
        'key_favourited_property_ids',
        _likedPropertyIds.toList(),
      );
    });

    notifyListeners();
  }

  Future<bool> toggleLikeProperty(
    PropertyModel property, {
    bool? explicitStatus,
    FavouriteAdsViewModel? favViewModel,
  }) async {
    final bool currentlyLiked = _likedPropertyIds.contains(property.id);
    final bool newLiked = explicitStatus ?? !currentlyLiked;

    // 1. Immediately toggle in-memory set
    if (newLiked) {
      _likedPropertyIds.add(property.id);
    } else {
      _likedPropertyIds.remove(property.id);
    }

    // 2. Instantly sync to FavouriteAdsViewModel (0ms optimistic)
    final targetFavVM = favViewModel ?? _favouriteAdsViewModel;
    if (targetFavVM != null) {
      targetFavVM.syncPropertyLike(property, newLiked);
    }

    // 3. Update in _publicProperties if present
    final index = _publicProperties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      final p = _publicProperties[index];
      _publicProperties[index] = p.copyWith(
        likesCount: !newLiked
            ? (p.likesCount > 0 ? p.likesCount - 1 : 0)
            : p.likesCount + 1,
        isLiked: newLiked,
      );
    }

    // 4. Update in _activeSingleProperty if matching
    if (_activeSingleProperty?.id == property.id) {
      _activeSingleProperty = _activeSingleProperty!.copyWith(
        isLiked: newLiked,
        likesCount: !newLiked
            ? (_activeSingleProperty!.likesCount > 0
                ? _activeSingleProperty!.likesCount - 1
                : 0)
            : _activeSingleProperty!.likesCount + 1,
      );
    }

    // 5. Instantly notify listeners so UI updates synchronously
    notifyListeners();

    // 6. Persist to SharedPreferences in background
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'key_favourited_property_ids',
        _likedPropertyIds.toList(),
      );
    } catch (e) {
      debugPrint('Error updating liked property ids in prefs: $e');
    }

    // 7. Call backend API using ApiEndpoints.propertyLikeEndpoint:
    // POST /property/:id/like when liking, DELETE /property/:id/like when unliking
    try {
      if (newLiked) {
        await _propertyRepository.likeProperty(property.id);
      } else {
        await _propertyRepository.unlikeProperty(property.id);
      }
    } catch (e) {
      debugPrint('Backend like/unlike error (preserved locally): $e');
    }

    return newLiked;
  }

  Future<bool> markPropertyAsRented(String id) async {
    try {
      await _propertyRepository.markPropertyAsRented(id);
      await fetchUserProperties();
      return true;
    } catch (e) {
      debugPrint('Error marking as rented: $e');
      return false;
    }
  }

  Future<bool> markPropertyAsInactive(String id) async {
    try {
      await _propertyRepository.markPropertyAsInactive(id);
      await fetchUserProperties();
      return true;
    } catch (e) {
      debugPrint('Error marking as inactive: $e');
      return false;
    }
  }

  // Getters for Rooms
  List<RoomPost> get rooms => _rooms;
  String get selectedFilter => _selectedFilter;

  List<RoomPost> get filteredRooms {
    final List<RoomPost> baseList = _userProperties.isEmpty
        ? _rooms
        : _userProperties.map((p) => p.toRoomPost()).toList();

    if (_selectedFilter.toLowerCase() == 'all') {
      return [..._localDrafts, ...baseList];
    }

    final List<RoomPost> matchedBase = baseList
        .where(
          (room) => room.status.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();

    final List<RoomPost> matchedLocal = _localDrafts
        .where(
          (room) => room.status.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();

    return [...matchedLocal, ...matchedBase];
  }

  List<RoomPost> getBrowseRooms(String filter) {
    if (_publicProperties.isEmpty) {
      if (filter.toLowerCase() == 'all') {
        return _rooms;
      }
      if (filter.toLowerCase() == 'private room') {
        return _rooms
            .where((r) => r.propertyType.toLowerCase() == 'room')
            .toList();
      }
      return _rooms
          .where((r) => r.propertyType.toLowerCase() == filter.toLowerCase())
          .toList();
    }

    List<PropertyModel> source = _publicProperties;
    if (filter.toLowerCase() != 'all') {
      final String filterType = filter.toLowerCase() == 'private room'
          ? 'room'
          : filter.toLowerCase();
      source = _publicProperties
          .where((p) => p.type.toLowerCase() == filterType)
          .toList();
    }
    return source.map((p) => p.toRoomPost()).toList();
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<T?> _runAsync<T>(Future<T> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    _successMessage = null;
    try {
      return await action();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> publishRoom() async {
    final property = await _runAsync(
      () => _propertyRepository.createProperty(
        type: _propertyType,
        title: _title,
        description: _description,
        monthlyRent: _monthlyRent,
        availableFrom: _availableFrom != null
            ? _availableFrom!.toIso8601String().split('T').first
            : DateTime.now().toIso8601String().split('T').first,
        location: _locationAddress,
        noOfBedRooms: _bedrooms,
        noOfBathRooms: _bathrooms,
        featureIds: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        contactPreference: _contactPreference,
        photos: _photoFiles,
      ),
    );

    if (property != null) {
      _lastCreatedProperty = property;
      _publicProperties.insert(0, property);
      _userProperties.insert(0, property);
      _rooms.insert(0, property.toRoomPost());
      _persistPublicProperties();
      _persistUserProperties();
      _successMessage = 'Property posted successfully!';
      resetForm();
      notifyListeners();
      return true;
    }
    return false;
  }

  // String _formatCurrentDate() {
  //   final now = DateTime.now();
  //   const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  //   return "${now.day} ${months[now.month - 1]} ${now.year}";
  // }

  // Form State
  String _propertyType = 'Room';
  String _title = '';
  String _description = '';
  String _monthlyRent = '';
  String _deposit = '';
  bool _billsIncluded = false;
  DateTime? _availableFrom;
  String _locationAddress = '';
  int _bedrooms = 1;
  int _bathrooms = 1;
  final List<String> _selectedAmenities = [];
  final List<String> _photos = [];
  final List<File> _photoFiles = [];
  File? _videoTourFile;
  String? _videoTourPath;
  String _contactPreference = 'Chat';

  List<File> get photoFiles => _photoFiles;
  File? get videoTourFile => _videoTourFile;

  // Post Room Form Controllers
  final TextEditingController roomTitleController = TextEditingController();
  final TextEditingController roomDescriptionController =
      TextEditingController();
  final TextEditingController roomRentController = TextEditingController();
  final TextEditingController roomLocationController = TextEditingController();
  final TextEditingController roomAvailableFromController =
      TextEditingController();
  final ImagePicker _roomImagePicker = ImagePicker();

  Future<void> pickRoomPhoto([BuildContext? context]) async {
    final remaining = 8 - _photos.length;
    if (remaining <= 0) {
      AppToast.showWarning('Maximum of 8 photos allowed.');
      return;
    }

    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> pickedFiles = await _roomImagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (pickedFiles.isNotEmpty) {
        final toAdd = pickedFiles
            .take(remaining)
            .map((xf) => File(xf.path))
            .toList();
        addPhotos(toAdd);
        if (pickedFiles.length > remaining) {
          AppToast.showWarning(
            'Only $remaining photo(s) added. Maximum limit is 8.',
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking photos: $e');
    }
  }

  void clearRoomForm() {
    resetForm();
    roomTitleController.clear();
    roomDescriptionController.clear();
    roomRentController.clear();
    roomLocationController.clear();
    roomAvailableFromController.clear();
    notifyListeners();
  }

  // Getters
  String get propertyType => _propertyType;
  String get title => _title;
  String get description => _description;
  String get monthlyRent => _monthlyRent;
  String get deposit => _deposit;
  bool get billsIncluded => _billsIncluded;
  DateTime? get availableFrom => _availableFrom;
  String get locationAddress => _locationAddress;
  int get bedrooms => _bedrooms;
  int get bathrooms => _bathrooms;
  List<String> get selectedAmenities => _selectedAmenities;
  List<String> get photos => _photos;
  String? get videoTourPath => _videoTourPath;
  String get contactPreference => _contactPreference;

  // Setters and state controllers
  void setPropertyType(String type) {
    _propertyType = type;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    if (roomTitleController.text != value) {
      roomTitleController.value = roomTitleController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    if (roomDescriptionController.text != value) {
      roomDescriptionController.value = roomDescriptionController.value
          .copyWith(
            text: value,
            selection: TextSelection.collapsed(offset: value.length),
          );
    }
    notifyListeners();
  }

  void setMonthlyRent(String value) {
    _monthlyRent = value;
    if (roomRentController.text != value) {
      roomRentController.value = roomRentController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    notifyListeners();
  }

  void setDeposit(String value) {
    _deposit = value;
    notifyListeners();
  }

  void setBillsIncluded(bool value) {
    _billsIncluded = value;
    notifyListeners();
  }

  void setAvailableFrom(DateTime? date) {
    _availableFrom = date;
    if (date != null) {
      final formatted =
          "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}";
      if (roomAvailableFromController.text != formatted) {
        roomAvailableFromController.text = formatted;
      }
    } else {
      roomAvailableFromController.clear();
    }
    notifyListeners();
  }

  void setLocationAddress(String value) {
    _locationAddress = value;
    if (roomLocationController.text != value) {
      roomLocationController.value = roomLocationController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    notifyListeners();
  }

  void incrementBedrooms() {
    _bedrooms++;
    notifyListeners();
  }

  void decrementBedrooms() {
    if (_bedrooms > 1) {
      _bedrooms--;
      notifyListeners();
    }
  }

  void incrementBathrooms() {
    _bathrooms++;
    notifyListeners();
  }

  void decrementBathrooms() {
    if (_bathrooms > 1) {
      _bathrooms--;
      notifyListeners();
    }
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  // Interactive photo addition (adds a mock photo or real file)
  void addMockPhoto() {
    if (_photos.length < 8) {
      final photoNum = _photos.length + 1;
      _photos.add('https://picsum.photos/200/300?random=$photoNum');
      notifyListeners();
    }
  }

  void addPhoto(File file) {
    if (_photoFiles.length < 8) {
      _photoFiles.add(file);
      _photos.add(file.path);
      notifyListeners();
    }
  }

  void addPhotos(List<File> files) {
    bool added = false;
    for (final file in files) {
      if (_photos.length < 8) {
        _photoFiles.add(file);
        _photos.add(file.path);
        added = true;
      }
    }
    if (added) {
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _photos.length) {
      if (index < _photoFiles.length) {
        _photoFiles.removeAt(index);
      }
      _photos.removeAt(index);
      notifyListeners();
    }
  }

  void setVideoTour(File? file) {
    _videoTourFile = file;
    _videoTourPath = file?.path;
    notifyListeners();
  }

  void setVideoTourPath(String? path) {
    _videoTourPath = path;
    if (path != null) {
      _videoTourFile = File(path);
    } else {
      _videoTourFile = null;
    }
    notifyListeners();
  }

  void setContactPreference(String preference) {
    _contactPreference = preference;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    _propertyType = 'Room';
    _title = '';
    _description = '';
    _monthlyRent = '';
    _deposit = '';
    _billsIncluded = false;
    _availableFrom = null;
    _locationAddress = '';
    _bedrooms = 1;
    _bathrooms = 1;
    _selectedAmenities.clear();
    _photos.clear();
    _photoFiles.clear();
    _videoTourFile = null;
    _videoTourPath = null;
    _contactPreference = 'Chat';
    roomTitleController.clear();
    roomDescriptionController.clear();
    roomRentController.clear();
    roomLocationController.clear();
    roomAvailableFromController.clear();
    notifyListeners();
  }

  // Validation
  bool validate(BuildContext context) {
    if (_title.trim().isEmpty) {
      _showError(context, 'Title is required');
      return false;
    }
    if (_description.trim().isEmpty) {
      _showError(context, 'Description is required');
      return false;
    }
    if (_monthlyRent.trim().isEmpty) {
      _showError(context, 'Monthly Rent is required');
      return false;
    }
    if (_availableFrom == null) {
      _showError(context, 'Available date is required');
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_availableFrom!.isBefore(today)) {
      _showError(context, 'Available date cannot be in the past');
      return false;
    }
    if (_locationAddress.trim().isEmpty) {
      _showError(context, 'Location / Address is required');
      return false;
    }
    if (_photoFiles.isEmpty) {
      _showError(context, 'At least 1 photo is required');
      return false;
    }
    if (_photoFiles.length > 8) {
      _showError(context, 'Maximum 8 photos allowed');
      return false;
    }
    return true;
  }

  // Calculate form progress based on 6 key required fields
  double get formProgress {
    int totalFields = 6;
    int completedFields = 0;

    if (_title.trim().isNotEmpty) completedFields++;
    if (_description.trim().isNotEmpty) completedFields++;
    if (_monthlyRent.trim().isNotEmpty) completedFields++;
    if (_availableFrom != null) completedFields++;
    if (_locationAddress.trim().isNotEmpty) completedFields++;
    if (_photoFiles.isNotEmpty || _photos.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  // Determine current active step text based on progress
  String get currentStepText {
    bool step1Done =
        _title.trim().isNotEmpty &&
        _description.trim().isNotEmpty &&
        _monthlyRent.trim().isNotEmpty &&
        _availableFrom != null;

    bool step2Done = step1Done && _locationAddress.trim().isNotEmpty;

    if (!step1Done) {
      return 'Step 1 of 3 — Basic info';
    } else if (!step2Done) {
      return 'Step 2 of 3 — Location & Details';
    } else {
      return 'Step 3 of 3 — Media & Contact';
    }
  }

  // Save the property as a draft locally (status: Pending)
  Future<bool> saveDraft() async {
    final ok = await _runAsync(() async {
      final localDraft = RoomPost(
        title: _title.trim().isEmpty ? 'Draft Room' : _title,
        location: _locationAddress.trim().isEmpty
            ? 'Unknown Location'
            : _locationAddress,
        price: _monthlyRent.trim().isEmpty ? '0' : _monthlyRent,
        status: 'Pending',
        date: _formatCurrentDate(),
        propertyType: _propertyType,
        amenities: [
          '$_bedrooms Bed',
          '$_bathrooms Bath',
          if (_billsIncluded) 'Bills Inc.',
          ..._selectedAmenities,
        ],
        imageUrl: _photos.isNotEmpty
            ? _photos.first
            : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
      );

      _localDrafts.insert(0, localDraft);
      _rooms.insert(0, localDraft);
      _successMessage = 'Draft saved locally!';
      resetForm();
      notifyListeners();
      return true;
    });
    return ok ?? false;
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  // Applied Filters State (used for filtering the main list)
  bool _isFilterApplied = false;
  String _appliedCategory = 'All';
  String _appliedLocation = '';
  String _appliedDistance = 'Any';
  double _appliedMaxPrice = 1000.0;
  Set<String> _appliedJobTypes = {};
  Set<String> _appliedRoomTypes = {};
  String _appliedSortBy = 'Newest First';

  // Worker-specific applied filters
  String _appliedWorkerService = 'All';
  double _appliedMaxWorkerRate = 150.0;
  bool _appliedAvailableTodayOnly = false;
  bool _appliedHasVehicleOnly = false;
  bool _appliedHasToolsOnly = false;
  int _appliedMinExperience = 0;

  // Temporary Filters State (used inside the Filters screen)
  String _tempCategory = 'All';
  String _tempLocation = 'Madrid, Spain';
  String _tempDistance = 'Any';
  double _tempMaxPrice = 500.0;
  Set<String> _tempJobTypes = {'Full Time'};
  Set<String> _tempRoomTypes = {'Private Room'};
  String _tempSortBy = 'Newest First';

  // Worker-specific temporary filters
  String _tempWorkerService = 'All';
  double _tempMaxWorkerRate = 150.0;
  bool _tempAvailableTodayOnly = false;
  bool _tempHasVehicleOnly = false;
  bool _tempHasToolsOnly = false;
  int _tempMinExperience = 0;

  String _filterSearchQuery = '';

  // Getters for applied/search
  bool get isFilterApplied => _isFilterApplied;
  String get filterSearchQuery => _filterSearchQuery;
  String get appliedCategory => _appliedCategory;
  String get appliedLocation => _appliedLocation;
  String get appliedDistance => _appliedDistance;
  double get appliedMaxPrice => _appliedMaxPrice;
  Set<String> get appliedJobTypes => _appliedJobTypes;
  Set<String> get appliedRoomTypes => _appliedRoomTypes;
  String get appliedSortBy => _appliedSortBy;

  // Worker applied getters
  String get appliedWorkerService => _appliedWorkerService;
  double get appliedMaxWorkerRate => _appliedMaxWorkerRate;
  bool get appliedAvailableTodayOnly => _appliedAvailableTodayOnly;
  bool get appliedHasVehicleOnly => _appliedHasVehicleOnly;
  bool get appliedHasToolsOnly => _appliedHasToolsOnly;
  int get appliedMinExperience => _appliedMinExperience;

  bool get hasActiveWorkerFilters =>
      _isFilterApplied &&
      (_appliedWorkerService != 'All' ||
          _appliedMaxWorkerRate < 150.0 ||
          _appliedAvailableTodayOnly ||
          _appliedHasVehicleOnly ||
          _appliedHasToolsOnly ||
          _appliedMinExperience > 0 ||
          (_appliedLocation.isNotEmpty &&
              _appliedLocation != 'Madrid, Spain') ||
          _appliedSortBy != 'Newest First');

  // Getters for temp (FiltersView binds to these!)
  String get tempCategory => _tempCategory;
  String get tempLocation => _tempLocation;
  String get tempDistance => _tempDistance;
  double get tempMaxPrice => _tempMaxPrice;
  Set<String> get tempJobTypes => _tempJobTypes;
  Set<String> get tempRoomTypes => _tempRoomTypes;
  String get tempSortBy => _tempSortBy;

  // Worker temp getters
  String get tempWorkerService => _tempWorkerService;
  double get tempMaxWorkerRate => _tempMaxWorkerRate;
  bool get tempAvailableTodayOnly => _tempAvailableTodayOnly;
  bool get tempHasVehicleOnly => _tempHasVehicleOnly;
  bool get tempHasToolsOnly => _tempHasToolsOnly;
  int get tempMinExperience => _tempMinExperience;

  final TextEditingController filterLocationController = TextEditingController(
    text: 'Madrid, Spain',
  );

  static const List<String> workerServicesList = [
    'All',
    'Electrician',
    'Cleaner',
    'Driver',
    'Painter',
    'Plumber',
    'Cook',
    'Handyman',
  ];
  List<String> get workerServices => workerServicesList;

  // Setters for temp variables
  void setTempCategory(String val) {
    _tempCategory = val;
    notifyListeners();
  }

  void setTempLocation(String val) {
    _tempLocation = val;
    if (filterLocationController.text != val) {
      filterLocationController.value = filterLocationController.value.copyWith(
        text: val,
        selection: TextSelection.collapsed(offset: val.length),
      );
    }
    notifyListeners();
  }

  void setTempDistance(String val) {
    _tempDistance = val;
    notifyListeners();
  }

  void setTempMaxPrice(double val) {
    _tempMaxPrice = val;
    notifyListeners();
  }

  void toggleTempJobType(String type) {
    if (_tempJobTypes.contains(type)) {
      if (_tempJobTypes.length > 1) {
        _tempJobTypes.remove(type);
      }
    } else {
      _tempJobTypes.add(type);
    }
    notifyListeners();
  }

  void toggleTempRoomType(String type) {
    if (_tempRoomTypes.contains(type)) {
      if (_tempRoomTypes.length > 1) {
        _tempRoomTypes.remove(type);
      }
    } else {
      _tempRoomTypes.add(type);
    }
    notifyListeners();
  }

  void setTempSortBy(String val) {
    _tempSortBy = val;
    notifyListeners();
  }

  // Worker temp setters
  void setTempWorkerService(String val) {
    _tempWorkerService = val;
    notifyListeners();
  }

  void setTempMaxWorkerRate(double val) {
    _tempMaxWorkerRate = val;
    notifyListeners();
  }

  void toggleTempAvailableTodayOnly() {
    _tempAvailableTodayOnly = !_tempAvailableTodayOnly;
    notifyListeners();
  }

  void toggleTempHasVehicleOnly() {
    _tempHasVehicleOnly = !_tempHasVehicleOnly;
    notifyListeners();
  }

  void toggleTempHasToolsOnly() {
    _tempHasToolsOnly = !_tempHasToolsOnly;
    notifyListeners();
  }

  void setTempMinExperience(int val) {
    _tempMinExperience = val;
    notifyListeners();
  }

  void setFilterSearchQuery(String val) {
    _filterSearchQuery = val;
    notifyListeners();
  }

  void enterFiltersScreen({
    String? initialCategory,
    String? initialWorkerService,
    String? defaultLocation,
  }) {
    if (_isFilterApplied) {
      _tempCategory = initialCategory ?? _appliedCategory;
      _tempLocation = _appliedLocation.isNotEmpty
          ? _appliedLocation
          : (defaultLocation ?? 'Madrid, Spain');
      _tempDistance = _appliedDistance;
      _tempMaxPrice = _appliedMaxPrice;
      _tempJobTypes = Set.from(_appliedJobTypes);
      _tempRoomTypes = Set.from(_appliedRoomTypes);
      _tempSortBy = _appliedSortBy;
      _tempWorkerService = initialWorkerService ?? _appliedWorkerService;
      _tempMaxWorkerRate = _appliedMaxWorkerRate;
      _tempAvailableTodayOnly = _appliedAvailableTodayOnly;
      _tempHasVehicleOnly = _appliedHasVehicleOnly;
      _tempHasToolsOnly = _appliedHasToolsOnly;
      _tempMinExperience = _appliedMinExperience;
    } else {
      _tempCategory = initialCategory ?? 'All';
      _tempLocation = defaultLocation ?? 'Madrid, Spain';
      _tempDistance = 'Any';
      _tempMaxPrice = 500.0;
      _tempJobTypes = {'Full Time'};
      _tempRoomTypes = {'Private Room'};
      _tempSortBy = 'Newest First';
      _tempWorkerService = initialWorkerService ?? 'All';
      _tempMaxWorkerRate = 150.0;
      _tempAvailableTodayOnly = false;
      _tempHasVehicleOnly = false;
      _tempHasToolsOnly = false;
      _tempMinExperience = 0;
    }
    filterLocationController.text = _tempLocation;
    notifyListeners();
  }

  void applyFilters() {
    _appliedCategory = _tempCategory;
    _appliedLocation = _tempLocation;
    _appliedDistance = _tempDistance;
    _appliedMaxPrice = _tempMaxPrice;
    _appliedJobTypes = Set.from(_tempJobTypes);
    _appliedRoomTypes = Set.from(_tempRoomTypes);
    _appliedSortBy = _tempSortBy;

    // Worker applied
    _appliedWorkerService = _tempWorkerService;
    _appliedMaxWorkerRate = _tempMaxWorkerRate;
    _appliedAvailableTodayOnly = _tempAvailableTodayOnly;
    _appliedHasVehicleOnly = _tempHasVehicleOnly;
    _appliedHasToolsOnly = _tempHasToolsOnly;
    _appliedMinExperience = _tempMinExperience;

    _isFilterApplied = true;
    notifyListeners();
  }

  void resetFilters() {
    _tempCategory = 'All';
    _tempLocation = 'Madrid, Spain';
    _tempDistance = 'Any';
    _tempMaxPrice = 500.0;
    _tempJobTypes = {'Full Time'};
    _tempRoomTypes = {'Private Room'};
    _tempSortBy = 'Newest First';
    _tempWorkerService = 'All';
    _tempMaxWorkerRate = 150.0;
    _tempAvailableTodayOnly = false;
    _tempHasVehicleOnly = false;
    _tempHasToolsOnly = false;
    _tempMinExperience = 0;

    _appliedCategory = 'All';
    _appliedLocation = '';
    _appliedDistance = 'Any';
    _appliedMaxPrice = 1000.0;
    _appliedJobTypes = {};
    _appliedRoomTypes = {};
    _appliedSortBy = 'Newest First';
    _appliedWorkerService = 'All';
    _appliedMaxWorkerRate = 150.0;
    _appliedAvailableTodayOnly = false;
    _appliedHasVehicleOnly = false;
    _appliedHasToolsOnly = false;
    _appliedMinExperience = 0;

    _isFilterApplied = false;
    filterLocationController.text = _tempLocation;
    notifyListeners();
  }

  PropertyModel _roomPostToProperty(RoomPost r) {
    final uuid = PropertyFeatureHelper.toUuid(r.title);
    return PropertyModel(
      id: uuid,
      ownerId: '',
      type: r.propertyType,
      title: r.title,
      description: r.amenities.join(', '),
      status: r.status == 'Pending' ? 'DRAFT' : 'PUBLISHED',
      monthlyRent: r.price,
      availableFrom: DateTime.now(),
      location: r.location,
      noOfBedRooms: 1,
      noOfBathRooms: 1,
      viewsCount: 24,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      propertyPhotos: [PropertyPhoto(id: '1', url: r.imageUrl)],
      featuresAndAmenities: r.amenities,
      isLiked: _likedPropertyIds.contains(uuid),
    );
  }

  List<PropertyModel> get filteredPublicProperties {
    List<PropertyModel> list;
    if (_hasFetchedPublic) {
      list = _publicProperties
          .where(
            (p) =>
                p.status.toUpperCase() == 'PUBLISHED' ||
                p.status.toUpperCase() == 'ACTIVE',
          )
          .toList();
    } else {
      list = _publicProperties.isNotEmpty
          ? _publicProperties
              .where(
                (p) =>
                    p.status.toUpperCase() == 'PUBLISHED' ||
                    p.status.toUpperCase() == 'ACTIVE',
              )
              .toList()
          : _rooms
              .where(
                (r) =>
                    r.status.toUpperCase() == 'PUBLISHED' ||
                    r.status.toUpperCase() == 'ACTIVE',
              )
              .map(_roomPostToProperty)
              .toList();
    }

    // Map like status reactively based on _likedPropertyIds
    list = list.map((p) {
      final liked = _likedPropertyIds.contains(p.id);
      if (p.isLiked != liked) {
        return p.copyWith(isLiked: liked);
      }
      return p;
    }).toList();

    // Filter by search query
    if (_filterSearchQuery.trim().isNotEmpty) {
      final q = _filterSearchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q);
      }).toList();
    }

    if (_isFilterApplied) {
      // 1. Filter by category
      if (_appliedCategory == 'Rooms') {
        list = list.where((p) {
          final typeLower = p.type.toLowerCase();
          return typeLower == 'room' || typeLower == 'studio';
        }).toList();
      } else if (_appliedCategory != 'All') {
        return [];
      }

      // 2. Filter by location
      if (_appliedLocation.trim().isNotEmpty) {
        final q = _appliedLocation.toLowerCase();
        list = list.where((p) => p.location.toLowerCase().contains(q)).toList();
      }

      // 3. Filter by price
      list = list.where((p) {
        final price = double.tryParse(p.monthlyRent) ?? 0.0;
        return price <= _appliedMaxPrice;
      }).toList();

      // 4. Filter by room types
      if (_appliedRoomTypes.isNotEmpty) {
        list = list.where((p) {
          final pType = p.type.toLowerCase();
          return _appliedRoomTypes.any((t) {
            final tLower = t.toLowerCase();
            if (tLower == 'private room') {
              return pType == 'room' &&
                  !(p.title.toLowerCase().contains('shared') ||
                      p.description.toLowerCase().contains('shared'));
            }
            if (tLower == 'shared') {
              return pType == 'room' &&
                  (p.title.toLowerCase().contains('shared') ||
                      p.description.toLowerCase().contains('shared'));
            }
            return pType == tLower;
          });
        }).toList();
      }

      // 5. Sort
      if (_appliedSortBy == 'Newest First') {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_appliedSortBy == 'Price: Low to High') {
        list.sort((a, b) {
          final priceA = double.tryParse(a.monthlyRent) ?? 0.0;
          final priceB = double.tryParse(b.monthlyRent) ?? 0.0;
          return priceA.compareTo(priceB);
        });
      } else if (_appliedSortBy == 'Price: High to Low') {
        list.sort((a, b) {
          final priceA = double.tryParse(a.monthlyRent) ?? 0.0;
          final priceB = double.tryParse(b.monthlyRent) ?? 0.0;
          return priceB.compareTo(priceA);
        });
      } else if (_appliedSortBy == 'Most Popular') {
        list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
      }
    }

    return list;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Room Bookmark & Page View Tracking
  // ──────────────────────────────────────────────────────────────────────────
  final Set<String> _bookmarkedRoomIds = {};
  bool isRoomBookmarked(String id) => _bookmarkedRoomIds.contains(id);

  bool toggleBookmarkRoom(String id) {
    if (_bookmarkedRoomIds.contains(id)) {
      _bookmarkedRoomIds.remove(id);
      notifyListeners();
      return false;
    } else {
      _bookmarkedRoomIds.add(id);
      notifyListeners();
      return true;
    }
  }

  int _detailsImageIndex = 0;
  int get detailsImageIndex => _detailsImageIndex;

  void setDetailsImageIndex(int index) {
    _detailsImageIndex = index;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Room Details View Helpers
  // ──────────────────────────────────────────────────────────────────────────
  String getUserLocation(UserModel? user) {
    if (user == null || user.address == null) return 'Barcelona, Spain';
    final addr = user.address!;
    final parts = <String>[];
    if (addr.city != null && addr.city!.trim().isNotEmpty) {
      parts.add(addr.city!.trim());
    } else if (addr.province != null && addr.province!.trim().isNotEmpty) {
      parts.add(addr.province!.trim());
    }
    if (addr.country != null && addr.country!.trim().isNotEmpty) {
      parts.add(addr.country!.trim());
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Barcelona, Spain';
  }

  List<PropertyModel> get filteredPublicPropertiesForRoomDetails {
    final String activeFilterLower = _selectedFilter.toLowerCase();
    List<PropertyModel> rooms = filteredPublicProperties
        .where(
          (p) =>
              p.status.toUpperCase() == 'PUBLISHED' ||
              p.status.toUpperCase() == 'ACTIVE',
        )
        .toList();

    if (activeFilterLower != 'all') {
      rooms = rooms.where((p) {
        final typeLower = p.type.toLowerCase();
        if (activeFilterLower == 'private room') {
          return typeLower == 'room' &&
              !(p.title.toLowerCase().contains('shared') ||
                  p.description.toLowerCase().contains('shared'));
        }
        if (activeFilterLower == 'shared') {
          return typeLower == 'room' &&
              (p.title.toLowerCase().contains('shared') ||
                  p.description.toLowerCase().contains('shared'));
        }
        return typeLower == activeFilterLower;
      }).toList();
    }
    return rooms;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Single Room Details State & Methods
  // ──────────────────────────────────────────────────────────────────────────
  PropertyModel? _activeSingleProperty;
  PropertyOwner? _activePropertyOwner;
  int _singlePropertyPageIndex = 0;
  final PageController singlePropertyPageController = PageController();

  PropertyModel? get activeSingleProperty => _activeSingleProperty;
  PropertyOwner? get activePropertyOwner => _activePropertyOwner;
  int get singlePropertyPageIndex => _singlePropertyPageIndex;

  void setSinglePropertyPageIndex(int index) {
    _singlePropertyPageIndex = index;
    notifyListeners();
  }

  Future<void> initSingleRoomDetails(
    PropertyModel initialProperty,
    AuthViewModel authViewModel, {
    bool force = false,
  }) async {
    if (!force && _activeSingleProperty?.id == initialProperty.id) {
      return;
    }
    _activeSingleProperty = initialProperty;
    _activePropertyOwner = initialProperty.owner;
    _singlePropertyPageIndex = 0;
    if (singlePropertyPageController.hasClients) {
      singlePropertyPageController.jumpToPage(0);
    }
    notifyListeners();

    try {
      final updated = await getPropertyDetails(initialProperty.id);
      _activeSingleProperty = updated;

      if (updated.owner != null &&
          updated.owner!.fullName.trim().isNotEmpty &&
          updated.owner!.fullName.trim() != 'User' &&
          updated.owner!.fullName.trim() != 'User Name') {
        _activePropertyOwner = updated.owner;
      } else if (updated.ownerId.isNotEmpty) {
        final userProfile = await authViewModel.fetchUserProfileById(
          updated.ownerId,
        );
        if (userProfile != null &&
            userProfile.username.trim().isNotEmpty &&
            userProfile.username.trim() != 'User Name') {
          _activePropertyOwner = PropertyOwner(
            id: userProfile.id,
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            profilePhotoUrl: userProfile.profilePhotoUrl,
            createdAt: userProfile.createdAt ?? '',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error fetching updated property details or owner details: $e',
      );
    }
  }

  PropertyOwner? resolveActiveOwner(
    PropertyModel activeProperty,
    dynamic currentUser,
  ) {
    PropertyOwner? owner = _activePropertyOwner ?? activeProperty.owner;
    if (owner == null ||
        owner.fullName.trim().isEmpty ||
        owner.fullName.trim() == 'User' ||
        owner.fullName.trim() == 'User Name') {
      if (currentUser != null &&
          activeProperty.ownerId.isNotEmpty &&
          activeProperty.ownerId == currentUser.id) {
        owner = PropertyOwner(
          id: currentUser.id,
          firstName: currentUser.firstName,
          lastName: currentUser.lastName,
          profilePhotoUrl: currentUser.profilePhotoUrl,
          createdAt:
              currentUser.createdAt ??
              activeProperty.createdAt.toIso8601String(),
        );
      }
    }
    return owner;
  }

  Future<bool> toggleSinglePropertyLike(
    PropertyModel activeProperty,
    FavouriteAdsViewModel favViewModel,
  ) async {
    final bool isLiked =
        favViewModel.isFavourited(activeProperty.id) ||
        isPropertyLiked(activeProperty.id);
    final bool newStatus = !isLiked;

    // 1. Instantly update FavouriteAdsViewModel and active single property (0ms optimistic)
    favViewModel.syncPropertyLike(activeProperty, newStatus);
    updateActiveSinglePropertyLike(newStatus);

    // 2. Perform toggle in PostRoomViewModel (in-memory + background network)
    await toggleLikeProperty(
      activeProperty,
      explicitStatus: newStatus,
      favViewModel: favViewModel,
    );
    return newStatus;
  }

  void updateActiveSinglePropertyLike(bool isLiked) {
    if (_activeSingleProperty != null) {
      _activeSingleProperty = _activeSingleProperty!.copyWith(isLiked: isLiked);
      notifyListeners();
    }
  }

  String resolvePropertyImageUrl(String? url, {String? fallback}) {
    if (url == null || url.isEmpty) {
      return fallback ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80';
    }
    if (url.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$url';
    }
    return url;
  }

  String getTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) {
      return 'Posted ${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return 'Posted ${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return 'Posted ${diff.inMinutes} minutes ago';
    }
    return 'Posted just now';
  }

  String getMemberYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '2024';
    try {
      final dt = DateTime.parse(dateStr);
      return dt.year.toString();
    } catch (_) {
      return '2024';
    }
  }

  bool hasWifi(PropertyModel p) {
    return p.featuresAndAmenities.any((a) => a.toLowerCase().contains('wifi'));
  }

  @override
  void dispose() {
    roomTitleController.dispose();
    roomDescriptionController.dispose();
    roomRentController.dispose();
    roomLocationController.dispose();
    roomAvailableFromController.dispose();
    filterLocationController.dispose();
    singlePropertyPageController.dispose();
    super.dispose();
  }
}
