import 'package:flutter/material.dart';
import '../../models/category_item.dart';
import '../../repositories/categories_repository.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repo;

  CategoriesViewModel(this._repo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CategoryItem> _businessCategories = [];
  List<CategoryItem> _jobCategories = [];
  List<CategoryItem> _needWorkerTypes = [];
  List<CategoryItem> _propertyFeatures = [];

  List<CategoryItem> get businessCategories => _businessCategories;
  List<CategoryItem> get jobCategories => _jobCategories;
  List<CategoryItem> get needWorkerTypes => _needWorkerTypes;
  List<CategoryItem> get propertyFeatures => _propertyFeatures;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  /// Fetches all four category lists in parallel with individual error resilience.
  /// Safe to call multiple times — skips if data is already loaded unless [force] is true.
  Future<void> fetchAll({bool force = false}) async {
    if ((!force && _hasFetched) || _isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final businessFuture = _repo.fetchBusinessCategories().catchError((e) {
        debugPrint('fetchBusinessCategories error: $e');
        return _businessCategories;
      });
      final jobFuture = _repo.fetchJobCategories().catchError((e) {
        debugPrint('fetchJobCategories error: $e');
        return _jobCategories;
      });
      final needWorkerFuture = _repo.fetchNeedWorkerTypes().catchError((e) {
        debugPrint('fetchNeedWorkerTypes error: $e');
        return _needWorkerTypes;
      });
      final propertyFuture = _repo.fetchPropertyFeatures().catchError((e) {
        debugPrint('fetchPropertyFeatures error: $e');
        return _propertyFeatures;
      });

      final results = await Future.wait([
        businessFuture,
        jobFuture,
        needWorkerFuture,
        propertyFuture,
      ]);

      _businessCategories = results[0];
      _jobCategories = results[1];
      _needWorkerTypes = results[2];
      _propertyFeatures = results[3];
      _hasFetched = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('CategoriesViewModel.fetchAll error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBusinessCategories() async {
    try {
      _businessCategories = await _repo.fetchBusinessCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchBusinessCategories error: $e');
    }
  }

  Future<void> fetchJobCategories() async {
    try {
      _jobCategories = await _repo.fetchJobCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchJobCategories error: $e');
    }
  }

  Future<void> fetchNeedWorkerTypes() async {
    try {
      _needWorkerTypes = await _repo.fetchNeedWorkerTypes();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchNeedWorkerTypes error: $e');
    }
  }

  Future<void> fetchPropertyFeatures() async {
    try {
      _propertyFeatures = await _repo.fetchPropertyFeatures();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchPropertyFeatures error: $e');
    }
  }

  CategoryItem? findBusinessCategoryById(String? id) {
    if (id == null) return null;
    return _businessCategories.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  CategoryItem? findJobCategoryById(String? id) {
    if (id == null) return null;
    return _jobCategories.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  CategoryItem? findNeedWorkerTypeById(String? id) {
    if (id == null) return null;
    return _needWorkerTypes.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  CategoryItem? findPropertyFeatureById(String? id) {
    if (id == null) return null;
    return _propertyFeatures.cast<CategoryItem?>().firstWhere(
      (c) => c?.id == id,
      orElse: () => null,
    );
  }

  /// Finds a CategoryItem in [needWorkerTypes] matching the given title or profession.
  CategoryItem? findNeedWorkerTypeByTitle(String? title) {
    if (title == null || title.trim().isEmpty) return null;
    final normalized = title.trim().toLowerCase();
    return _needWorkerTypes.cast<CategoryItem?>().firstWhere(
      (c) => c != null && c.title.trim().toLowerCase() == normalized,
      orElse: () => null,
    );
  }

  /// Resolves the admin workerTypeId UUID for the given profession or service.
  /// Matches case-insensitively, then substring, and falls back to first admin worker type.
  String? findWorkerTypeId(String? titleOrProfession) {
    if (_needWorkerTypes.isEmpty) return null;

    final exactMatch = findNeedWorkerTypeByTitle(titleOrProfession);
    if (exactMatch != null && exactMatch.id.isNotEmpty) {
      return exactMatch.id;
    }

    if (titleOrProfession != null && titleOrProfession.trim().isNotEmpty) {
      final norm = titleOrProfession.trim().toLowerCase();
      for (final item in _needWorkerTypes) {
        final t = item.title.trim().toLowerCase();
        if (t.contains(norm) || norm.contains(t)) {
          return item.id;
        }
      }
    }

    return _needWorkerTypes.first.id;
  }

  /// Ensures need worker types are loaded, fetching them if currently empty.
  Future<List<CategoryItem>> ensureNeedWorkerTypes() async {
    if (_needWorkerTypes.isEmpty) {
      await fetchNeedWorkerTypes();
    }
    return _needWorkerTypes;
  }
}
