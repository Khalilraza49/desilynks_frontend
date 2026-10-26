import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/resource_hub_model.dart';
import '../../repositories/resource_hub_repository.dart';
import '../../services/local/storage_service.dart';
import '../../services/permissions/app_toast.dart';

class ResourceHubViewModel extends ChangeNotifier {
  final ResourceHubRepository _repository;
  final StorageService _storageService;

  ResourceHubViewModel(this._repository, this._storageService);

  // ── Article List State ──────────────────────────────────────────────────
  List<ResourceHubArticle> _articles = [];
  List<ResourceHubArticle> get articles => _articles;

  PaginationMeta _meta = PaginationMeta.empty();
  PaginationMeta get meta => _meta;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Saved Articles State ────────────────────────────────────────────────
  List<ResourceHubArticle> _savedArticles = [];
  List<ResourceHubArticle> get savedArticles => _savedArticles;

  PaginationMeta _savedMeta = PaginationMeta.empty();
  PaginationMeta get savedMeta => _savedMeta;

  bool _isLoadingSaved = false;
  bool get isLoadingSaved => _isLoadingSaved;

  bool _isLoadingMoreSaved = false;
  bool get isLoadingMoreSaved => _isLoadingMoreSaved;

  String? _savedErrorMessage;
  String? get savedErrorMessage => _savedErrorMessage;

  // ── Filters & Search ────────────────────────────────────────────────────
  ResourceHubCategory? _selectedCategory;
  ResourceHubCategory? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _selectedTab = 0; // 0 = Explore, 1 = Saved
  int get selectedTab => _selectedTab;

  Timer? _debounceTimer;

  // ── Controllers & Scroll ──
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool _hasSetupScroll = false;

  void initHub() {
    if (!_hasSetupScroll) {
      _hasSetupScroll = true;
      scrollController.addListener(_onScroll);
    }
    if (_articles.isEmpty) {
      fetchArticles();
    }
    if (isLoggedIn && _savedArticles.isEmpty) {
      fetchSavedArticles();
    }
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (selectedTab == 0) {
        loadMoreArticles();
      } else {
        loadMoreSavedArticles();
      }
    }
  }

  // ── Detail State ────────────────────────────────────────────────────────
  ResourceHubArticle? _currentDetailArticle;
  ResourceHubArticle? get currentDetailArticle => _currentDetailArticle;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  // ── Auth helper ─────────────────────────────────────────────────────────
  bool get isLoggedIn {
    final token = _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Tab Management ──────────────────────────────────────────────────────
  void setSelectedTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();

    if (_selectedTab == 1 && _savedArticles.isEmpty && isLoggedIn) {
      fetchSavedArticles(refresh: true);
    }
  }

  // ── Filter & Search Methods ─────────────────────────────────────────────
  void selectCategory(ResourceHubCategory? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
    fetchArticles(refresh: true);
    if (isLoggedIn && _selectedTab == 1) {
      fetchSavedArticles(refresh: true);
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchArticles(refresh: true);
      if (isLoggedIn && _selectedTab == 1) {
        fetchSavedArticles(refresh: true);
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _debounceTimer?.cancel();
    notifyListeners();
    fetchArticles(refresh: true);
    if (isLoggedIn && _selectedTab == 1) {
      fetchSavedArticles(refresh: true);
    }
  }

  // ── Fetch Public Articles ───────────────────────────────────────────────
  Future<void> fetchArticles({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      _articles = [];
      _meta = PaginationMeta.empty();
    }
    notifyListeners();

    try {
      final response = await _repository.getArticles(
        page: 1,
        limit: 10,
        search: _searchQuery,
        category: _selectedCategory,
      );
      _articles = response.data;
      _meta = response.meta;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || !_meta.hasNextPage) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _meta.page + 1;
      final response = await _repository.getArticles(
        page: nextPage,
        limit: 10,
        search: _searchQuery,
        category: _selectedCategory,
      );
      _articles.addAll(response.data);
      _meta = response.meta;
    } catch (e) {
      AppToast.showError('Failed to load more articles');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Fetch Saved Articles ────────────────────────────────────────────────
  Future<void> fetchSavedArticles({bool refresh = false}) async {
    if (!isLoggedIn) {
      _savedArticles = [];
      _savedMeta = PaginationMeta.empty();
      _savedErrorMessage = null;
      notifyListeners();
      return;
    }

    if (_isLoadingSaved) return;
    _isLoadingSaved = true;
    _savedErrorMessage = null;
    if (refresh) {
      _savedArticles = [];
      _savedMeta = PaginationMeta.empty();
    }
    notifyListeners();

    try {
      final response = await _repository.getSavedArticles(
        page: 1,
        limit: 10,
        search: _searchQuery,
        category: _selectedCategory,
      );
      _savedArticles = response.data;
      _savedMeta = response.meta;
    } catch (e) {
      _savedErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingSaved = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSavedArticles() async {
    if (!isLoggedIn || _isLoadingMoreSaved || !_savedMeta.hasNextPage) return;
    _isLoadingMoreSaved = true;
    notifyListeners();

    try {
      final nextPage = _savedMeta.page + 1;
      final response = await _repository.getSavedArticles(
        page: nextPage,
        limit: 10,
        search: _searchQuery,
        category: _selectedCategory,
      );
      _savedArticles.addAll(response.data);
      _savedMeta = response.meta;
    } catch (e) {
      AppToast.showError('Failed to load more saved articles');
    } finally {
      _isLoadingMoreSaved = false;
      notifyListeners();
    }
  }

  // ── Fetch Article Detail ────────────────────────────────────────────────
  Future<ResourceHubArticle?> fetchArticleDetail(String id) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _currentDetailArticle = null;
    notifyListeners();

    try {
      final article = await _repository.getArticleDetail(id);
      _currentDetailArticle = article;
      // Sync isSaved with the item in the list if already loaded
      _updateArticleSavedLocally(article.id, article.isSaved);
      return article;
    } catch (e) {
      final error = e.toString().replaceFirst('Exception: ', '');
      _detailErrorMessage = error;
      if (error.contains('not found') || error.contains('404')) {
        _removeArticleLocally(id);
        AppToast.showWarning('This article is no longer available');
      } else {
        AppToast.showError(error);
      }
      return null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ── Optimistic Save / Unsave ────────────────────────────────────────────
  Future<bool> toggleSaveArticle(ResourceHubArticle article) async {
    if (!isLoggedIn) {
      AppToast.showWarning('Please sign in to save articles');
      return false;
    }

    final bool newSavedState = !article.isSaved;

    // Apply optimistic updates locally
    _updateArticleSavedLocally(article.id, newSavedState);
    if (_currentDetailArticle?.id == article.id) {
      _currentDetailArticle = _currentDetailArticle!.copyWith(isSaved: newSavedState);
    }
    if (!newSavedState) {
      _savedArticles.removeWhere((item) => item.id == article.id);
    } else {
      final existsInSaved = _savedArticles.any((item) => item.id == article.id);
      if (!existsInSaved) {
        _savedArticles.insert(0, article.copyWith(isSaved: true, savedAt: DateTime.now()));
      }
    }
    notifyListeners();

    AppToast.show(
      newSavedState ? 'Article saved to bookmarks' : 'Removed from bookmarks',
    );

    try {
      if (newSavedState) {
        await _repository.saveArticle(article.id);
      } else {
        await _repository.unsaveArticle(article.id);
      }
      return true;
    } catch (e) {
      // Revert optimistic changes on failure
      final originalSavedState = !newSavedState;
      _updateArticleSavedLocally(article.id, originalSavedState);
      if (_currentDetailArticle?.id == article.id) {
        _currentDetailArticle =
            _currentDetailArticle!.copyWith(isSaved: originalSavedState);
      }
      if (originalSavedState) {
        if (!_savedArticles.any((item) => item.id == article.id)) {
          _savedArticles.insert(0, article.copyWith(isSaved: true));
        }
      } else {
        _savedArticles.removeWhere((item) => item.id == article.id);
      }
      notifyListeners();

      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (errorMsg.contains('404') || errorMsg.contains('not found')) {
        _removeArticleLocally(article.id);
        AppToast.showWarning('This article is no longer available');
      } else {
        AppToast.showError('Could not update bookmark. Please try again.');
      }
      return false;
    }
  }

  void _updateArticleSavedLocally(String articleId, bool isSaved) {
    final index = _articles.indexWhere((item) => item.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(isSaved: isSaved);
    }
  }

  void _removeArticleLocally(String articleId) {
    _articles.removeWhere((item) => item.id == articleId);
    _savedArticles.removeWhere((item) => item.id == articleId);
    if (_currentDetailArticle?.id == articleId) {
      _currentDetailArticle = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
