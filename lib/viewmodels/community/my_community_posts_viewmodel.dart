import 'package:flutter/material.dart';
import '../../models/community_comment_model.dart';
import '../../models/community_enums.dart';
import '../../models/community_post_model.dart';
import '../../repositories/community_repository.dart';
import '../../services/local/cache_service.dart';

/// ViewModel for managing "My Community Posts" and "My Comments" screen.
/// Adheres strictly to MVVM architecture with Provider state management.
class MyCommunityPostsViewModel extends ChangeNotifier {
  final CommunityRepository? _communityRepository;

  MyCommunityPostsViewModel([this._communityRepository]) {
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    try {
      final cachedPosts = CacheService.instance.getJsonList(CacheService.keyCommunityMyPosts);
      if (cachedPosts != null && cachedPosts.isNotEmpty) {
        _myPosts = cachedPosts.map((json) => CommunityPostModel.fromJson(json)).toList();
      }
      final cachedComments = CacheService.instance.getJsonList(CacheService.keyCommunityMyComments);
      if (cachedComments != null && cachedComments.isNotEmpty) {
        _myComments = cachedComments.map((json) => CommunityCommentModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[MyCommunityPostsViewModel] Hydration error: $e');
    }
  }

  void _persistMyPosts() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyCommunityMyPosts,
        _myPosts.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _persistMyComments() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyCommunityMyComments,
        _myComments.take(30).map((c) => c.toJson()).toList(),
      );
    } catch (_) {}
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CommunityPostModel> _myPosts = [];
  List<CommunityPostModel> get myPosts => _myPosts;

  List<CommunityCommentModel> _myComments = [];
  List<CommunityCommentModel> get myComments => _myComments;

  // ──────────────────────────────────────────────────────────────────────────
  // Tab Management
  // ──────────────────────────────────────────────────────────────────────────
  void setTabIndex(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();

    if (index == 1 && _myComments.isEmpty && !_isLoading) {
      fetchMyComments();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Data Fetching
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> fetchMyPosts({
    int page = 1,
    int limit = 30,
    CommunityPostType? type,
    CommunityPostVisibility? visibility,
    bool silent = false,
    bool force = false,
  }) async {
    if ((_hasFetched && !force) || _isLoading) return;
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      if (_communityRepository != null) {
        final result = await _communityRepository.getMyPosts(
          page: page,
          limit: limit,
          type: type,
          visibility: visibility,
        );
        if (page == 1) {
          _myPosts = result.data;
          _persistMyPosts();
        } else {
          _myPosts.addAll(result.data);
        }
      } else if (_myPosts.isEmpty) {
        _myPosts = _getFallbackPosts();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _hasFetched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyComments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_communityRepository != null) {
        final result = await _communityRepository.getMyComments(
          page: 1,
          limit: 30,
        );
        _myComments = result.data;
        _persistMyComments();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_selectedTabIndex == 0) {
      await fetchMyPosts();
    } else {
      await fetchMyComments();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Post Interactions (Like, Share, Delete)
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final index = _myPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _myPosts[index];
    final bool wasLiked = post.isLiked;

    // Optimistic UI update
    post.isLiked = !wasLiked;
    if (post.isLiked) {
      post.likesCount += 1;
    } else {
      post.likesCount = (post.likesCount - 1).clamp(0, 999999);
    }
    notifyListeners();

    try {
      if (_communityRepository != null) {
        if (post.isLiked) {
          await _communityRepository.likePost(postId);
        } else {
          await _communityRepository.unlikePost(postId);
        }
      }
    } catch (_) {
      // Revert on error
      post.isLiked = wasLiked;
      if (wasLiked) {
        post.likesCount += 1;
      } else {
        post.likesCount = (post.likesCount - 1).clamp(0, 999999);
      }
      notifyListeners();
    }
  }

  Future<void> sharePost(String postId) async {
    final index = _myPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _myPosts[index];
    post.sharesCount += 1;
    notifyListeners();

    try {
      if (_communityRepository != null) {
        await _communityRepository.sharePost(postId);
      }
    } catch (_) {
      // Keep optimistic increment
    }
  }

  Future<bool> deletePost(String postId) async {
    final index = _myPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final removed = _myPosts.removeAt(index);
    notifyListeners();

    try {
      if (_communityRepository != null) {
        await _communityRepository.deletePost(postId);
      }
      _persistMyPosts();
      return true;
    } catch (e) {
      // Revert on error
      _myPosts.insert(index, removed);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    final index = _myComments.indexWhere((c) => c.id == commentId);
    if (index == -1) return false;

    final removed = _myComments.removeAt(index);
    notifyListeners();

    try {
      if (_communityRepository != null) {
        final success = await _communityRepository.deleteComment(commentId);
        if (!success) {
          _myComments.insert(index, removed);
          notifyListeners();
          return false;
        }
      }
      _persistMyComments();
      return true;
    } catch (e) {
      _myComments.insert(index, removed);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Retrieve full CommunityPostModel for a comment, querying cache or backend API.
  Future<CommunityPostModel> getOrFetchPost(CommunityCommentModel comment) async {
    for (final p in _myPosts) {
      if (p.id == comment.postId) return p;
    }

    if (_communityRepository != null) {
      try {
        final fetched = await _communityRepository.getPostById(comment.postId);
        return fetched;
      } catch (e) {
        debugPrint('Could not fetch post by id, using summary fallback: $e');
      }
    }

    final postSummary = comment.post;
    return CommunityPostModel(
      id: comment.postId,
      content: postSummary?.content ?? '',
      type: (postSummary?.type.toUpperCase() == 'PHOTO')
          ? CommunityPostType.PHOTO
          : ((postSummary?.type.toUpperCase() == 'VIDEO')
              ? CommunityPostType.VIDEO
              : CommunityPostType.TEXT),
      author: PostAuthorModel(
        id: postSummary?.author?.id ?? '',
        firstName: postSummary?.author?.firstName ?? 'Community',
        lastName: postSummary?.author?.lastName,
        profilePhotoUrl: postSummary?.author?.profilePhotoUrl,
      ),
      likesCount: 0,
      commentsCount: comment.repliesCount,
      sharesCount: 0,
      timeAgo: CommunityPostModel.formatTimeAgo(comment.createdAt),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Fallback initial dataset matching the user's design reference
  // ──────────────────────────────────────────────────────────────────────────
  List<CommunityPostModel> _getFallbackPosts() {
    return [
      CommunityPostModel(
        id: 'post_fallback_1',
        content:
            'Need a driver for personal work in Barcelona. Please contact if available.',
        timeAgo: '2 hours ago',
        location: 'Barcelona, Spain',
        likesCount: 12,
        commentsCount: 8,
        sharesCount: 3,
        type: CommunityPostType.TEXT,
        visibility: CommunityPostVisibility.PUBLIC,
        author: const PostAuthorModel(
          id: 'user_1',
          firstName: 'Ali',
          lastName: 'Khan',
        ),
      ),
      CommunityPostModel(
        id: 'post_fallback_2',
        content:
            'Looking for 1 bedroom apartment in Madrid. Budget €400-€500.',
        timeAgo: '5 days ago',
        location: 'Madrid, Spain',
        likesCount: 8,
        commentsCount: 15,
        sharesCount: 2,
        type: CommunityPostType.TEXT,
        visibility: CommunityPostVisibility.PUBLIC,
        author: const PostAuthorModel(
          id: 'user_1',
          firstName: 'Ali',
          lastName: 'Khan',
        ),
      ),
      CommunityPostModel(
        id: 'post_fallback_3',
        content: 'Best Pakistani restaurant in Madrid? 🍛',
        timeAgo: '1 week ago',
        location: null,
        likesCount: 15,
        commentsCount: 12,
        sharesCount: 5,
        type: CommunityPostType.TEXT,
        visibility: CommunityPostVisibility.PUBLIC,
        author: const PostAuthorModel(
          id: 'user_1',
          firstName: 'Ali',
          lastName: 'Khan',
        ),
      ),
    ];
  }
}
