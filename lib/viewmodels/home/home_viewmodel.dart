import 'dart:async';
import 'dart:convert';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../models/banner_ad_model.dart';
import '../../models/marketplace_item_model.dart';
import '../../models/job_model.dart';
import '../../models/job_enums.dart';
import '../../models/worker_profile_model.dart';
import '../../models/explore_country_model.dart';
import '../../repositories/property_repository.dart';
import '../../repositories/job_repository.dart';
import '../../repositories/worker_repository.dart';
import '../../repositories/product_ad_repository.dart';
import '../../repositories/banner_ad_repository.dart';
import '../../repositories/explore_country_repository.dart';
import '../../services/api/api_service.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/local/cache_service.dart';

class HomeViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final JobRepository? _jobRepository;
  final WorkerRepository? _workerRepository;
  final ProductAdRepository? _productAdRepository;
  final ApiService? _apiService;
  final BannerAdRepository? _bannerAdRepository;
  final ExploreCountryRepository? _exploreCountryRepository;

  HomeViewModel(
    this._propertyRepository, {
    JobRepository? jobRepository,
    WorkerRepository? workerRepository,
    ProductAdRepository? productAdRepository,
    ApiService? apiService,
    BannerAdRepository? bannerAdRepository,
    ExploreCountryRepository? exploreCountryRepository,
  })  : _jobRepository = jobRepository,
        _workerRepository = workerRepository,
        _productAdRepository = productAdRepository,
        _apiService = apiService,
        _bannerAdRepository = bannerAdRepository,
        _exploreCountryRepository = exploreCountryRepository {
    _hydrateRoomsFromCache();
    _hydrateMarketplaceAdsFromCache();
    _hydrateJobsFromCache();
    _hydrateWorkersFromCache();
    fetchHomeData();
  }

  void _hydrateMarketplaceAdsFromCache() {
    try {
      final cached =
          CacheService.instance.getJsonList(CacheService.keyMarketplacePublic);
      if (cached != null && cached.isNotEmpty) {
        _marketplaceAds = cached
            .map((j) => MarketplaceItemModel.fromJson(j))
            .where((item) =>
                item.status.toUpperCase() == 'ACTIVE' ||
                item.status.toUpperCase() == 'PUBLISHED')
            .toList();
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error hydrating marketplace ads: $e');
    }
  }

  void _hydrateRoomsFromCache() {
    try {
      final cached =
          CacheService.instance.getJsonList(CacheService.keyPropertiesPublic);
      if (cached != null && cached.isNotEmpty) {
        _apiRooms = cached
            .map((j) => PropertyModel.fromJson(j))
            .where((p) =>
                p.status.toUpperCase() == 'PUBLISHED' ||
                p.status.toUpperCase() == 'ACTIVE')
            .take(5)
            .toList();
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error hydrating rooms: $e');
    }
  }

  void _hydrateJobsFromCache() {
    try {
      final cached =
          CacheService.instance.getJsonList(CacheService.keyJobsPublic);
      if (cached != null && cached.isNotEmpty) {
        _apiJobs = cached
            .map((j) => JobModel.fromJson(j))
            .where((j) => j.status == JobStatus.open)
            .take(5)
            .toList();
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error hydrating jobs: $e');
    }
  }

  void _hydrateWorkersFromCache() {
    try {
      final cached =
          CacheService.instance.getJsonList(CacheService.keyWorkersPublic);
      if (cached != null && cached.isNotEmpty) {
        _apiWorkers = cached
            .map((w) => WorkerProfileModel.fromJson(w))
            .take(6)
            .toList();
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error hydrating workers: $e');
    }
  }

  String _selectedCity = 'All Cities';

  String get selectedCity => _selectedCity;

  void selectCity(String city) {
    if (_selectedCity != city) {
      _selectedCity = city;
      notifyListeners();
    }
  }

  // ─── Banners & Promos (Derived from Live Banner Ads) ──────────────────────
  List<Map<String, dynamic>> get bannerPromos {
    if (_homeBanners.isNotEmpty) {
      return _homeBanners.map((b) => {
        'id': b.id,
        'title': b.title,
        'subtitle': b.description,
        'buttonText': b.ctaButtonText.isNotEmpty ? b.ctaButtonText : 'Explore',
        'color': b.position.iconColor,
        'imageUrl': b.photoUrl,
        'destinationLink': b.destinationLink,
        'bannerAd': b,
      }).toList();
    }
    return [];
  }

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Jobs',
      'icon': AppIcons.briefcaseSvg,
      'iconColor': AppColors.primaryBlue,
      'bgColor': AppColors.lightBlue,
    },
    {
      'label': 'Rooms',
      'icon': AppIcons.roomSvg,
      'iconColor': AppColors.orangeAccent,
      'bgColor': AppColors.lightOrange,
    },
    {
      'label': 'Workers',
      'icon': AppIcons.workerSvg,
      'iconColor': AppColors.successGreen,
      'bgColor': AppColors.lightGreen,
    },
    {
      'label': 'Marketplace',
      'icon': AppIcons.marketplaceSvg,
      'iconColor': AppColors.primaryPurple,
      'bgColor': AppColors.lightPurple,
    },
    {
      'label': 'Cities',
      'icon': AppIcons.locationSvg,
      'iconColor': AppColors.primaryRed,
      'bgColor': AppColors.softRed,
    },
  ];

  List<Map<String, dynamic>> get categories => _categories;

  // Cities (Dynamic with fallback)
  List<String> get cities {
    final list = <String>['All Cities'];
    if (_exploreCities.isNotEmpty) {
      for (final c in _exploreCities) {
        final name = c['name'] as String? ?? '';
        if (name.isNotEmpty && !list.contains(name)) {
          list.add(name);
        }
      }
    } else {
      list.addAll(['Barcelona', 'Madrid', 'Valencia']);
    }
    return list;
  }

  // Listings (Derived from live marketplace ads)
  List<Map<String, dynamic>> get listings => filteredListings;

  List<Map<String, dynamic>> get filteredListings {
    if (topMarketplaceAds.isNotEmpty) {
      return topMarketplaceAds.map((item) {
        final photoUrl = item.photos.isNotEmpty
            ? item.photos.first.url
            : (item.photoUrls.isNotEmpty ? item.photoUrls.first : item.imageUrl);
        return {
          'id': item.id,
          'title': item.title,
          'category': item.category.isNotEmpty ? item.category : 'Marketplace',
          'location': item.location.isNotEmpty ? item.location : 'Spain',
          'rating': item.sellerRating > 0
              ? '${item.sellerRating.toStringAsFixed(1)} (${item.sellerReviewCount})'
              : '4.8 (36)',
          'price': item.price.startsWith('€') ? item.price : '€${item.price}',
          'tag': item.condition?.isNotEmpty == true
              ? item.condition!
              : (item.isNegotiable ? 'Negotiable' : 'Fixed Price'),
          'imageUrl': photoUrl,
          'isGolden': item.isGolden,
        };
      }).toList();
    }
    return [];
  }

  // Quick Actions
  final List<Map<String, dynamic>> _quickActions = [
    {
      'label': 'Hire Workers',
      'icon': AppIcons.workerSvg,
      'iconColor': AppColors.primaryBlue,
      'bgColor': AppColors.lightBlue,
    },
    {
      'label': 'Find Job',
      'icon': AppIcons.briefcaseSvg,
      'iconColor': AppColors.emerald,
      'bgColor': AppColors.lightGreen,
    },
    {
      'label': 'Find Room',
      'icon': AppIcons.roomSvg,
      'iconColor': AppColors.orange,
      'bgColor': AppColors.lightOrange,
    },
    {
      'label': 'Buy & Sell',
      'icon': AppIcons.shopSvg,
      'iconColor': AppColors.primaryPurple,
      'bgColor': AppColors.lightPurple,
    },
    {
      'label': 'Need Delivery',
      'icon': AppIcons.bikeSvg,
      'iconColor': AppColors.amberOrange,
      'bgColor': AppColors.lightYellow,
    },
    {
      'label': 'Need Cleaner',
      'icon': AppIcons.brushSvg,
      'iconColor': AppColors.green600,
      'bgColor': AppColors.softGreen,
    },
    {
      'label': 'Need Driver',
      'icon': AppIcons.carSvg,
      'iconColor': AppColors.primaryRed,
      'bgColor': AppColors.softRed,
    },
    {
      'label': 'More',
      'icon': AppIcons.moreVerticalSvg,
      'iconColor': AppColors.slate500,
      'bgColor': AppColors.slate100,
    },
  ];

  List<Map<String, dynamic>> get quickActions => _quickActions;

  // Revenue Promotions
  final List<Map<String, dynamic>> _revPromos = [
    {
      'label': 'Business Promote',
      'icon': AppIcons.shopSvg,
      'iconColor': AppColors.primaryBlue,
      'bgColor': AppColors.lightBlue,
    },
    {
      'label': 'Boost Listing',
      'icon': AppIcons.boostRocketSvg,
      'iconColor': AppColors.primaryPurple,
      'bgColor': AppColors.lightPurple,
    },
    {
      'label': 'Banner Ads',
      'icon': AppIcons.gallerySvg,
      'iconColor': AppColors.amberOrange,
      'bgColor': AppColors.lightYellow,
    },
    {
      'label': 'Spotlight',
      'icon': AppIcons.starFavoriteSvg,
      'iconColor': AppColors.orange,
      'bgColor': AppColors.lightOrange,
    },
  ];

  List<Map<String, dynamic>> get revPromos => _revPromos;

  // ─── Spotlight Users (Live Workers) ─────────────────────────────────────────
  List<WorkerProfileModel> _apiWorkers = [];
  bool _isLoadingWorkers = false;
  List<WorkerProfileModel> get apiWorkers => _apiWorkers;
  bool get isLoadingWorkers => _isLoadingWorkers;

  List<Map<String, dynamic>> get spotlightUsers {
    return _apiWorkers.map((w) {
      final photo = (w.profilePhotoUrl != null && w.profilePhotoUrl!.isNotEmpty)
          ? w.profilePhotoUrl!
          : (w.workPhotoItems.isNotEmpty ? w.workPhotoItems.first.url : '');
      return {
        'id': w.id,
        'name': w.name,
        'role': w.profession.isNotEmpty ? w.profession : 'Worker',
        'imageUrl': photo,
        'worker': w,
      };
    }).toList();
  }

  Future<void> fetchWorkers() async {
    final repo = _workerRepository;
    if (repo == null) return;
    _isLoadingWorkers = true;
    notifyListeners();
    try {
      final res = await repo.getPublicWorkerProfiles(page: 1, limit: 6);
      _apiWorkers = res;
      if (_apiWorkers.isNotEmpty) {
        CacheService.instance.saveJsonList(
          CacheService.keyWorkersPublic,
          _apiWorkers.take(20).map((w) => w.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching workers: $e');
    } finally {
      _isLoadingWorkers = false;
      notifyListeners();
    }
  }

  // ─── Featured Jobs (Live Jobs) ──────────────────────────────────────────────
  List<JobModel> _apiJobs = [];
  bool _isLoadingJobs = false;
  List<JobModel> get apiJobs => _apiJobs;
  bool get isLoadingJobs => _isLoadingJobs;

  List<Map<String, dynamic>> get jobs {
    final activeJobs = _apiJobs
        .where((j) => j.status == JobStatus.open)
        .toList();

    return activeJobs.map((j) {
      final salaryStr = j.salary.isNotEmpty && j.salary != '0' && j.salary != '0.00'
          ? (j.salary.startsWith('€') ? j.salary : '€${j.salary}/${j.salaryPeriod.displayName}')
          : 'Negotiable';
      return {
        'id': j.id,
        'title': j.title,
        'company': j.companyName.isNotEmpty ? j.companyName : 'Company',
        'location': j.location.isNotEmpty ? j.location : 'Spain',
        'type': j.type.displayName,
        'salary': salaryStr,
        'isSponsored': false,
        'imageUrl': j.posterUrl ?? (j.employer?.profilePhotoUrl ?? ''),
        'typeColor': AppColors.lightBlue,
        'typeTextColor': AppColors.primaryBlue,
        'job': j,
      };
    }).toList();
  }

  Future<void> fetchJobs() async {
    final repo = _jobRepository;
    if (repo == null) return;
    _isLoadingJobs = true;
    notifyListeners();
    try {
      final res = await repo.getPublicJobs(page: 1, limit: 5);
      final rawJobs = res['jobs'] as List<JobModel>? ?? [];
      _apiJobs = rawJobs
          .where((j) => j.status == JobStatus.open)
          .take(5)
          .toList();
      if (_apiJobs.isNotEmpty) {
        CacheService.instance.saveJsonList(
          CacheService.keyJobsPublic,
          _apiJobs.map((j) => j.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching jobs: $e');
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  // ─── Rooms for Rent (Live Properties) ──────────────────────────────────────
  List<PropertyModel> _apiRooms = [];
  bool _isLoadingRooms = false;
  List<PropertyModel> get apiRooms => _apiRooms;
  bool get isLoadingRooms => _isLoadingRooms;

  List<Map<String, dynamic>> get rooms {
    final activeRooms = _apiRooms
        .where(
          (p) =>
              p.status.toUpperCase() == 'PUBLISHED' ||
              p.status.toUpperCase() == 'ACTIVE',
        )
        .toList();
    if (activeRooms.isNotEmpty) {
      return activeRooms
          .map(
            (p) => {
              'id': p.id,
              'title': p.title,
              'location': p.location,
              'price':
                  '€${double.tryParse(p.monthlyRent)?.toStringAsFixed(0) ?? p.monthlyRent}/month',
              'specs':
                  '${p.noOfBedRooms} Bed  |  ${p.noOfBathRooms} Bath${p.featuresAndAmenities.isNotEmpty ? "  |  ${p.featuresAndAmenities.take(2).join(' & ')}" : ""}',
              'imageUrl': p.propertyPhotos.isNotEmpty
                  ? p.propertyPhotos.first.url
                  : '',
              'property': p,
            },
          )
          .toList();
    }
    return [];
  }

  Future<void> fetchRooms() async {
    _isLoadingRooms = true;
    notifyListeners();
    try {
      final res = await _propertyRepository.getProperties(limit: 5);
      final rawRooms = res['properties'] as List<PropertyModel>;
      _apiRooms = rawRooms
          .where(
            (p) =>
                p.status.toUpperCase() == 'PUBLISHED' ||
                p.status.toUpperCase() == 'ACTIVE',
          )
          .toList();
      if (_apiRooms.isNotEmpty) {
        CacheService.instance.saveJsonList(
          CacheService.keyPropertiesPublic,
          _apiRooms.map((p) => p.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching rooms: $e');
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  // ─── API-backed Postings Stats ─────────────────────────────────────────────
  bool _isInitialLoading = true;
  int _jobsCount = 0;
  int _roomsCount = 0;
  int _workersCount = 0;
  int _dealsCount = 0;
  bool _isLoadingStats = false;

  bool get isInitialLoading => _isInitialLoading;
  int get jobsCount => _jobsCount;
  int get roomsCount => _roomsCount;
  int get workersCount => _workersCount;
  int get dealsCount => _dealsCount;
  int get totalPostings =>
      _jobsCount + _roomsCount + _workersCount + _dealsCount;
  bool get isLoadingStats => _isLoadingStats;

  void setInitialLoading(bool loading) {
    if (_isInitialLoading != loading) {
      _isInitialLoading = loading;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      final futures = <Future<void>>[];

      // 1. Rooms/Properties total from API
      futures.add(() async {
        try {
          final res = await _propertyRepository.getProperties(
            page: 1,
            limit: 1,
          );
          if (res['meta'] is Map && res['meta']['total'] != null) {
            _roomsCount = (res['meta']['total'] as num).toInt();
          } else if (res['properties'] is List &&
              (res['properties'] as List).isNotEmpty) {
            _roomsCount = (res['properties'] as List).length;
          }
        } catch (e) {
          debugPrint('HomeViewModel: Error fetching property count: $e');
        }
      }());

      // 2. Jobs total from API
      final jobRepo = _jobRepository;
      if (jobRepo != null) {
        futures.add(() async {
          try {
            final res = await jobRepo.getPublicJobs(page: 1, limit: 1);
            if (res['meta'] is Map && res['meta']['total'] != null) {
              _jobsCount = (res['meta']['total'] as num).toInt();
            } else if (res['jobs'] is List &&
                (res['jobs'] as List).isNotEmpty) {
              _jobsCount = (res['jobs'] as List).length;
            }
          } catch (e) {
            debugPrint('HomeViewModel: Error fetching jobs count: $e');
          }
        }());
      }

      // 3. Workers total from API
      final workerRepo = _workerRepository;
      final api = _apiService;
      if (workerRepo != null) {
        futures.add(() async {
          try {
            if (api != null) {
              final res = await api.get(
                '${ApiEndpoints.workerProfileEndpoint}?page=1&limit=1',
              );
              final Map<String, dynamic> body = jsonDecode(res.body);
              if (body['meta'] is Map && body['meta']['total'] != null) {
                _workersCount = (body['meta']['total'] as num).toInt();
              } else if (body['data'] is List) {
                _workersCount = (body['data'] as List).length;
              }
            } else {
              final workers = await workerRepo.getPublicWorkerProfiles(
                page: 1,
                limit: 1,
              );
              if (workers.isNotEmpty) {
                _workersCount = workers.length;
              }
            }
          } catch (e) {
            debugPrint('HomeViewModel: Error fetching worker count: $e');
          }
        }());
      }

      // 4. Deals / Product Ads total from API
      final productAdRepo = _productAdRepository;
      if (productAdRepo != null) {
        futures.add(() async {
          try {
            final res = await productAdRepo.getPublicProductAds(
              page: 1,
              limit: 1,
            );
            if (res['meta'] is Map && res['meta']['total'] != null) {
              _dealsCount = (res['meta']['total'] as num).toInt();
            } else if (res['ads'] is List && (res['ads'] as List).isNotEmpty) {
              _dealsCount = (res['ads'] as List).length;
            }
          } catch (e) {
            debugPrint('HomeViewModel: Error fetching deals count: $e');
          }
        }());
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching stats: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // ─── Marketplace Top Ads ───────────────────────────────────────────────────
  List<MarketplaceItemModel> _marketplaceAds = [];
  bool _isLoadingMarketplaceAds = false;

  bool get isLoadingMarketplaceAds => _isLoadingMarketplaceAds;
  List<MarketplaceItemModel> get marketplaceAds => _marketplaceAds;

  List<MarketplaceItemModel> get topMarketplaceAds {
    final active = _marketplaceAds
        .where((item) =>
            item.status.toUpperCase() == 'ACTIVE' ||
            item.status.toUpperCase() == 'PUBLISHED')
        .toList();

    if (_selectedCity == 'All Cities') {
      return active.take(3).toList();
    }
    final filtered = active
        .where((item) =>
            item.location.toLowerCase().contains(_selectedCity.toLowerCase()))
        .toList();
    return (filtered.isNotEmpty ? filtered : active).take(3).toList();
  }

  Future<void> fetchMarketplaceAds() async {
    final repo = _productAdRepository;
    if (repo == null) return;
    _isLoadingMarketplaceAds = true;
    notifyListeners();
    try {
      final res = await repo.getPublicProductAds(page: 1, limit: 10);
      final rawItems = res['data'] as List<MarketplaceItemModel>? ?? [];
      _marketplaceAds = rawItems
          .where((item) =>
              item.status.toUpperCase() == 'ACTIVE' ||
              item.status.toUpperCase() == 'PUBLISHED')
          .toList();
      if (_marketplaceAds.isNotEmpty) {
        CacheService.instance.saveJsonList(
          CacheService.keyMarketplacePublic,
          _marketplaceAds.take(30).map((i) => i.toJson()).toList(),
        );
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching marketplace ads: $e');
    } finally {
      _isLoadingMarketplaceAds = false;
      notifyListeners();
    }
  }

  // ─── Home Banners (Live API) ────────────────────────────────────────────────
  List<BannerAdModel> _homeBanners = [];
  List<BannerAdModel> get homeBanners => _homeBanners;
  bool _isLoadingHomeBanners = false;
  bool get isLoadingHomeBanners => _isLoadingHomeBanners;

  Future<void> fetchHomeBanners() async {
    if (_bannerAdRepository == null) return;
    _isLoadingHomeBanners = true;
    notifyListeners();

    try {
      final res = await _bannerAdRepository.getPublicBannerAds(
        position: 'HOME_SCREEN',
        limit: 10,
      );
      _homeBanners = res['data'] as List<BannerAdModel>;
      if (_homeBanners.isEmpty) {
        final allRes = await _bannerAdRepository.getPublicBannerAds(limit: 10);
        _homeBanners = allRes['data'] as List<BannerAdModel>;
      }
    } catch (e) {
      debugPrint('HomeViewModel: error fetching home banners: $e');
    } finally {
      _isLoadingHomeBanners = false;
      notifyListeners();
    }
  }

  void recordBannerView(String id) {
    _bannerAdRepository?.recordView(id);
  }

  void recordBannerClick(String id) {
    _bannerAdRepository?.recordClick(id);
  }

  // ─── Deals & Discounts (Live Banners/Ads) ──────────────────────────────────
  List<Map<String, dynamic>> get deals {
    if (_homeBanners.isNotEmpty) {
      final List<Map<String, dynamic>> list = [];
      for (final b in _homeBanners) {
        list.add({
          'id': b.id,
          'desc': b.title,
          'discount': b.ctaButtonText.isNotEmpty
              ? b.ctaButtonText
              : 'Special Offer',
          'accentColor': AppColors.emerald,
          'svgIcon': AppIcons.shopingSvg,
          'discountTitle': b.title,
          'category': b.position.label,
          'location': 'Spain',
          'imageUrl': b.photoUrl,
          'destinationLink': b.destinationLink,
          'bannerAd': b,
          'detailsText': b.description,
          'validUntil': b.expiresAt != null
              ? '${b.expiresAt!.day}/${b.expiresAt!.month}/${b.expiresAt!.year}'
              : '7 Days',
        });
      }
      return list;
    }
    return [];
  }

  // ─── Explore Spain Cities (Live Explore Countries) ──────────────────────────
  List<Map<String, dynamic>> _exploreCities = [];
  bool _isLoadingExploreCities = false;
  List<Map<String, dynamic>> get exploreCities => _exploreCities;
  bool get isLoadingExploreCities => _isLoadingExploreCities;

  Future<void> fetchExploreCities() async {
    final repo = _exploreCountryRepository;
    if (repo == null) return;
    _isLoadingExploreCities = true;
    notifyListeners();
    try {
      final res = await repo.getCountries(page: 1, limit: 5);
      final List<ExploreCountry> countries = res.data;
      if (countries.isNotEmpty) {
        final spain = countries.firstWhere(
          (c) => c.name.toLowerCase().contains('spain'),
          orElse: () => countries.first,
        );
        if (spain.popularCities.isNotEmpty) {
          _exploreCities = spain.popularCities.map((c) => {
            'id': c.id,
            'name': c.name,
            'desc': spain.name,
            'imageUrl': c.bannerUrl ?? (spain.banner?.fullUrl ?? ''),
            'city': c,
          }).toList();
        } else {
          _exploreCities = countries.map((c) => {
            'id': c.id,
            'name': c.name,
            'desc': c.capital.isNotEmpty ? c.capital : c.name,
            'imageUrl': c.banner?.fullUrl ?? '',
            'country': c,
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('HomeViewModel: Error fetching explore cities: $e');
    } finally {
      _isLoadingExploreCities = false;
      notifyListeners();
    }
  }

  // ─── Master Refresh ────────────────────────────────────────────────────────
  Future<void> fetchHomeData() async {
    try {
      await Future.wait([
        fetchRooms(),
        fetchStats(),
        fetchHomeBanners(),
        fetchMarketplaceAds(),
        fetchJobs(),
        fetchWorkers(),
        fetchExploreCities(),
      ]);
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  // ─── Home Widgets State & Controllers ─────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();

  // Deals
  final PageController dealsPageController = PageController();
  int _dealsIndex = 0;
  int get dealsIndex => _dealsIndex;
  void setDealsIndex(int index) {
    if (_dealsIndex != index) {
      _dealsIndex = index;
      notifyListeners();
    }
  }

  // Featured Listings
  final PageController featuredListingsController = PageController();
  int _featuredListingsIndex = 0;
  int get featuredListingsIndex => _featuredListingsIndex;
  void setFeaturedListingsIndex(int index) {
    if (_featuredListingsIndex != index) {
      _featuredListingsIndex = index;
      notifyListeners();
    }
  }

  // Rooms for Rent
  final PageController roomsPageController = PageController();
  int _roomsIndex = 0;
  int get roomsIndex => _roomsIndex;
  void setRoomsIndex(int index) {
    if (_roomsIndex != index) {
      _roomsIndex = index;
      notifyListeners();
    }
  }

  // Promo Banner
  static const int _loopFactor = 1000;
  static const Duration _autoScrollInterval = Duration(seconds: 4);
  static const Duration _scrollDuration = Duration(milliseconds: 600);

  PageController? _bannerController;
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;

  PageController get bannerController {
    if (_bannerController == null) {
      final banners = bannerPromos;
      final total = banners.length * _loopFactor;
      final initialPage = banners.length <= 1
          ? 0
          : (total ~/ 2) - ((total ~/ 2) % banners.length);
      _bannerController = PageController(initialPage: initialPage);
      startAutoScroll();
    }
    return _bannerController!;
  }

  int get currentBannerIndex => _currentBannerIndex;

  void setBannerIndex(int index) {
    if (_currentBannerIndex != index) {
      _currentBannerIndex = index;
      notifyListeners();
    }
  }

  void startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (bannerPromos.length <= 1) return;

    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (_bannerController == null ||
          !_bannerController!.hasClients ||
          bannerPromos.isEmpty) {
        return;
      }
      _bannerController!.nextPage(
        duration: _scrollDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void dispose() {
    searchController.dispose();
    dealsPageController.dispose();
    featuredListingsController.dispose();
    roomsPageController.dispose();
    _autoScrollTimer?.cancel();
    _bannerController?.dispose();
    super.dispose();
  }
}
