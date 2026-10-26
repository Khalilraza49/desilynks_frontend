import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/banner_ad_model.dart';
import '../../repositories/banner_ad_repository.dart';

class DealItem {
  final String id;
  final String title;
  final String rating;
  final String views;
  final String discountTag;
  final Color tagBgColor;
  final String imageUrl;
  final String category;
  final BannerAdModel? bannerAd;
  final String? storeName;
  final String? destinationLink;
  final String? description;
  final String? validUntil;

  const DealItem({
    required this.id,
    required this.title,
    required this.rating,
    required this.views,
    required this.discountTag,
    required this.tagBgColor,
    required this.imageUrl,
    required this.category,
    this.bannerAd,
    this.storeName,
    this.destinationLink,
    this.description,
    this.validUntil,
  });
}

class DealsDiscountsViewModel extends ChangeNotifier {
  final BannerAdRepository? _repository;

  final TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _hasShownComingSoon = false;
  bool get hasShownComingSoon => _hasShownComingSoon;

  void markComingSoonShown() {
    _hasShownComingSoon = true;
  }

  final List<String> categories = const [
    'All',
    'Restaurants',
    'Travel',
    'Shopping',
    'Services',
  ];

  static const List<DealItem> _defaultDeals = [
    DealItem(
      id: 'd1',
      title: '20% OFF at Spain Village Vintage Restaurant',
      rating: '4.8',
      views: '3.4K views',
      discountTag: '20% OFF',
      tagBgColor: Color(0xFFEF4444),
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=400',
      category: 'Restaurants',
      storeName: 'Spain Village Vintage Restaurant',
      description:
          'Get 20% off on all dishes at Spain Village Vintage Restaurant. Valid for dine-in and takeaway.',
    ),
    DealItem(
      id: 'd2',
      title: '15% OFF at Travel World',
      rating: '4.7',
      views: '2.1K views',
      discountTag: '15% OFF',
      tagBgColor: Color(0xFF4F46E5),
      imageUrl:
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&q=80&w=400',
      category: 'Travel',
      storeName: 'Travel World Spain',
      description:
          'Enjoy 15% discount on travel packages across Spain and Europe.',
    ),
    DealItem(
      id: 'd3',
      title: '10% OFF at Super Store',
      rating: '4.5',
      views: '1.8K views',
      discountTag: '10% OFF',
      tagBgColor: Color(0xFF10B981),
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      category: 'Shopping',
      storeName: 'Desi Super Store',
      description:
          'Get 10% off on all authentic South Asian groceries and spices.',
    ),
  ];

  List<BannerAdModel> _publicBanners = [];
  List<BannerAdModel> get publicBanners => _publicBanners;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Timer? _debounce;

  DealsDiscountsViewModel([this._repository]) {
    searchController.addListener(_onSearchChanged);
    fetchPublicBanners();
  }

  void _onSearchChanged() {
    final text = searchController.text;
    if (_searchQuery == text) return;
    _searchQuery = text;
    notifyListeners();

    // Debounce API calls — wait 500ms after user stops typing
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(text);
    });
  }

  void submitSearch(String query) {
    _debounce?.cancel();
    _searchQuery = query;
    notifyListeners();
    _performSearch(query);
  }

  Future<void> refresh() async {
    await _performSearch(_searchQuery);
  }

  Future<void> _performSearch(String query) async {
    if (_repository == null) return;

    _isSearching = true;
    notifyListeners();

    try {
      final res = await _repository.getPublicBannerAds(
        limit: 50,
        search: query.trim().isEmpty ? null : query.trim(),
      );
      _publicBanners = res['data'] as List<BannerAdModel>;
    } catch (e) {
      debugPrint('DealsDiscountsViewModel: search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> fetchPublicBanners() async {
    if (_repository == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _repository.getPublicBannerAds(limit: 50);
      _publicBanners = res['data'] as List<BannerAdModel>;
    } catch (e) {
      debugPrint('DealsDiscountsViewModel: fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void recordView(String id) {
    _repository?.recordView(id);
  }

  void recordClick(String id) {
    _repository?.recordClick(id);
  }

  List<DealItem> get deals {
    final List<DealItem> items = [];

    // Convert live public banner ads into DealItems
    for (final b in _publicBanners) {
      String validDate = '7 Days';
      if (b.expiresAt != null) {
        final d = b.expiresAt!;
        validDate = '${d.day} ${_monthName(d.month)} ${d.year}';
      }

      items.add(
        DealItem(
          id: b.id,
          title: b.title,
          rating: '4.9',
          views: '${b.views} views',
          discountTag: b.ctaButtonText.isNotEmpty ? b.ctaButtonText : 'PROMO',
          tagBgColor: const Color(0xFF2563EB),
          imageUrl: b.photoUrl.isNotEmpty
              ? b.photoUrl
              : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=400',
          category: b.position.label,
          bannerAd: b,
          storeName: b.creator != null && b.creator!.fullName.isNotEmpty
              ? b.creator!.fullName
              : b.title,
          destinationLink: b.destinationLink,
          description: b.description,
          validUntil: validDate,
        ),
      );
    }

    // Append default deals so the view is always vibrant
    items.addAll(_defaultDeals);
    return items;
  }

  List<DealItem> get filteredDeals {
    return deals.where((deal) {
      final matchesCategory = _selectedCategory == 'All' ||
          deal.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      if (!matchesCategory) return false;

      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;

      // If item is returned directly from the backend search API, keep it
      if (deal.bannerAd != null) return true;

      // Local matching for default items
      return deal.title.toLowerCase().contains(q) ||
          (deal.storeName?.toLowerCase().contains(q) ?? false) ||
          (deal.description?.toLowerCase().contains(q) ?? false) ||
          deal.discountTag.toLowerCase().contains(q);
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _debounce?.cancel();
    notifyListeners();
    // Re-fetch all banners without search filter
    fetchPublicBanners();
  }

  String _monthName(int month) {
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
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
