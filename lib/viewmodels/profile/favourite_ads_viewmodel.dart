import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/property_model.dart';
import '../../models/marketplace_item_model.dart';
import '../../models/job_model.dart';
import '../../repositories/property_repository.dart';
import '../../repositories/product_ad_repository.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/local/cache_service.dart';

class FavouriteAdsViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final ProductAdRepository? _productAdRepository;

  FavouriteAdsViewModel(
    this._propertyRepository, {
    ProductAdRepository? productAdRepository,
  }) : _productAdRepository = productAdRepository {
    _loadPersistedFavourites();
  }

  static const String _prefsKeySavedItems = 'key_saved_favourite_items_v2';
  static const String _prefsKeyIds = 'key_favourited_property_ids';
  static const String _prefsKeyJobIds = 'key_bookmarked_job_ids';

  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _savedItems = [];
  final Set<String> _favouritedIds = {};
  Map<String, dynamic>? _lastRemovedItem;
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _errorMessage;

  String get selectedCategory => _selectedCategory;
  List<Map<String, dynamic>> get savedItems => _savedItems;
  Set<String> get favouritedIds => _favouritedIds;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  String? get errorMessage => _errorMessage;

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  Map<String, dynamic> _propertyToItemMap(PropertyModel p) {
    String url = p.propertyPhotos.isNotEmpty ? p.propertyPhotos.first.url : '';
    if (url.startsWith('/')) {
      url = '${ApiEndpoints.baseUrl}$url';
    } else if (url.isEmpty) {
      url =
          'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80';
    }

    final String cleanRent = p.monthlyRent
        .replaceAll('/month', '')
        .replaceAll('/mo', '')
        .trim();
    final double? parsedPrice = double.tryParse(cleanRent);
    final String formattedPrice = parsedPrice != null
        ? parsedPrice.toStringAsFixed(0)
        : cleanRent;

    final typeUpper = p.type.toUpperCase();
    String category = 'Room';
    if (typeUpper == 'APARTMENT') {
      category = 'Apartment';
    } else if (typeUpper == 'HOUSE') {
      category = 'House';
    } else if (typeUpper == 'STUDIO') {
      category = 'Studio';
    }

    return <String, dynamic>{
      'id': p.id,
      'category': category,
      'title': p.title,
      'location': p.location,
      'price': '€$formattedPrice/month',
      'imageUrl': url,
      'propertyModel': p,
    };
  }

  Map<String, dynamic> _productToItemMap(MarketplaceItemModel p) {
    String url = p.imageUrl.isNotEmpty ? p.imageUrl : '';
    if (url.startsWith('/')) {
      url = '${ApiEndpoints.baseUrl}$url';
    } else if (url.isEmpty && p.photoUrls.isNotEmpty) {
      url = p.photoUrls.first;
      if (url.startsWith('/')) {
        url = '${ApiEndpoints.baseUrl}$url';
      }
    } else if (url.isEmpty) {
      url =
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600';
    }

    final priceStr = p.price.startsWith('€') ? p.price : '€ ${p.price}';

    return <String, dynamic>{
      'id': p.id,
      'category': 'Ads',
      'title': p.title,
      'location': p.location.isNotEmpty ? p.location : 'Marketplace',
      'price': priceStr,
      'imageUrl': url,
      'productModel': p,
    };
  }

  Map<String, dynamic> _jobToItemMap(JobModel j) {
    String url = j.posterUrl ?? '';
    if (url.startsWith('/')) {
      url = '${ApiEndpoints.baseUrl}$url';
    } else if (url.isEmpty) {
      url =
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=600&q=80';
    }

    final String salaryStr = j.salary.isNotEmpty && j.salary != '0.00'
        ? (j.salary.startsWith('€') ? j.salary : '€${j.salary}/month')
        : 'Salary Negotiable';

    return <String, dynamic>{
      'id': j.id,
      'category': 'Job',
      'title': j.title,
      'location': j.location.isNotEmpty ? j.location : j.companyName,
      'price': salaryStr,
      'imageUrl': url,
      'jobModel': j,
    };
  }

  Future<void> _savePersistedFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKeyIds, _favouritedIds.toList());

      final jobIds = _savedItems
          .where((item) =>
              (item['category'] as String?)?.toLowerCase() == 'job' ||
              item['jobModel'] != null)
          .map((item) => item['id'] as String)
          .where((id) => _favouritedIds.contains(id))
          .toList();
      await prefs.setStringList(_prefsKeyJobIds, jobIds);

      final List<Map<String, dynamic>> encodableList = [];
      for (final item in _savedItems) {
        final p = item['propertyModel'] as PropertyModel?;
        final prod = item['productModel'] as MarketplaceItemModel?;
        final j = item['jobModel'] as JobModel?;
        encodableList.add({
          'id': item['id'],
          'category': item['category'],
          'title': item['title'],
          'location': item['location'],
          'price': item['price'],
          'imageUrl': item['imageUrl'],
          if (p != null) 'propertyModelJson': p.toJson(),
          if (prod != null) 'productModelJson': prod.toJson(),
          if (j != null) 'jobModelJson': j.toJson(),
        });
      }
      await prefs.setString(_prefsKeySavedItems, jsonEncode(encodableList));
    } catch (e) {
      debugPrint('Error persisting favourites: $e');
    }
  }

  static List<PropertyModel> get fallbackMockProperties => [
    PropertyModel(
      id: PropertyFeatureHelper.toUuid('Room in Madrid'),
      ownerId: '',
      type: 'Room',
      title: 'Room in Madrid',
      description: 'Cozy and spacious room in the heart of Madrid.',
      status: 'PUBLISHED',
      monthlyRent: '350',
      deposit: '350',
      billsIncluded: true,
      availableFrom: DateTime.now(),
      location: 'Madrid, Spain',
      noOfBedRooms: 1,
      noOfBathRooms: 1,
      featuresAndAmenities: ['1 Bed', '1 Bath', 'WiFi', 'Furnished'],
      viewsCount: 24,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      propertyPhotos: [
        PropertyPhoto(
          id: '1',
          url:
              'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
        ),
      ],
      isLiked: true,
    ),
    PropertyModel(
      id: PropertyFeatureHelper.toUuid('Shared Room Barcelona'),
      ownerId: '',
      type: 'Shared',
      title: 'Shared Room Barcelona',
      description: 'Shared room close to Barcelona city center.',
      status: 'PUBLISHED',
      monthlyRent: '300',
      deposit: '300',
      billsIncluded: false,
      availableFrom: DateTime.now(),
      location: 'Barcelona, Spain',
      noOfBedRooms: 1,
      noOfBathRooms: 1,
      featuresAndAmenities: ['1 Bed', '1 Bath', 'WiFi'],
      viewsCount: 15,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      propertyPhotos: [
        PropertyPhoto(
          id: '2',
          url:
              'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=600&q=80',
        ),
      ],
      isLiked: true,
    ),
    PropertyModel(
      id: PropertyFeatureHelper.toUuid('Single Room Valencia'),
      ownerId: '',
      type: 'Room',
      title: 'Single Room Valencia',
      description: 'Quiet single room in sunny Valencia.',
      status: 'PUBLISHED',
      monthlyRent: '280',
      deposit: '280',
      billsIncluded: false,
      availableFrom: DateTime.now(),
      location: 'Valencia, Spain',
      noOfBedRooms: 1,
      noOfBathRooms: 1,
      featuresAndAmenities: ['1 Bed', '1 Bath', 'WiFi'],
      viewsCount: 18,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      propertyPhotos: [
        PropertyPhoto(
          id: '3',
          url:
              'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80',
        ),
      ],
      isLiked: true,
    ),
  ];

  Future<void> _loadPersistedFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_prefsKeyIds);
      if (ids != null) {
        _favouritedIds.addAll(ids);
      }
      final jobIds = prefs.getStringList(_prefsKeyJobIds);
      if (jobIds != null) {
        _favouritedIds.addAll(jobIds);
      }

      final savedStr = prefs.getString(_prefsKeySavedItems);
      if (savedStr != null && savedStr.isNotEmpty) {
        final decoded = jsonDecode(savedStr) as List<dynamic>;
        _savedItems = List<Map<String, dynamic>>.from(
          decoded.map<Map<String, dynamic>>((e) {
            final map = Map<String, dynamic>.from(e as Map);
            PropertyModel? p;
            MarketplaceItemModel? prod;
            JobModel? j;
            if (map['propertyModelJson'] != null) {
              try {
                p = PropertyModel.fromJson(
                  Map<String, dynamic>.from(map['propertyModelJson'] as Map),
                );
              } catch (_) {}
            }
            if (map['productModelJson'] != null) {
              try {
                prod = MarketplaceItemModel.fromJson(
                  Map<String, dynamic>.from(map['productModelJson'] as Map),
                );
              } catch (_) {}
            }
            if (map['jobModelJson'] != null) {
              try {
                j = JobModel.fromJson(
                  Map<String, dynamic>.from(map['jobModelJson'] as Map),
                );
              } catch (_) {}
            }
            return <String, dynamic>{
              'id': map['id'] as String,
              'category': map['category'] as String? ?? 'Room',
              'title': map['title'] as String? ?? '',
              'location': map['location'] as String? ?? '',
              'price': map['price'] as String? ?? '',
              'imageUrl': map['imageUrl'] as String? ?? '',
              if (p != null) 'propertyModel': p,
              if (prod != null) 'productModel': prod,
              if (j != null) 'jobModel': j,
            };
          }),
        );
      }

      // Recover details for any favorited IDs (from cache or fallback mock rooms)
      for (final id in _favouritedIds) {
        final exists = _savedItems.any((item) => item['id'] == id);
        if (!exists) {
          PropertyModel? found;
          if (CacheService.isInitialized) {
            final cached = CacheService.instance.getJsonList(CacheService.keyPropertiesPublic);
            if (cached != null) {
              for (final json in cached) {
                try {
                  final p = PropertyModel.fromJson(json);
                  if (p.id == id) {
                    found = p;
                    break;
                  }
                } catch (_) {}
              }
            }
          }
          found ??= fallbackMockProperties.where((p) => p.id == id).firstOrNull;
          if (found != null) {
            _savedItems.add(_propertyToItemMap(found));
          } else if (CacheService.isInitialized) {
            final cachedJobs = CacheService.instance.getJsonList(CacheService.keyJobsPublic);
            if (cachedJobs != null) {
              for (final json in cachedJobs) {
                try {
                  final j = JobModel.fromJson(json);
                  if (j.id == id) {
                    _savedItems.add(_jobToItemMap(j));
                    break;
                  }
                } catch (_) {}
              }
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persisted favourites: $e');
    }
  }

  /// Sync liked status of a property called when user taps heart in RoomDetails or RoomSingleDetails
  void syncPropertyLike(PropertyModel property, bool isLiked) {
    if (isLiked) {
      _favouritedIds.add(property.id);
      final itemMap = _propertyToItemMap(property);
      final idx = _savedItems.indexWhere((item) => item['id'] == property.id);
      if (idx == -1) {
        _savedItems.insert(0, itemMap);
      } else {
        _savedItems[idx] = itemMap;
      }
    } else {
      _favouritedIds.remove(property.id);
      _savedItems.removeWhere((item) => item['id'] == property.id);
    }
    _savePersistedFavourites();
    notifyListeners();
  }

  /// Sync bookmarked status of a job called when user taps bookmark in JobDetailView
  void syncJobBookmark(JobModel job, bool isBookmarked) {
    if (isBookmarked) {
      _favouritedIds.add(job.id);
      final itemMap = _jobToItemMap(job);
      final idx = _savedItems.indexWhere((item) => item['id'] == job.id);
      if (idx == -1) {
        _savedItems.insert(0, itemMap);
      } else {
        _savedItems[idx] = itemMap;
      }
    } else {
      _favouritedIds.remove(job.id);
      _savedItems.removeWhere((item) => item['id'] == job.id);
    }
    _savePersistedFavourites();
    notifyListeners();
  }

  /// Sync saved status of a marketplace product called when user taps heart in detail view
  void syncProductSave(MarketplaceItemModel product, bool isSaved) {
    if (isSaved) {
      _favouritedIds.add(product.id);
      final exists = _savedItems.any((item) => item['id'] == product.id);
      if (!exists) {
        _savedItems.insert(0, _productToItemMap(product));
      } else {
        final idx = _savedItems.indexWhere((item) => item['id'] == product.id);
        if (idx != -1) {
          _savedItems[idx] = _productToItemMap(product);
        }
      }
    } else {
      _favouritedIds.remove(product.id);
      _savedItems.removeWhere((item) => item['id'] == product.id);
    }
    _savePersistedFavourites();
    notifyListeners();
  }

  Future<void> fetchFavourites({bool force = false}) async {
    if ((_hasFetched && !force) || _isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _propertyRepository.getProperties(page: 1, limit: 50);
      final List<PropertyModel> allProps =
          (res['properties'] as List?)?.cast<PropertyModel>() ??
          <PropertyModel>[];

      // Merge backend-liked properties with locally favorited ones
      for (final p in allProps) {
        if (p.isLiked || _favouritedIds.contains(p.id)) {
          _favouritedIds.add(p.id);
          final exists = _savedItems.any((item) => item['id'] == p.id);
          if (!exists) {
            _savedItems.add(_propertyToItemMap(p));
          } else {
            final idx = _savedItems.indexWhere((item) => item['id'] == p.id);
            if (idx != -1) {
              _savedItems[idx] = _propertyToItemMap(p);
            }
          }
        }
      }

      // Update fresh details for properties currently favorited
      for (int i = 0; i < _savedItems.length; i++) {
        final id = _savedItems[i]['id'];
        for (final p in allProps) {
          if (p.id == id) {
            _savedItems[i] = _propertyToItemMap(p);
            break;
          }
        }
      }

      // Recover details for any locally favorited mock properties or cached public properties
      for (final id in _favouritedIds) {
        final exists = _savedItems.any((item) => item['id'] == id);
        if (!exists) {
          PropertyModel? found;
          if (CacheService.isInitialized) {
            final cached = CacheService.instance.getJsonList(CacheService.keyPropertiesPublic);
            if (cached != null) {
              for (final json in cached) {
                try {
                  final p = PropertyModel.fromJson(json);
                  if (p.id == id) {
                    found = p;
                    break;
                  }
                } catch (_) {}
              }
            }
          }
          found ??= fallbackMockProperties.where((p) => p.id == id).firstOrNull;
          if (found != null) {
            _savedItems.add(_propertyToItemMap(found));
          } else if (CacheService.isInitialized) {
            JobModel? foundJob;
            final cachedJobs = CacheService.instance.getJsonList(CacheService.keyJobsPublic);
            if (cachedJobs != null) {
              for (final json in cachedJobs) {
                try {
                  final j = JobModel.fromJson(json);
                  if (j.id == id) {
                    foundJob = j;
                    break;
                  }
                } catch (_) {}
              }
            }
            if (foundJob == null) {
              final cachedUserJobs = CacheService.instance.getJsonList(CacheService.keyJobsUser);
              if (cachedUserJobs != null) {
                for (final json in cachedUserJobs) {
                  try {
                    final j = JobModel.fromJson(json);
                    if (j.id == id) {
                      foundJob = j;
                      break;
                    }
                  } catch (_) {}
                }
              }
            }
            if (foundJob != null) {
              _savedItems.add(_jobToItemMap(foundJob));
            }
          }
        }
      }

      // Fetch public product ads and load saved ones
      if (_productAdRepository != null) {
        try {
          final res = await _productAdRepository.getPublicProductAds(
            page: 1,
            limit: 50,
          );
          final List<MarketplaceItemModel> prods =
              (res['data'] as List?)?.cast<MarketplaceItemModel>() ?? [];

          for (final prod in prods) {
            if (prod.isSaved || _favouritedIds.contains(prod.id)) {
              _favouritedIds.add(prod.id);
              final exists = _savedItems.any((item) => item['id'] == prod.id);
              if (!exists) {
                _savedItems.add(_productToItemMap(prod));
              } else {
                final idx =
                    _savedItems.indexWhere((item) => item['id'] == prod.id);
                if (idx != -1) {
                  _savedItems[idx] = _productToItemMap(prod);
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching favourite product ads: $e');
        }
      }

      await _savePersistedFavourites();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching favourites: $e');
    } finally {
      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavourite(String id) async {
    final isCurrentlyLiked = _favouritedIds.contains(id);

    // Optimistic UI update
    if (isCurrentlyLiked) {
      _favouritedIds.remove(id);
      final idx = _savedItems.indexWhere((item) => item['id'] == id);
      if (idx != -1) {
        _lastRemovedItem = _savedItems[idx];
        _savedItems.removeAt(idx);
      }
    } else {
      _favouritedIds.add(id);
      if (_lastRemovedItem != null && _lastRemovedItem!['id'] == id) {
        _savedItems.add(_lastRemovedItem!);
        _lastRemovedItem = null;
      } else {
        PropertyModel? found;
        if (CacheService.isInitialized) {
          final cached = CacheService.instance.getJsonList(CacheService.keyPropertiesPublic);
          if (cached != null) {
            for (final json in cached) {
              try {
                final p = PropertyModel.fromJson(json);
                if (p.id == id) {
                  found = p;
                  break;
                }
              } catch (_) {}
            }
          }
        }
        found ??= fallbackMockProperties.where((p) => p.id == id).firstOrNull;
        if (found != null) {
          _savedItems.add(_propertyToItemMap(found));
        } else if (CacheService.isInitialized) {
          JobModel? foundJob;
          final cachedJobs = CacheService.instance.getJsonList(CacheService.keyJobsPublic);
          if (cachedJobs != null) {
            for (final json in cachedJobs) {
              try {
                final j = JobModel.fromJson(json);
                if (j.id == id) {
                  foundJob = j;
                  break;
                }
              } catch (_) {}
            }
          }
          if (foundJob == null) {
            final cachedUserJobs = CacheService.instance.getJsonList(CacheService.keyJobsUser);
            if (cachedUserJobs != null) {
              for (final json in cachedUserJobs) {
                try {
                  final j = JobModel.fromJson(json);
                  if (j.id == id) {
                    foundJob = j;
                    break;
                  }
                } catch (_) {}
              }
            }
          }
          if (foundJob != null) {
            _savedItems.add(_jobToItemMap(foundJob));
          }
        }
      }
    }
    _savePersistedFavourites();
    notifyListeners();

    final targetItem = _savedItems.firstWhere(
      (item) => item['id'] == id,
      orElse: () => _lastRemovedItem ?? {},
    );
    final isProduct = targetItem['category'] == 'Ads' ||
        targetItem['productModel'] != null;
    final isJob = targetItem['category'] == 'Job' ||
        targetItem['jobModel'] != null;

    if (isJob) {
      // Jobs are saved locally via key_bookmarked_job_ids / cache
      return;
    }

    try {
      if (isProduct && _productAdRepository != null) {
        if (isCurrentlyLiked) {
          await _productAdRepository.unsaveAd(id);
        } else {
          await _productAdRepository.saveAd(id);
        }
      } else {
        if (isCurrentlyLiked) {
          await _propertyRepository.unlikeProperty(id);
        } else {
          await _propertyRepository.likeProperty(id);
        }
      }
    } catch (e) {
      debugPrint('Error toggling favourite on backend (continuing with local state): $e');
      // Do not revert local state on mock items or server 500 errors
    }
  }

  bool isFavourited(String id) => _favouritedIds.contains(id);

  List<Map<String, dynamic>> get filteredItems {
    return _savedItems.where((item) {
      if (!_favouritedIds.contains(item['id'])) return false;
      if (_selectedCategory == 'All') return true;

      final cat = (item['category'] as String?)?.toLowerCase() ?? '';
      switch (_selectedCategory) {
        case 'Jobs':
          return cat == 'job';
        case 'Rooms':
          return cat == 'room' ||
              cat == 'apartment' ||
              cat == 'house' ||
              cat == 'studio' ||
              cat == 'shared';
        case 'Ads':
          return cat == 'ads' || cat == 'ad';
        case 'Workers':
          return cat == 'worker';
        default:
          return true;
      }
    }).toList();
  }
}
