import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/marketplace_item_model.dart';
import '../../models/product_ad_offer_model.dart';
import '../../models/user_model.dart';
import '../../models/property_model.dart';
import '../../repositories/product_ad_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/permissions/app_toast.dart';
import '../auth/auth_viewmodel.dart';
import '../profile/favourite_ads_viewmodel.dart';
import '../../services/local/cache_service.dart';

class MarketplaceViewModel extends ChangeNotifier {
  final ProductAdRepository? _productAdRepository;
  final AuthRepository? _authRepository;

  MarketplaceViewModel([
    this._productAdRepository,
    this._authRepository,
  ]) {
    _hydrateFromCache();
    fetchPublicProducts();
  }

  void _hydrateFromCache() {
    try {
      final cachedPublic = CacheService.instance.getJsonList(CacheService.keyMarketplacePublic);
      if (cachedPublic != null && cachedPublic.isNotEmpty) {
        _items = cachedPublic.map((json) => MarketplaceItemModel.fromJson(json)).toList();
      }
      final cachedMyAds = CacheService.instance.getJsonList(CacheService.keyMarketplaceMyAds);
      if (cachedMyAds != null && cachedMyAds.isNotEmpty) {
        _myAds = cachedMyAds.map((json) => MarketplaceItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[MarketplaceViewModel] Hydration error: $e');
    }
  }

  void _persistPublicProducts() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyMarketplacePublic,
        _items.take(30).map((i) => i.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _persistMyAds() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyMarketplaceMyAds,
        _myAds.take(30).map((i) => i.toJson()).toList(),
      );
    } catch (_) {}
  }

  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _maxPrice = 1000.0;
  String _locationFilter = '';

  bool _isLoading = false;
  String? _errorMessage;
  bool _isRefreshing = false;
  bool _hasFetched = false;
  bool _hasFetchedMyAds = false;
  bool _hasFetchedMySentOffers = false;
  bool _isMyAdsLoading = false;

  bool get isLoading => _isLoading;
  bool get isMyAdsLoading => _isMyAdsLoading;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  bool get hasFetched => _hasFetched;
  bool get hasFetchedMyAds => _hasFetchedMyAds;
  bool get hasFetchedMySentOffers => _hasFetchedMySentOffers;

  void resetFetch() {
    _hasFetched = false;
    _hasFetchedMyAds = false;
    _hasFetchedMySentOffers = false;
  }

  final List<MarketplaceItemModel> _userCreatedItems = [];
  List<MarketplaceItemModel> _items = [];
  List<MarketplaceItemModel> _myAds = [];
  final Map<String, List<ProductAdOfferModel>> _offersByAdId = {};
  List<ProductAdOfferModel> _offersOnMyAd = [];
  List<ProductAdOfferModel> _mySentOffers = [];
  final Set<String> _savedAdIds = {};

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get maxPrice => _maxPrice;
  String get locationFilter => _locationFilter;

  List<MarketplaceItemModel> get items => _items;
  List<MarketplaceItemModel> get myAds => _myAds;
  List<ProductAdOfferModel> get offersOnMyAd => _offersOnMyAd;
  List<ProductAdOfferModel> get mySentOffers => _mySentOffers;
  Set<String> get savedAdIds => _savedAdIds;

  int getOfferCountForAd(String adId) {
    return _offersByAdId[adId]?.length ?? 0;
  }

  List<ProductAdOfferModel> getOffersForAd(String adId) {
    return _offersByAdId[adId] ?? [];
  }

  int _myOffersTabIndex = 0;
  int get myOffersTabIndex => _myOffersTabIndex;
  void setMyOffersTabIndex(int index) {
    _myOffersTabIndex = index;
    notifyListeners();
  }

  bool isAdSaved(String adId) => _savedAdIds.contains(adId);

  // ================================================================
  // SELLER PROFILE FOR ITEM DETAIL (MVVM)
  // ================================================================
  final Map<String, UserModel> _sellerProfiles = {};
  final Set<String> _checkedSellerIds = {};
  bool _isLoadingSeller = false;

  bool get isLoadingSeller => _isLoadingSeller;
  UserModel? getSellerProfile(String sellerId) => _sellerProfiles[sellerId];
  bool isSellerChecked(String sellerId) => _checkedSellerIds.contains(sellerId);

  Future<void> fetchSellerProfile(
    String sellerId, {
    AuthViewModel? authViewModel,
  }) async {
    if (sellerId.isEmpty) return;
    if (_checkedSellerIds.contains(sellerId)) return;

    _isLoadingSeller = true;
    notifyListeners();

    try {
      UserModel? profile;
      if (authViewModel != null) {
        profile = await authViewModel.fetchUserProfileById(sellerId);
      } else if (_authRepository != null) {
        profile = await _authRepository.fetchUserProfileById(sellerId);
      }
      _checkedSellerIds.add(sellerId);
      if (profile != null) {
        _sellerProfiles[sellerId] = profile;
      }
    } catch (e) {
      debugPrint('Error fetching seller profile in MarketplaceViewModel: $e');
    } finally {
      _isLoadingSeller = false;
      notifyListeners();
    }
  }

  String resolveSellerName(MarketplaceItemModel item) {
    final profile = _sellerProfiles[item.sellerId];
    if (profile != null && profile.username.trim().isNotEmpty) {
      return profile.username;
    }
    return item.sellerName;
  }

  String resolveSellerAvatar(MarketplaceItemModel item) {
    final profile = _sellerProfiles[item.sellerId];
    if (profile?.profilePhotoUrl != null &&
        profile!.profilePhotoUrl!.isNotEmpty) {
      String url = profile.profilePhotoUrl!;
      if (!url.startsWith('http')) {
        url = '${ApiEndpoints.baseUrl}$url';
      }
      return url;
    }
    return item.sellerAvatar;
  }

  String resolveSellerMemberSince(MarketplaceItemModel item) {
    final profile = _sellerProfiles[item.sellerId];
    if (profile?.createdAt != null && profile!.createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(profile.createdAt!);
        return '${dt.year}';
      } catch (_) {}
    }
    return item.sellerMemberSince;
  }

  PropertyOwner resolveSellerOwner(MarketplaceItemModel item) {
    final profile = _sellerProfiles[item.sellerId];
    final sellerName = resolveSellerName(item);
    final nameParts = sellerName.split(' ');
    return PropertyOwner(
      id: item.sellerId,
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
      profilePhotoUrl: resolveSellerAvatar(item),
      createdAt: profile?.createdAt ?? item.sellerMemberSince,
    );
  }

  // ================================================================
  // PRODUCT DETAIL PHOTOS & FULL SCREEN VIEWER (MVVM)
  // ================================================================
  MarketplaceItemModel? _activeProduct;
  int _selectedProductPhotoIndex = 0;
  final PageController singleProductPageController = PageController();

  MarketplaceItemModel? get activeProduct => _activeProduct;
  int get selectedProductPhotoIndex => _selectedProductPhotoIndex;
  int get singlePropertyPageIndex => _selectedProductPhotoIndex;
  int get singleProductPageIndex => _selectedProductPhotoIndex;
  PageController get singlePropertyPageController => singleProductPageController;
  PageController get productPhotoPageController => singleProductPageController;

  void setSelectedProductPhotoIndex(int index) {
    if (_selectedProductPhotoIndex != index) {
      _selectedProductPhotoIndex = index;
      notifyListeners();
    }
  }

  void setSinglePropertyPageIndex(int index) =>
      setSelectedProductPhotoIndex(index);

  void setSingleProductPageIndex(int index) =>
      setSelectedProductPhotoIndex(index);

  void jumpToProductPhoto(int index) {
    _selectedProductPhotoIndex = index;
    if (singleProductPageController.hasClients) {
      singleProductPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }

  void initProductDetail(MarketplaceItemModel item) {
    _activeProduct = item;
    _selectedProductPhotoIndex = 0;
    if (singleProductPageController.hasClients) {
      singleProductPageController.jumpToPage(0);
    }
    notifyListeners();

    // Silently fetch fresh details by ID in the background to get any extra photos or updated data
    if (item.id.isNotEmpty && _productAdRepository != null) {
      _productAdRepository.getProductAdById(item.id).then((fresh) {
        if (_activeProduct?.id == fresh.id) {
          _activeProduct = fresh;
          notifyListeners();
        }
      }).catchError((e) {
        debugPrint('Could not refresh product ad detail: $e');
      });
    }
  }

  String resolvePropertyImageUrl(String? url, {String? fallback}) {
    if (url == null || url.trim().isEmpty) {
      return fallback ??
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600';
    }
    final trimmed = url.trim();
    if (trimmed.startsWith('http')) {
      return trimmed;
    }
    final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
        ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
        : ApiEndpoints.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$path';
  }

  String resolveProductImageUrl(String? url, {String? fallback}) =>
      resolvePropertyImageUrl(url, fallback: fallback);

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

  Future<bool> toggleSingleProductLike(
    MarketplaceItemModel item,
    FavouriteAdsViewModel favViewModel,
  ) async {
    final newStatus = await toggleSaveAd(item.id);
    favViewModel.syncProductSave(item, newStatus);
    if (_activeProduct?.id == item.id) {
      _activeProduct = _activeProduct!.copyWith(isSaved: newStatus);
      notifyListeners();
    }
    return newStatus;
  }

  Future<bool> toggleSinglePropertyLike(
    MarketplaceItemModel item,
    FavouriteAdsViewModel favViewModel,
  ) =>
      toggleSingleProductLike(item, favViewModel);

  bool isPropertyLiked(String id) => isAdSaved(id);

  List<String> getProductPhotoUrls(MarketplaceItemModel item) {
    final active = (_activeProduct != null && _activeProduct!.id == item.id)
        ? _activeProduct!
        : item;
    final List<String> list = [];
    if (active.photos.isNotEmpty) {
      for (final p in active.photos) {
        final resolved = resolvePropertyImageUrl(p.url);
        list.add(resolved);
      }
    } else if (active.photoUrls.isNotEmpty) {
      for (final p in active.photoUrls) {
        final resolved = resolvePropertyImageUrl(p);
        list.add(resolved);
      }
    } else if (active.imageUrl.trim().isNotEmpty) {
      list.add(resolvePropertyImageUrl(active.imageUrl));
    }
    if (list.isEmpty) {
      list.add(
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600',
      );
    }
    return list;
  }

  List<MarketplaceItemModel> get filteredItems {
    return _items.where((item) {
      if (_selectedCategory != 'All') {
        final catMatch =
            item.category.toLowerCase() == _selectedCategory.toLowerCase();
        final isPhoneCategoryMatch =
            _selectedCategory == 'Phones' &&
            (item.title.toLowerCase().contains('phone') ||
                item.title.toLowerCase().contains('samsung') ||
                item.title.toLowerCase().contains('iphone') ||
                item.category.toLowerCase().contains('phone'));
        if (!catMatch && !isPhoneCategoryMatch) return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = item.title.toLowerCase().contains(query);
        final categoryMatch = item.category.toLowerCase().contains(query);
        final locationMatch = item.location.toLowerCase().contains(query);
        if (!titleMatch && !categoryMatch && !locationMatch) {
          return false;
        }
      }

      if (_locationFilter.trim().isNotEmpty) {
        if (!item.location.toLowerCase().contains(
          _locationFilter.toLowerCase(),
        )) {
          return false;
        }
      }

      if (_maxPrice < 1000.0) {
        final priceNum = _extractPriceNumber(item.price);
        if (priceNum != null && priceNum > _maxPrice) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  double? _extractPriceNumber(String priceStr) {
    if (priceStr.toLowerCase().contains('free')) return 0.0;
    return double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), ''));
  }

  // ================================================================
  // FETCH / LIST APIs
  // ================================================================

  // Fetch public product ads (GET /product-ad)
  Future<void> fetchPublicProducts({bool force = false}) async {
    if (_productAdRepository == null || _isLoading || (_hasFetched && !force)) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? apiCategory = _selectedCategory != 'All'
          ? MarketplaceItemModel.categoryToApi(_selectedCategory)
          : null;

      final result = await _productAdRepository.getPublicProductAds(
        category: apiCategory,
        maxPrice: _maxPrice < 1000.0 ? _maxPrice : null,
      );

      final List<MarketplaceItemModel> fetchedList =
          result['data'] as List<MarketplaceItemModel>? ?? [];

      final Set<String> apiIds = fetchedList.map((e) => e.id).toSet();

      // Keep local user created items that aren't returned in API response yet
      final List<MarketplaceItemModel> pendingUserItems = _userCreatedItems
          .where((e) => !apiIds.contains(e.id))
          .toList();

      _items = [...pendingUserItems, ...fetchedList];
      _persistPublicProducts();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching product ads: $e');
    } finally {
      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch seller's own ads (GET /product-ad/my-ads)
  Future<void> fetchMyAds({String? status, bool force = false}) async {
    if (_productAdRepository == null || _isMyAdsLoading || (_hasFetchedMyAds && !force)) return;
    if (!(_authRepository?.isAuthenticated ?? false)) {
      _myAds = [];
      _isMyAdsLoading = false;
      notifyListeners();
      return;
    }
    _isMyAdsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _productAdRepository.getMyProductAds(limit: 50, status: status);
      _myAds = result['data'] as List<MarketplaceItemModel>? ?? [];
      _persistMyAds();
      // Also fetch live offers on my ads to populate accurate offer counts
      for (final ad in _myAds) {
        try {
          final offers = await _productAdRepository.getOffersOnMyAd(ad.id);
          _offersByAdId[ad.id] = offers;
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching my ads: $e');
    } finally {
      _hasFetchedMyAds = true;
      _isMyAdsLoading = false;
      notifyListeners();
    }
  }

  // Get product ad details by ID (GET /product-ad/:id)
  Future<MarketplaceItemModel?> getProductAdById(String id) async {
    if (_productAdRepository == null) return null;
    try {
      return await _productAdRepository.getProductAdById(id);
    } catch (e) {
      debugPrint('Error getting product ad by id: $e');
      return null;
    }
  }

  // ================================================================
  // CREATE / UPDATE / DELETE APIs
  // ================================================================

  // Create product ad (POST /product-ad)
  Future<MarketplaceItemModel> createProductAd({
    required String category,
    required String title,
    String? brand,
    required String condition,
    required String price,
    required bool negotiable,
    required String description,
    required String location,
    required List<File> photos,
  }) async {
    // Map category & condition to API enum strings
    final apiCategory = MarketplaceItemModel.categoryToApi(category);
    final apiCondition = MarketplaceItemModel.conditionToApi(condition);

    MarketplaceItemModel? createdItem;

    if (_productAdRepository != null) {
      try {
        createdItem = await _productAdRepository.createProductAd(
          category: apiCategory,
          title: title,
          brand: brand,
          condition: apiCondition,
          price: price,
          negotiable: negotiable,
          description: description,
          location: location,
          photos: photos,
        );
      } catch (e) {
        debugPrint('API product ad creation error: $e');
      }
    }

    // Fallback if repository was null or API request threw error
    createdItem ??= MarketplaceItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      location: location,
      price: price.startsWith('€') ? price : '€ $price',
      condition: condition,
      category: category,
      brand: brand,
      badgeType: 'Premium',
      imageUrl: photos.isNotEmpty
          ? photos.first.path
          : 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600',
      description: description,
      timeAgo: 'Just now',
      isNegotiable: negotiable,
    );

    _userCreatedItems.insert(0, createdItem);
    _items.insert(0, createdItem);
    _persistPublicProducts();
    notifyListeners();
    return createdItem;
  }

  // Update product ad details (PATCH /product-ad/:id)
  Future<MarketplaceItemModel?> updateProductAd(
    String id, {
    String? category,
    String? title,
    String? brand,
    String? condition,
    String? price,
    bool? negotiable,
    String? description,
    String? location,
  }) async {
    if (_productAdRepository == null) return null;
    try {
      final updated = await _productAdRepository.updateProductAd(
        id,
        category: category != null
            ? MarketplaceItemModel.categoryToApi(category)
            : null,
        title: title,
        brand: brand,
        condition: condition != null
            ? MarketplaceItemModel.conditionToApi(condition)
            : null,
        price: price,
        negotiable: negotiable,
        description: description,
        location: location,
      );

      // Update local lists
      _replaceItemInLists(id, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating product ad: $e');
      notifyListeners();
      return null;
    }
  }

  // Update product ad photos (PATCH /product-ad/:id/photos)
  Future<MarketplaceItemModel?> updateProductAdPhotos(
    String id,
    List<File> photos,
  ) async {
    if (_productAdRepository == null) return null;
    try {
      final updated = await _productAdRepository.updateProductAdPhotos(
        id,
        photos,
      );
      _replaceItemInLists(id, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating product ad photos: $e');
      notifyListeners();
      return null;
    }
  }

  // Update product ad status (PATCH /product-ad/:id/status)
  Future<MarketplaceItemModel?> updateProductAdStatus(
    String id,
    String status,
  ) async {
    if (_productAdRepository == null) return null;
    try {
      final updated = await _productAdRepository.updateProductAdStatus(
        id,
        status,
      );
      _replaceItemInLists(id, updated);
      notifyListeners();
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating product ad status: $e');
      notifyListeners();
      return null;
    }
  }

  // Delete product ad (DELETE /product-ad/:id)
  Future<bool> deleteProductAd(String id) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.deleteProductAd(id);
      _items.removeWhere((item) => item.id == id);
      _myAds.removeWhere((item) => item.id == id);
      _userCreatedItems.removeWhere((item) => item.id == id);
      _persistPublicProducts();
      _persistMyAds();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting product ad: $e');
      notifyListeners();
      return false;
    }
  }

  // ================================================================
  // OFFER APIs
  // ================================================================

  // Send offer (POST /product-ad/:id/send-offer)
  Future<bool> sendOffer(
    String adId,
    String offerPrice, {
    String? message,
  }) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.sendOffer(adId, offerPrice, message: message);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error sending offer: $e');
      notifyListeners();
      return false;
    }
  }

  // Cancel offer (PATCH /product-ad/:id/cancel-offer)
  Future<bool> cancelOffer(String adId) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.cancelOffer(adId);
      _mySentOffers.removeWhere((o) => o.adId == adId && o.isPending);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error cancelling offer: $e');
      notifyListeners();
      return false;
    }
  }

  // Get offers on my ad (GET /product-ad/:id/offers)
  Future<void> fetchOffersOnMyAd(String adId) async {
    if (_productAdRepository == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _offersOnMyAd = await _productAdRepository.getOffersOnMyAd(adId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching offers on my ad: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get my sent offers (GET /product-ad/my-offers)
  Future<void> fetchMySentOffers({bool force = false}) async {
    if ((_hasFetchedMySentOffers && !force) || _isLoading) return;
    if (_productAdRepository == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mySentOffers = await _productAdRepository.getMySentOffers();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching my sent offers: $e');
    } finally {
      _hasFetchedMySentOffers = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept offer (PATCH /product-ad/offers/:offerId/accept)
  Future<bool> acceptOffer(String offerId) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.acceptOffer(offerId);
      // Update local offer status
      final idx = _offersOnMyAd.indexWhere((o) => o.id == offerId);
      if (idx != -1) {
        // Refresh offers list
        await fetchOffersOnMyAd(_offersOnMyAd[idx].adId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error accepting offer: $e');
      notifyListeners();
      return false;
    }
  }

  // Reject offer (PATCH /product-ad/offers/:offerId/reject)
  Future<bool> rejectOffer(String offerId) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.rejectOffer(offerId);
      // Update local offer status
      final idx = _offersOnMyAd.indexWhere((o) => o.id == offerId);
      if (idx != -1) {
        await fetchOffersOnMyAd(_offersOnMyAd[idx].adId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error rejecting offer: $e');
      notifyListeners();
      return false;
    }
  }

  // ================================================================
  // SAVE / BOOKMARK APIs
  // ================================================================

  // Save ad (POST /product-ad/:id/save)
  Future<bool> saveAd(String adId) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.saveAd(adId);
      _savedAdIds.add(adId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error saving ad: $e');
      notifyListeners();
      return false;
    }
  }

  // Unsave ad (DELETE /product-ad/:id/save)
  Future<bool> unsaveAd(String adId) async {
    if (_productAdRepository == null) return false;
    try {
      await _productAdRepository.unsaveAd(adId);
      _savedAdIds.remove(adId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error unsaving ad: $e');
      notifyListeners();
      return false;
    }
  }

  // Toggle save/unsave
  Future<bool> toggleSaveAd(String adId) async {
    if (isAdSaved(adId)) {
      return unsaveAd(adId);
    } else {
      return saveAd(adId);
    }
  }

  // ================================================================
  // FILTER / SEARCH HELPERS
  // ================================================================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateFilters({String? category, String? location, double? maxPrice}) {
    if (category != null) _selectedCategory = category;
    if (location != null) _locationFilter = location;
    if (maxPrice != null) _maxPrice = maxPrice;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isRefreshing = true;
    notifyListeners();
    await fetchPublicProducts();
    _isRefreshing = false;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _maxPrice = 1000.0;
    _locationFilter = '';
    notifyListeners();
  }

  // ================================================================
  // PRIVATE HELPERS
  // ================================================================

  void _replaceItemInLists(String id, MarketplaceItemModel updated) {
    final itemIdx = _items.indexWhere((i) => i.id == id);
    if (itemIdx != -1) _items[itemIdx] = updated;

    final myAdIdx = _myAds.indexWhere((i) => i.id == id);
    if (myAdIdx != -1) _myAds[myAdIdx] = updated;

    final userIdx = _userCreatedItems.indexWhere((i) => i.id == id);
    if (userIdx != -1) _userCreatedItems[userIdx] = updated;

    _persistPublicProducts();
    _persistMyAds();
  }

  // ================================================================
  // MARKETPLACE VIEW STATE & HELPERS
  // ================================================================
  final TextEditingController marketplaceSearchController =
      TextEditingController();
  bool _showAllLocations = false;

  bool get showAllLocations => _showAllLocations;

  void setShowAllLocations(bool value) {
    _showAllLocations = value;
    notifyListeners();
  }

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

  String getUserCity(UserModel? user) {
    if (user == null || user.address == null) return '';
    return user.address?.city?.trim() ?? user.address?.province?.trim() ?? '';
  }

  List<MarketplaceItemModel> getMarketplaceItemsForView({
    required UserModel? user,
  }) {
    final userCity = getUserCity(user);
    List<MarketplaceItemModel> itemsList = filteredItems;

    if (locationFilter.trim().isNotEmpty) {
      final locQ = locationFilter.trim().toLowerCase();
      itemsList = itemsList
          .where((i) => i.location.toLowerCase().contains(locQ))
          .toList();
    } else if (!_showAllLocations && userCity.isNotEmpty) {
      final cityQ = userCity.toLowerCase();
      itemsList = itemsList
          .where((i) => i.location.toLowerCase().contains(cityQ))
          .toList();
    }
    return itemsList;
  }

  // ================================================================
  // POST PRODUCT VIEW STATE & CONTROLLERS
  // ================================================================
  final TextEditingController productTitleController = TextEditingController();
  final TextEditingController productBrandController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productLocationController =
      TextEditingController();

  String _selectedProductCategory = '';
  String _selectedProductCondition = '';
  bool _isProductNegotiable = true;
  final List<XFile> _selectedProductPhotos = [];
  final List<String> _existingProductPhotos = [];
  final ImagePicker _productImagePicker = ImagePicker();
  bool _isSubmittingProduct = false;
  bool _productFormInitialized = false;
  String? _initializedProductId;

  String get selectedProductCategory => _selectedProductCategory;
  String get selectedProductCondition => _selectedProductCondition;
  bool get isProductNegotiable => _isProductNegotiable;
  List<XFile> get selectedProductPhotos => _selectedProductPhotos;
  List<String> get existingProductPhotos => _existingProductPhotos;
  int get totalProductPhotosCount =>
      _existingProductPhotos.length + _selectedProductPhotos.length;
  bool get isSubmittingProduct => _isSubmittingProduct;

  Listenable get productProgressListenable => Listenable.merge([
        this,
        productTitleController,
        productBrandController,
        productPriceController,
        productDescriptionController,
        productLocationController,
      ]);

  double get postProductProgress {
    double progress = 0.0;
    if (_selectedProductPhotos.isNotEmpty || _existingProductPhotos.isNotEmpty) {
      progress += 0.15;
    }
    if (_selectedProductCategory.isNotEmpty) progress += 0.15;
    if (productTitleController.text.trim().isNotEmpty) progress += 0.15;
    if (productBrandController.text.trim().isNotEmpty) progress += 0.10;
    if (_selectedProductCondition.isNotEmpty) progress += 0.15;
    if (productPriceController.text.trim().isNotEmpty) progress += 0.10;
    if (productDescriptionController.text.trim().isNotEmpty) progress += 0.10;
    if (productLocationController.text.trim().isNotEmpty) progress += 0.10;
    return progress.clamp(0.0, 1.0);
  }

  void setSelectedProductCategory(String category) {
    _selectedProductCategory = category;
    notifyListeners();
  }

  void setSelectedProductCondition(String condition) {
    _selectedProductCondition = condition;
    notifyListeners();
  }

  void setIsProductNegotiable(bool negotiable) {
    _isProductNegotiable = negotiable;
    notifyListeners();
  }

  void initPostProductForm(
    MarketplaceItemModel? productToEdit, {
    bool force = false,
  }) {
    final targetId = productToEdit?.id ?? '__new__';
    if (!force && _productFormInitialized && _initializedProductId == targetId) {
      return;
    }
    _productFormInitialized = true;
    _initializedProductId = targetId;

    if (productToEdit != null) {
      _selectedProductCategory = productToEdit.category;
      productTitleController.text = productToEdit.title;
      productBrandController.text = productToEdit.brand ?? '';
      _selectedProductCondition = productToEdit.condition ?? 'New';
      productPriceController.text =
          productToEdit.price.replaceAll(RegExp(r'[^0-9.]'), '');
      _isProductNegotiable = productToEdit.isNegotiable;
      productDescriptionController.text = productToEdit.description;
      productLocationController.text = productToEdit.location;
      _selectedProductPhotos.clear();
      _existingProductPhotos.clear();
      if (productToEdit.photoUrls.isNotEmpty) {
        _existingProductPhotos.addAll(productToEdit.photoUrls);
      } else if (productToEdit.imageUrl.isNotEmpty &&
          !productToEdit.imageUrl.contains('unsplash.com')) {
        _existingProductPhotos.add(productToEdit.imageUrl);
      }
    } else {
      clearPostProductForm();
      _productFormInitialized = true;
      _initializedProductId = targetId;
    }
    notifyListeners();
  }

  Future<void> pickProductPhotos([BuildContext? context]) async {
    final remaining = 8 - (_existingProductPhotos.length + _selectedProductPhotos.length);
    if (remaining <= 0) {
      AppToast.showWarning('Maximum of 8 photos allowed.');
      return;
    }

    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> pickedImages = await _productImagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedImages.isNotEmpty) {
        final toAdd = pickedImages.take(remaining).toList();
        _selectedProductPhotos.addAll(toAdd);
        if (pickedImages.length > remaining) {
          AppToast.showWarning(
            'Only $remaining photo(s) added. Maximum limit is 8.',
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking photos: $e');
    }
  }

  Future<void> takeProductPhoto([BuildContext? context]) async {
    final remaining = 8 - (_existingProductPhotos.length + _selectedProductPhotos.length);
    if (remaining <= 0) {
      AppToast.showWarning('Maximum of 8 photos allowed.');
      return;
    }

    final allowed = await PermissionService.requestCamera(context);
    if (!allowed) return;
    try {
      final XFile? photo = await _productImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null) {
        _selectedProductPhotos.add(photo);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  Future<void> pickProductPhoto(int index, [BuildContext? context]) async {
    if (index >= _selectedProductPhotos.length) {
      return pickProductPhotos(context);
    }
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? image = await _productImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedProductPhotos[index] = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error replacing photo: $e');
    }
  }

  void removeProductPhoto(int index) {
    if (index < _selectedProductPhotos.length) {
      _selectedProductPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void removeExistingProductPhoto(int index) {
    if (index >= 0 && index < _existingProductPhotos.length) {
      _existingProductPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void clearPostProductForm() {
    _selectedProductCategory = '';
    _selectedProductCondition = '';
    _isProductNegotiable = true;
    _selectedProductPhotos.clear();
    _existingProductPhotos.clear();
    productTitleController.clear();
    productBrandController.clear();
    productPriceController.clear();
    productDescriptionController.clear();
    productLocationController.clear();
    _isSubmittingProduct = false;
    _productFormInitialized = false;
    _initializedProductId = null;
    notifyListeners();
  }

  String? validateProductForm() {
    if (_selectedProductCategory.isEmpty) {
      return 'Please select a product category';
    }
    if (productTitleController.text.trim().isEmpty) {
      return 'Please enter a product title';
    }
    if (_selectedProductCondition.isEmpty) {
      return 'Please select item condition';
    }
    if (productPriceController.text.trim().isEmpty) {
      return 'Please enter a price';
    }
    if (productDescriptionController.text.trim().isEmpty) {
      return 'Please enter a description for your product';
    }
    if (productLocationController.text.trim().isEmpty) {
      return 'Please enter your location';
    }
    return null;
  }

  Future<bool> publishProductListing({
    MarketplaceItemModel? productToEdit,
  }) async {
    if (_isSubmittingProduct) return false;
    _isSubmittingProduct = true;
    notifyListeners();

    try {
      final photoFiles =
          _selectedProductPhotos.map((x) => File(x.path)).toList();

      if (productToEdit != null) {
        await updateProductAd(
          productToEdit.id,
          category: _selectedProductCategory,
          title: productTitleController.text.trim(),
          brand: productBrandController.text.trim(),
          condition: _selectedProductCondition,
          price: productPriceController.text.trim(),
          negotiable: _isProductNegotiable,
          description: productDescriptionController.text.trim(),
          location: productLocationController.text.trim(),
        );

        if (photoFiles.isNotEmpty) {
          await updateProductAdPhotos(
            productToEdit.id,
            photoFiles,
          );
        }
      } else {
        await createProductAd(
          category: _selectedProductCategory,
          title: productTitleController.text.trim(),
          brand: productBrandController.text.trim(),
          condition: _selectedProductCondition,
          price: productPriceController.text.trim(),
          negotiable: _isProductNegotiable,
          description: productDescriptionController.text.trim(),
          location: productLocationController.text.trim(),
          photos: photoFiles,
        );
      }
      return true;
    } finally {
      _isSubmittingProduct = false;
      notifyListeners();
    }
  }

  // ================================================================
  // MAKE OFFER STATE & CONTROLLERS
  // ================================================================
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController offerMessageController = TextEditingController();
  bool _isSendingOffer = false;

  bool get isSendingOffer => _isSendingOffer;

  void resetOfferForm() {
    offerPriceController.clear();
    offerMessageController.clear();
    _isSendingOffer = false;
    notifyListeners();
  }

  Future<bool> submitMakeOffer(String adId) async {
    final price = offerPriceController.text.trim();
    if (price.isEmpty) return false;

    _isSendingOffer = true;
    notifyListeners();

    try {
      final message = offerMessageController.text.trim();
      final success = await sendOffer(
        adId,
        price,
        message: message.isNotEmpty ? message : null,
      );
      return success;
    } finally {
      _isSendingOffer = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    marketplaceSearchController.dispose();
    singleProductPageController.dispose();
    productTitleController.dispose();
    productBrandController.dispose();
    productPriceController.dispose();
    productDescriptionController.dispose();
    productLocationController.dispose();
    offerPriceController.dispose();
    offerMessageController.dispose();
    super.dispose();
  }
}
