import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/explore_country_model.dart';
import '../../repositories/explore_country_repository.dart';

class ExploreCountryViewModel extends ChangeNotifier {
  final ExploreCountryRepository _repository;

  final TextEditingController searchController = TextEditingController();

  ExploreCountryViewModel(this._repository);

  // ── Countries List State ────────────────────────────────────────────────
  List<ExploreCountry> _countries = [];
  List<ExploreCountry> get countries => _countries;
  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  ExploreCountryPaginationMeta _meta = ExploreCountryPaginationMeta.empty();
  ExploreCountryPaginationMeta get meta => _meta;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Client-side filtered list since the backend strictly rejects any query params other than page & limit
  List<ExploreCountry> get filteredCountries {
    if (_searchQuery.trim().isEmpty) return _countries;
    final q = _searchQuery.trim().toLowerCase();
    return _countries.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.capital.toLowerCase().contains(q) ||
          c.currency.toLowerCase().contains(q) ||
          c.language.toLowerCase().contains(q);
    }).toList();
  }

  // ── Country Detail State ────────────────────────────────────────────────
  ExploreCountry? _selectedCountry;
  ExploreCountry? get selectedCountry => _selectedCountry;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  // ── Search & Filter ─────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    notifyListeners();
  }

  // ── Fetch Countries ─────────────────────────────────────────────────────
  Future<void> fetchCountries({bool refresh = false, bool force = false}) async {
    if ((_hasFetched && !refresh && !force) || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      // Clear data on refresh for clean UI state
      _countries = [];
      _meta = ExploreCountryPaginationMeta.empty();
    }
    notifyListeners();

    try {
      final response = await _repository.getCountries(
        page: 1,
        limit: 10,
      );
      _countries = response.data;
      _meta = response.meta;
      _errorMessage = null;
      developer.log(
        'Fetched ${_countries.length} countries (total: ${_meta.total})',
        name: 'explore_country_viewmodel',
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('HttpException: ', '');
      developer.log(
        'Error fetching countries: $e',
        name: 'explore_country_viewmodel',
        error: e,
      );
    } finally {
      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCountries() async {
    await fetchCountries(refresh: true, force: true);
  }

  // ── Load More Countries (Pagination) ───────────────────────────────────
  Future<void> loadMoreCountries() async {
    if (_isLoadingMore || !_meta.hasNextPage || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _meta.page + 1;
      final response = await _repository.getCountries(
        page: nextPage,
        limit: _meta.limit,
      );

      // Append new unique countries
      final existingIds = _countries.map((c) => c.id).toSet();
      final newItems = response.data.where((c) => !existingIds.contains(c.id)).toList();
      _countries.addAll(newItems);
      _meta = response.meta;

      developer.log(
        'Loaded page $nextPage: added ${newItems.length} countries',
        name: 'explore_country_viewmodel',
      );
    } catch (e) {
      developer.log(
        'Error loading more countries: $e',
        name: 'explore_country_viewmodel',
        error: e,
      );
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Fetch Country Detail ───────────────────────────────────────────────
  Future<ExploreCountry?> fetchCountryDetail(
    String id, {
    ExploreCountry? initialCountry,
  }) async {
    if (initialCountry != null) {
      _selectedCountry = initialCountry;
    }
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      final country = await _repository.getCountryDetail(id);
      _selectedCountry = country;
      _detailErrorMessage = null;
      return country;
    } catch (e) {
      _detailErrorMessage = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('HttpException: ', '');
      developer.log(
        'Error fetching country detail ($id): $e',
        name: 'explore_country_viewmodel',
        error: e,
      );
      return null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearSelectedCountry() {
    _selectedCountry = null;
    _detailErrorMessage = null;
    _isLoadingDetail = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
