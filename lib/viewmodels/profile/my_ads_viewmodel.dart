import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_model.dart';
import '../../repositories/property_repository.dart';
import '../../services/permissions/permission_service.dart';

class MyAdsViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;

  MyAdsViewModel(this._propertyRepository);

  String _selectedTab = 'All';
  List<PropertyModel> _userAds = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _errorMessage;

  // Edit Ad Form Key and Controllers
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  final TextEditingController editTitleController = TextEditingController();
  final TextEditingController editDescController = TextEditingController();
  final TextEditingController editPriceController = TextEditingController();
  final TextEditingController editCityController = TextEditingController();
  final TextEditingController editPostalController = TextEditingController();
  final TextEditingController editCountryController = TextEditingController();

  // Edit Ad State
  String _editSelectedCategory = 'ROOM';
  String _editSelectedPricingType = 'Fixed Price';
  String _editStatus = 'PUBLISHED';
  final List<PropertyPhoto> _editExistingPhotos = [];
  final List<String> _editPhotosToRemove = [];
  final List<File> _editNewPhotos = [];
  File? _editNewVideoTour;
  bool _editRemoveVideo = false;
  String? _currentEditingPropertyId;
  final ImagePicker _editPicker = ImagePicker();
  final Set<String> _editSelectedFeatureIds = {};

  String get selectedTab => _selectedTab;
  List<PropertyModel> get userAds => _userAds;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  String? get errorMessage => _errorMessage;

  String? get currentEditingPropertyId => _currentEditingPropertyId;
  String get editSelectedCategory => _editSelectedCategory;
  String get editSelectedPricingType => _editSelectedPricingType;
  String get editStatus => _editStatus;
  bool get isEditActive => _editStatus.toUpperCase() == 'PUBLISHED';
  bool get isEditInactive => _editStatus.toUpperCase() == 'INACTIVE';
  bool get isEditRented => _editStatus.toUpperCase() == 'RENTED';
  List<PropertyPhoto> get editExistingPhotos => _editExistingPhotos;
  List<String> get editPhotosToRemove => _editPhotosToRemove;
  List<File> get editNewPhotos => _editNewPhotos;
  File? get editNewVideoTour => _editNewVideoTour;
  bool get editRemoveVideo => _editRemoveVideo;
  int get editTotalPhotosCount =>
      _editExistingPhotos.length + _editNewPhotos.length;
  Set<String> get editSelectedFeatureIds => _editSelectedFeatureIds;

  void initEditProperty(PropertyModel property, {bool notify = true}) {
    if (_currentEditingPropertyId == property.id) return;
    _currentEditingPropertyId = property.id;
    _editStatus = property.status.toUpperCase();
    if (_editStatus.isEmpty) {
      _editStatus = 'PUBLISHED';
    }

    editTitleController.text = property.title;
    editDescController.text = property.description;
    editPriceController.text = property.monthlyRent;

    final parts = property.location.split(',');
    String city = '';
    String postal = '';
    String country = '';

    if (parts.isNotEmpty) city = parts[0].trim();
    if (parts.length > 1) postal = parts[1].trim();
    if (parts.length > 2) country = parts[2].trim();

    if (city.isEmpty) city = property.location;
    if (country.isEmpty) country = 'Spain';

    editCityController.text = city;
    editPostalController.text = postal;
    editCountryController.text = country;

    _editSelectedCategory = property.type.toUpperCase();
    if (![
      'ROOM',
      'APARTMENT',
      'HOUSE',
      'STUDIO',
    ].contains(_editSelectedCategory)) {
      _editSelectedCategory = 'ROOM';
    }
    _editSelectedPricingType = 'Fixed Price';

    _editExistingPhotos.clear();
    _editExistingPhotos.addAll(property.propertyPhotos);
    _editPhotosToRemove.clear();
    _editNewPhotos.clear();
    _editNewVideoTour = null;
    _editRemoveVideo = false;
    _editSelectedFeatureIds.clear();
    _editSelectedFeatureIds.addAll(property.parsedFeatureIds);
    if (notify) {
      notifyListeners();
    }
  }

  void setEditCategory(String value) {
    _editSelectedCategory = value;
    notifyListeners();
  }

  void setEditPricingType(String value) {
    _editSelectedPricingType = value;
    notifyListeners();
  }

  void toggleEditFeature(String featureId) {
    if (_editSelectedFeatureIds.contains(featureId)) {
      _editSelectedFeatureIds.remove(featureId);
    } else {
      _editSelectedFeatureIds.add(featureId);
    }
    notifyListeners();
  }

  Future<void> pickEditPhotos([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> picked = await _editPicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        _editNewPhotos.addAll(picked.map((x) => File(x.path)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void removeEditExistingPhoto(PropertyPhoto photo) {
    _editExistingPhotos.remove(photo);
    _editPhotosToRemove.add(photo.id);
    notifyListeners();
  }

  void removeEditNewPhoto(File file) {
    _editNewPhotos.remove(file);
    notifyListeners();
  }

  Future<void> pickEditVideo([BuildContext? context]) async {
    final allowed = await PermissionService.requestVideo(context);
    if (!allowed) return;
    try {
      final XFile? picked = await _editPicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        _editNewVideoTour = File(picked.path);
        _editRemoveVideo = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  void removeEditVideo() {
    _editRemoveVideo = true;
    notifyListeners();
  }

  void cancelNewVideo() {
    _editNewVideoTour = null;
    notifyListeners();
  }

  void notifyFormUpdate() {
    notifyListeners();
  }

  int get totalCount => _userAds.length;
  int get activeCount => _userAds
      .where(
        (ad) =>
            ad.status.toUpperCase() == 'PUBLISHED' ||
            ad.status.toUpperCase() == 'ACTIVE',
      )
      .length;
  int get pendingCount => _userAds
      .where(
        (ad) =>
            ad.status.toUpperCase() == 'DRAFT' ||
            ad.status.toUpperCase() == 'PENDING',
      )
      .length;
  int get rentedCount =>
      _userAds.where((ad) => ad.status.toUpperCase() == 'RENTED').length;
  int get inactiveCount => _userAds
      .where(
        (ad) =>
            ad.status.toUpperCase() == 'INACTIVE' ||
            ad.status.toUpperCase() == 'ARCHIVED',
      )
      .length;

  void setSelectedTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  List<PropertyModel> get filteredAds {
    if (_selectedTab == 'All') {
      return _userAds;
    }
    if (_selectedTab == 'Active') {
      return _userAds
          .where(
            (ad) =>
                ad.status.toUpperCase() == 'PUBLISHED' ||
                ad.status.toUpperCase() == 'ACTIVE',
          )
          .toList();
    }
    if (_selectedTab == 'Pending') {
      return _userAds
          .where(
            (ad) =>
                ad.status.toUpperCase() == 'DRAFT' ||
                ad.status.toUpperCase() == 'PENDING',
          )
          .toList();
    }
    if (_selectedTab == 'Rented') {
      return _userAds
          .where((ad) => ad.status.toUpperCase() == 'RENTED')
          .toList();
    }
    if (_selectedTab == 'Inactive') {
      return _userAds
          .where(
            (ad) =>
                ad.status.toUpperCase() == 'INACTIVE' ||
                ad.status.toUpperCase() == 'ARCHIVED',
          )
          .toList();
    }
    return _userAds;
  }

  Future<void> fetchUserAds({bool force = false}) async {
    if ((_hasFetched && !force) || (_isLoading && !force)) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _propertyRepository.getUserProperties(
        page: 1,
        limit: 50,
      );
      _userAds = res['properties'] as List<PropertyModel>;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching user ads: $e');
    } finally {
      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _userAds = [];
    _hasFetched = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateAd(
    String id, {
    required String type,
    required String title,
    required String description,
    required String monthlyRent,
    required String deposit,
    required bool billsIncluded,
    required String availableFrom,
    required String location,
    required int noOfBedRooms,
    required int noOfBathRooms,
    List<String>? featureIds,
    String? contactPreference,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.updatePropertyDetails(
        id,
        type: type,
        title: title,
        description: description,
        monthlyRent: monthlyRent,
        deposit: deposit,
        billsIncluded: billsIncluded,
        availableFrom: availableFrom,
        location: location,
        noOfBedRooms: noOfBedRooms,
        noOfBathRooms: noOfBathRooms,
        featureIds: featureIds,
        contactPreference: contactPreference,
      );
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after update: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating ad details: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAd(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.deleteProperty(id);
      _userAds.removeWhere((ad) => ad.id == id);
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after delete: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting property ad: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateLocalAdStatus(String id, String newStatus) {
    final index = _userAds.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      _userAds[index] = _userAds[index].copyWith(status: newStatus);
    }
  }

  Future<bool> markPropertyAsRented(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.markPropertyAsRented(id);
      _editStatus = 'RENTED';
      _updateLocalAdStatus(id, 'RENTED');
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after status change: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('HttpException: ', '');
      debugPrint('Error marking property as rented: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markPropertyAsInactive(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.markPropertyAsInactive(id);
      _editStatus = 'INACTIVE';
      _updateLocalAdStatus(id, 'INACTIVE');
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after status change: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('HttpException: ', '');
      debugPrint('Error marking property as inactive: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markPropertyAsActive(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.markPropertyAsActive(id);
      _editStatus = 'PUBLISHED';
      _updateLocalAdStatus(id, 'PUBLISHED');
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after status change: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('HttpException: ', '');
      debugPrint('Error marking property as active: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setEditPropertyStatus(String id, String newStatus) async {
    final upper = newStatus.toUpperCase();
    if (upper == 'INACTIVE') {
      return markPropertyAsInactive(id);
    } else if (upper == 'RENTED') {
      return markPropertyAsRented(id);
    } else {
      return markPropertyAsActive(id);
    }
  }

  Future<bool> updateAdPhotos(
    String id, {
    List<File>? newPhotos,
    List<String>? photosToRemove,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.updatePropertyPhotos(
        id,
        newPhotos: newPhotos,
        photosToRemove: photosToRemove,
      );
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after photo update: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating property photos: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAdVideo(
    String id, {
    File? videoTour,
    bool removeVideo = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _propertyRepository.updatePropertyVideo(
        id,
        videoTour: videoTour,
        removeVideo: removeVideo,
      );
      try {
        final res = await _propertyRepository.getUserProperties(
          page: 1,
          limit: 50,
        );
        _userAds = res['properties'] as List<PropertyModel>;
      } catch (e) {
        debugPrint('Error refreshing ads after video update: $e');
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating property video: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> boostAd(String id) async {
    final index = _userAds.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      final ad = _userAds[index];
      _userAds[index] = PropertyModel(
        id: ad.id,
        ownerId: ad.ownerId,
        type: ad.type,
        title: ad.title,
        description: ad.description,
        status: ad.status,
        monthlyRent: ad.monthlyRent,
        deposit: ad.deposit,
        billsIncluded: ad.billsIncluded,
        availableFrom: ad.availableFrom,
        location: ad.location,
        noOfBedRooms: ad.noOfBedRooms,
        noOfBathRooms: ad.noOfBathRooms,
        featuresAndAmenities: ad.featuresAndAmenities,
        viewsCount: ad.viewsCount + 50,
        createdAt: ad.createdAt,
        updatedAt: ad.updatedAt,
        propertyPhotos: ad.propertyPhotos,
        likesCount: ad.likesCount,
        isLiked: ad.isLiked,
        owner: ad.owner,
      );
      notifyListeners();
    }
    return true;
  }

  Future<bool> toggleStatus(String id) async {
    final index = _userAds.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      final ad = _userAds[index];
      if (ad.status == 'PUBLISHED') {
        return markPropertyAsInactive(id);
      } else {
        return markPropertyAsActive(id);
      }
    }
    return false;
  }

  @override
  void dispose() {
    editTitleController.dispose();
    editDescController.dispose();
    editPriceController.dispose();
    editCityController.dispose();
    editPostalController.dispose();
    editCountryController.dispose();
    super.dispose();
  }
}
