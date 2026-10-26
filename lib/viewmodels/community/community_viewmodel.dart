import 'dart:io';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/community_comment_model.dart';
import '../../models/community_enums.dart';
import '../../models/community_group_model.dart';
import '../../models/community_post_model.dart';
import '../../repositories/community_repository.dart';
import '../../services/local/storage_service.dart';
import '../../services/local/cache_service.dart';
import '../../services/permissions/permission_service.dart';

/// Represents a single community group.
class CommunityGroup {
  final String? id;
  final String title;
  final String members;
  final Color bgColor;
  final dynamic icon;
  final String? coverImageUrl;

  const CommunityGroup({
    this.id,
    required this.title,
    required this.members,
    required this.bgColor,
    required this.icon,
    this.coverImageUrl,
  });
}

/// Represents a spotlight community member.
class SpotlightMember {
  final String name;
  final String role;
  final String imageUrl;
  final bool isOnline;
  final bool hasBorderRing;

  const SpotlightMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.isOnline,
    required this.hasBorderRing,
  });
}

/// Represents a community feed filter option.
class CommunityFilter {
  final String label;
  final String icon;

  const CommunityFilter({required this.label, required this.icon});
}

/// ViewModel for the Community module.
///
/// Manages:
/// - Feed filter selection (All, Questions, Help, Events)
/// - Groups list and navigation state
/// - Community spotlight members list
/// - Dynamic Feed posts data, adding new posts, liking, voting, commenting
/// - Integration with CommunityRepository for REST API operations
class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository? _communityRepository;
  final StorageService? _storageService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CommunityViewModel([this._communityRepository, this._storageService]) {
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    try {
      final cachedFeed = CacheService.instance.getJsonList(CacheService.keyCommunityFeed);
      if (cachedFeed != null && cachedFeed.isNotEmpty) {
        _posts.clear();
        _posts.addAll(cachedFeed.map((json) => CommunityPostModel.fromJson(json)));
      }
      final cachedMyPosts = CacheService.instance.getJsonList(CacheService.keyCommunityMyPosts);
      if (cachedMyPosts != null && cachedMyPosts.isNotEmpty) {
        _myPosts.clear();
        _myPosts.addAll(cachedMyPosts.map((json) => CommunityPostModel.fromJson(json)));
      }
    } catch (e) {
      debugPrint('[CommunityViewModel] Hydration error: $e');
    }
  }

  void _persistFeed() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyCommunityFeed,
        _posts.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _persistMyPosts() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyCommunityMyPosts,
        _myPosts.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Filter State
  // ──────────────────────────────────────────────────────────────────────────
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  final List<CommunityFilter> filterOptions = const [
    CommunityFilter(label: 'All', icon: ''),
    CommunityFilter(label: 'Questions', icon: '❓'),
    CommunityFilter(label: 'Help', icon: '🤝'),
    CommunityFilter(label: 'Events', icon: '🎉'),
  ];

  void selectFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Groups Data
  // ──────────────────────────────────────────────────────────────────────────
  final List<CommunityGroup> _groups = [];
  List<CommunityGroup> get groups => _groups;

  void setGroups(List<CommunityGroup> newGroups) {
    _groups.clear();
    _groups.addAll(newGroups);
    notifyListeners();
  }

  void addGroup(CommunityGroup group) {
    _groups.insert(0, group);
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // All Groups Screen State
  // ──────────────────────────────────────────────────────────────────────────
  String _allGroupsFilter = 'All';
  String get allGroupsFilter => _allGroupsFilter;

  bool _showAllMyGroups = false;
  bool get showAllMyGroups => _showAllMyGroups;

  bool _showAllDiscoverGroups = false;
  bool get showAllDiscoverGroups => _showAllDiscoverGroups;

  final ScrollController allGroupsScrollController = ScrollController();

  final List<String> allGroupsFilters = const ['All', 'My Groups'];

  final List<Map<String, dynamic>> _myGroupsList = [];
  List<Map<String, dynamic>> get myGroupsList => _myGroupsList;

  final List<Map<String, dynamic>> _discoverGroupsList = [];
  List<Map<String, dynamic>> get discoverGroupsList => _discoverGroupsList;

  void addCreatedGroup(Map<String, dynamic> group) {
    _myGroupsList.insert(0, group);
    if (_selectedAudience == 'Group') {
      final avail = availableGroups;
      if (avail.isNotEmpty &&
          (_selectedGroupId == null ||
              _selectedGroupId!.isEmpty ||
              !avail.any((g) => g['id'] == _selectedGroupId))) {
        _selectedGroupId = avail.first['id'];
        _selectedGroupName = avail.first['name'] ?? 'Select Group';
      }
    }
    notifyListeners();
  }

  void setMyGroups(List<Map<String, dynamic>> groups) {
    _myGroupsList.clear();
    _myGroupsList.addAll(groups);
    if (_selectedAudience == 'Group') {
      final avail = availableGroups;
      if (avail.isNotEmpty &&
          (_selectedGroupId == null ||
              _selectedGroupId!.isEmpty ||
              !avail.any((g) => g['id'] == _selectedGroupId))) {
        _selectedGroupId = avail.first['id'];
        _selectedGroupName = avail.first['name'] ?? 'Select Group';
      }
    }
    notifyListeners();
  }

  void setDiscoverGroups(List<Map<String, dynamic>> groups) {
    _discoverGroupsList.clear();
    _discoverGroupsList.addAll(groups);
    notifyListeners();
  }

  void setAllGroupsFilter(String filter) {
    _allGroupsFilter = filter;
    if (filter == 'My Groups') {
      _showAllMyGroups = true;
    }
    notifyListeners();
  }

  void toggleShowAllMyGroups() {
    _showAllMyGroups = !_showAllMyGroups;
    if (_showAllMyGroups) {
      _allGroupsFilter = 'My Groups';
    } else {
      _allGroupsFilter = 'All';
    }
    notifyListeners();
  }

  void toggleShowAllDiscoverGroups() {
    _showAllDiscoverGroups = !_showAllDiscoverGroups;
    _allGroupsFilter = 'All(128)';
    notifyListeners();
    if (allGroupsScrollController.hasClients) {
      allGroupsScrollController.animateTo(
        allGroupsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> toggleJoinDiscoverGroup(int index) async {
    if (index >= 0 && index < _discoverGroupsList.length) {
      final group = _discoverGroupsList[index];
      final current = (group['isJoined'] as bool?) ?? false;
      final newStatus = !current;
      group['isJoined'] = newStatus;
      final groupId = (group['id'] ?? group['groupId'])?.toString();

      if (newStatus) {
        if (groupId != null &&
            !_myGroupsList.any(
              (g) => (g['id'] ?? g['groupId'])?.toString() == groupId,
            )) {
          _myGroupsList.insert(
            0,
            Map<String, dynamic>.from(group)..['isJoined'] = true,
          );
        }
      } else {
        if (groupId != null) {
          _myGroupsList.removeWhere(
            (g) => (g['id'] ?? g['groupId'])?.toString() == groupId,
          );
        }
      }
      notifyListeners();

      if (_communityRepository != null && groupId != null && _isUuid(groupId)) {
        try {
          if (newStatus) {
            await _communityRepository.joinGroup(groupId);
          } else {
            await _communityRepository.leaveGroup(groupId);
          }
        } catch (e) {
          debugPrint('Error toggling group join: $e');
        }
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Create Group Form State
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController createGroupNameController =
      TextEditingController();
  final TextEditingController createGroupDescController =
      TextEditingController();

  File? _createGroupCoverPhoto;
  File? get createGroupCoverPhoto => _createGroupCoverPhoto;

  CommunityGroupCategory? _createGroupCategory;
  CommunityGroupCategory? get createGroupCategory => _createGroupCategory;

  CommunityGroupPrivacy _createGroupPrivacy = CommunityGroupPrivacy.PUBLIC;
  CommunityGroupPrivacy get createGroupPrivacy => _createGroupPrivacy;

  bool _isCreatingGroup = false;
  bool get isCreatingGroup => _isCreatingGroup;

  void setCreateGroupCategory(CommunityGroupCategory? cat) {
    _createGroupCategory = cat;
    notifyListeners();
  }

  void setCreateGroupPrivacy(CommunityGroupPrivacy privacy) {
    _createGroupPrivacy = privacy;
    notifyListeners();
  }

  void toggleCreateGroupPrivacy() {
    _createGroupPrivacy = _createGroupPrivacy == CommunityGroupPrivacy.PUBLIC
        ? CommunityGroupPrivacy.PRIVATE
        : CommunityGroupPrivacy.PUBLIC;
    notifyListeners();
  }

  Future<void> pickCreateGroupCoverPhoto([BuildContext? context]) async {
    final hasPermission = await PermissionService.requestGallery(context);
    if (!hasPermission) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        _createGroupCoverPhoto = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking cover photo: $e');
    }
  }

  void removeCreateGroupCoverPhoto() {
    _createGroupCoverPhoto = null;
    notifyListeners();
  }

  void resetCreateGroupForm() {
    createGroupNameController.clear();
    createGroupDescController.clear();
    _createGroupCoverPhoto = null;
    _createGroupCategory = null;
    _createGroupPrivacy = CommunityGroupPrivacy.PUBLIC;
    _isCreatingGroup = false;
    notifyListeners();
  }

  /// Creates a new Community Group via REST API (`POST /community/group`)
  Future<CommunityGroupModel?> createGroup(BuildContext context) async {
    final name = createGroupNameController.text.trim();
    final desc = createGroupDescController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return null;
    }

    if (name.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group name cannot exceed 100 characters'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return null;
    }

    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group description'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return null;
    }

    if (desc.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description cannot exceed 1000 characters'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return null;
    }

    if (_createGroupCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a group category'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return null;
    }

    _isCreatingGroup = true;
    notifyListeners();

    try {
      if (_communityRepository == null) {
        final localGroup = CommunityGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: name,
          members: '1 member',
          bgColor: const Color(0xFF0052FF),
          icon: AppIcons.assetCommuintySvg,
        );
        addGroup(localGroup);
        addCreatedGroup({
          'id': localGroup.id,
          'groupId': localGroup.id,
          'title': name,
          'name': name,
          'description': desc,
          'members': '1 member',
          'memberCount': 1,
          'category': _createGroupCategory!.name,
          'privacy': _createGroupPrivacy.name,
          'tag': name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'GP',
          'bgColor': const Color(0xFF0052FF),
          'isJoined': true,
        });
        resetCreateGroupForm();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Community group created successfully!'),
              backgroundColor: AppColors.vibrantBlue,
            ),
          );
          Navigator.pop(context);
        }
        return null;
      }

      final created = await _communityRepository.createGroup(
        name: name,
        description: desc,
        category: _createGroupCategory!,
        privacy: _createGroupPrivacy,
        coverPhoto: _createGroupCoverPhoto,
      );

      final uiGroup = CommunityGroup(
        id: created.id,
        title: created.name,
        members: created.formattedMemberCount,
        bgColor: const Color(0xFF0052FF),
        icon: AppIcons.assetCommuintySvg,
        coverImageUrl: created.coverPhotoUrl,
      );
      addGroup(uiGroup);
      addCreatedGroup(created.toMapForUI()..['isJoined'] = true);

      resetCreateGroupForm();

      // Refresh groups list in background to ensure server sync
      fetchMyGroups(force: true);
      fetchGroups(force: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community group created successfully!'),
            backgroundColor: AppColors.vibrantBlue,
          ),
        );
        Navigator.pop(context);
      }
      return created;
    } catch (e) {
      debugPrint('Error creating group: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create group: ${e.toString().replaceAll("Exception:", "").trim()}',
            ),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
      return null;
    } finally {
      _isCreatingGroup = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Spotlight Members Data
  // ──────────────────────────────────────────────────────────────────────────
  final List<SpotlightMember> _spotlightMembers = [];
  List<SpotlightMember> get spotlightMembers => _spotlightMembers;

  void setSpotlightMembers(List<SpotlightMember> members) {
    _spotlightMembers.clear();
    _spotlightMembers.addAll(members);
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Feed Posts Data
  // ──────────────────────────────────────────────────────────────────────────
  final List<CommunityPostModel> _posts = [];

  List<CommunityPostModel> get posts => List.unmodifiable(_posts);

  List<CommunityPostModel> get filteredPosts {
    // Only display general/public community posts (those without a groupId)
    // so group-specific posts only appear within their respective group screen!
    final publicPosts = _posts.where((post) {
      final hasGroup =
          (post.groupId != null && post.groupId!.trim().isNotEmpty) ||
          (post.group != null && post.group!.id.trim().isNotEmpty);
      return !hasGroup;
    }).toList();

    if (_selectedFilter == 'All') {
      return publicPosts;
    }
    return publicPosts
        .where(
          (post) => post.tag.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // User's Own Community Posts
  // ──────────────────────────────────────────────────────────────────────────
  final List<CommunityPostModel> _myPosts = [];
  List<CommunityPostModel> get myPosts => List.unmodifiable(_myPosts);

  int _myPostsTotalCount = 0;
  int get myPostsTotalCount =>
      _myPostsTotalCount > 0 ? _myPostsTotalCount : _myPosts.length;

  bool _isFetchingMyPosts = false;
  bool _hasFetchedMyPosts = false;
  bool get hasFetchedMyPosts => _hasFetchedMyPosts;

  Future<void> fetchMyPosts({bool force = false}) async {
    if ((_hasFetchedMyPosts && !force) || _isFetchingMyPosts) return;
    final token = _storageService?.getToken();
    if (token == null || token.isEmpty) {
      _myPosts.clear();
      _myPostsTotalCount = 0;
      _hasFetchedMyPosts = true;
      notifyListeners();
      return;
    }
    _isFetchingMyPosts = true;
    try {
      if (_communityRepository != null) {
        final result = await _communityRepository.getMyPosts(
          page: 1,
          limit: 30,
        );
        _myPosts.clear();
        _myPosts.addAll(result.data);
        _myPostsTotalCount = result.meta.total;
        _persistMyPosts();
        _hasFetchedMyPosts = true;
        notifyListeners();
      }
    } catch (_) {
      // ignore
    } finally {
      _isFetchingMyPosts = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // API Integration Methods
  // ──────────────────────────────────────────────────────────────────────────

  bool _isFeedInitialized = false;
  void initCommunityFeed() {
    if (!_isFeedInitialized) {
      _isFeedInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchFeed();
        fetchGroups();
        fetchMyGroups();
      });
    }
  }

  bool _isLoadingGroups = false;
  bool get isLoadingGroups => _isLoadingGroups;

  bool _hasFetchedGroups = false;
  bool get hasFetchedGroups => _hasFetchedGroups;

  bool _isLoadingMyGroups = false;
  bool get isLoadingMyGroups => _isLoadingMyGroups;

  bool _hasFetchedMyGroups = false;
  bool get hasFetchedMyGroups => _hasFetchedMyGroups;

  /// Fetches active public community groups (`GET /community/group`)
  Future<void> fetchGroups({
    int page = 1,
    int limit = 10,
    CommunityGroupCategory? category,
    bool force = false,
  }) async {
    if (_communityRepository == null) return;
    if ((_hasFetchedGroups && !force) || _isLoadingGroups) return;
    _isLoadingGroups = true;
    notifyListeners();

    try {
      final res = await _communityRepository.getGroups(
        page: page,
        limit: limit,
        category: category,
      );
      final mappedGroups = res.data.map((g) {
        return CommunityGroup(
          id: g.id,
          title: g.name,
          members: g.formattedMemberCount,
          bgColor: const Color(0xFF0052FF),
          icon: AppIcons.assetCommuintySvg,
          coverImageUrl: g.coverPhotoUrl,
        );
      }).toList();
      setGroups(mappedGroups);

      final mappedDiscover = res.data.map((g) => g.toMapForUI()).toList();
      setDiscoverGroups(mappedDiscover);
      _hasFetchedGroups = true;
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    } finally {
      _isLoadingGroups = false;
      notifyListeners();
    }
  }

  /// Fetches the authenticated user's joined groups (`GET /community/group/me`)
  Future<void> fetchMyGroups({
    int page = 1,
    int limit = 50,
    CommunityGroupCategory? category,
    bool force = false,
  }) async {
    if (_communityRepository == null) return;
    if ((_hasFetchedMyGroups && !force) || _isLoadingMyGroups) return;
    _isLoadingMyGroups = true;
    notifyListeners();

    try {
      final res = await _communityRepository.getMyGroups(
        page: page,
        limit: limit,
        category: category,
      );
      final mappedMy = res.data
          .map((g) => g.toMapForUI()..['isJoined'] = true)
          .toList();
      setMyGroups(mappedMy);
      _hasFetchedMyGroups = true;
    } catch (e) {
      debugPrint('Error fetching my groups: $e');
    } finally {
      _isLoadingMyGroups = false;
      notifyListeners();
    }
  }

  /// Fetches a single group by ID (`GET /community/group/:id`)
  Future<CommunityGroupModel?> fetchGroupById(String id) async {
    if (_communityRepository == null || id.isEmpty) return null;
    try {
      return await _communityRepository.getGroupById(id);
    } catch (e) {
      debugPrint('Error fetching group by ID: $e');
      return null;
    }
  }

  /// Ensures both discover groups and joined groups are fetched for AllGroupsView
  void ensureAllGroupsInitialized() {
    if (!_hasFetchedGroups && !_isLoadingGroups) {
      fetchGroups();
    }
    if (!_hasFetchedMyGroups && !_isLoadingMyGroups) {
      fetchMyGroups();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Active Group Detail State (MVVM for GroupDetailView)
  // ──────────────────────────────────────────────────────────────────────────
  String? _activeGroupId;
  String? get activeGroupId => _activeGroupId;

  Map<String, dynamic>? _currentGroupDetails;
  Map<String, dynamic>? get currentGroupDetails => _currentGroupDetails;

  List<CommunityPostModel> _currentGroupPosts = [];
  List<CommunityPostModel> get currentGroupPosts => _currentGroupPosts;

  bool _isLoadingGroupPosts = false;
  bool get isLoadingGroupPosts => _isLoadingGroupPosts;

  /// Ensures group detail view state is initialized for a specific groupId
  void ensureGroupDetailInitialized(
    String groupId, {
    Map<String, dynamic>? initialGroup,
  }) {
    if (groupId.isEmpty) return;

    if (_activeGroupId != groupId) {
      _activeGroupId = groupId;
      _currentGroupDetails =
          initialGroup != null ? Map<String, dynamic>.from(initialGroup) : null;
      _currentGroupPosts = [];
      _isLoadingGroupPosts = true;
      notifyListeners();

      fetchGroupById(groupId).then((model) {
        if (model != null && _activeGroupId == groupId) {
          _currentGroupDetails = model.toMapForUI();
          notifyListeners();
        }
      });

      loadActiveGroupPosts(groupId);
    } else if (initialGroup != null && _currentGroupDetails == null) {
      _currentGroupDetails = Map<String, dynamic>.from(initialGroup);
      notifyListeners();
    }
  }

  /// Loads group posts for active group
  Future<void> loadActiveGroupPosts(String groupId) async {
    if (groupId.isEmpty) return;
    _isLoadingGroupPosts = true;
    notifyListeners();

    try {
      final posts = await fetchGroupPosts(groupId);
      if (_activeGroupId == groupId) {
        _currentGroupPosts = posts;
      }
    } catch (e) {
      debugPrint('Error loading active group posts: $e');
    } finally {
      if (_activeGroupId == groupId) {
        _isLoadingGroupPosts = false;
        notifyListeners();
      }
    }
  }

  /// Full refresh for active group (used on pull-to-refresh)
  Future<void> refreshActiveGroup(String groupId) async {
    if (groupId.isEmpty) return;
    await Future.wait([
      fetchGroupById(groupId).then((model) {
        if (model != null && _activeGroupId == groupId) {
          _currentGroupDetails = model.toMapForUI();
          notifyListeners();
        }
      }),
      loadActiveGroupPosts(groupId),
    ]);
  }

  /// Fetches the feed from the backend API if available (`GET /community/post`)
  Future<void> fetchFeed({
    int page = 1,
    int limit = 10,
    CommunityPostType? type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_communityRepository != null) {
      try {
        final response = await _communityRepository.getFeed(
          page: page,
          limit: limit,
          type: type,
        );
        if (page == 1) {
          _posts.clear();
        }
        _posts.addAll(response.data);
        if (page == 1) {
          _persistFeed();
        }
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      if (page == 1) {
        _posts.clear();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create and submit a post to the API (`POST /community/post`)
  Future<bool> createPost({
    required CommunityPostType type,
    required CommunityPostVisibility visibility,
    String? content,
    String? groupId,
    String? pollQuestion,
    List<String>? pollOptions,
    DateTime? pollExpiresAt,
    List<File>? photos,
    File? video,
    CommunityPostModel? fallbackPost,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_communityRepository != null) {
      try {
        final created = await _communityRepository.createPost(
          type: type,
          visibility: visibility,
          content: content,
          groupId: groupId,
          pollQuestion: pollQuestion,
          pollOptions: pollOptions,
          pollExpiresAt: pollExpiresAt,
          photos: photos,
          video: video,
        );
        // Insert real backend post at top of feed
        _posts.insert(0, created);
        _myPosts.insert(0, created);
        _myPostsTotalCount++;
        if (groupId != null && groupId.isNotEmpty && _activeGroupId == groupId) {
          _currentGroupPosts.insert(0, created);
        }
        _persistFeed();
        _persistMyPosts();
        return true;
      } catch (e) {
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('HttpException: ', '');
        debugPrint('CommunityViewModel.createPost error: $e');
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _errorMessage = 'Community service is currently unavailable.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Adds a new community post to the top of the feed.
  void addPost(CommunityPostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// Toggles like on a post with API synchronization (`POST/DELETE /interaction/like`)
  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final wasLiked = post.isLiked;

      // Optimistic update
      post.isLiked = !wasLiked;
      if (post.isLiked) {
        post.likesCount++;
      } else {
        post.likesCount = (post.likesCount - 1).clamp(0, 999999);
      }
      notifyListeners();

      if (_communityRepository != null) {
        try {
          if (wasLiked) {
            await _communityRepository.unlikePost(postId);
          } else {
            await _communityRepository.likePost(postId);
          }
        } catch (e) {
          // Keep optimistic state
        }
      }
    }
  }

  /// Share post with API sync (`POST /interaction/share`)
  Future<void> sharePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index].sharesCount++;
      notifyListeners();

      if (_communityRepository != null) {
        try {
          await _communityRepository.sharePost(postId);
        } catch (e) {
          // Ignored for optimistic UI
        }
      }
    }
  }

  /// Votes on a post poll option with API sync (`POST /poll/vote`)
  Future<void> votePoll(
    String postId,
    int optionIndex, {
    String? optionId,
  }) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      if (post.userVotedOption == null && post.pollOptions != null) {
        post.userVotedOption = optionIndex;
        post.pollVotes[optionIndex] = (post.pollVotes[optionIndex] ?? 0) + 1;
        notifyListeners();

        if (_communityRepository != null && optionId != null) {
          try {
            final pollResult = await _communityRepository.castPollVote(
              postId: postId,
              optionId: optionId,
            );
            _posts[index] = CommunityPostModel(
              id: post.id,
              authorId: post.authorId,
              groupId: post.groupId,
              type: post.type,
              visibility: post.visibility,
              status: post.status,
              content: post.content,
              officialSource: post.officialSource,
              authorLocation: post.authorLocation,
              isVerified: post.isVerified,
              timeAgo: post.timeAgo,
              tag: post.tag,
              location: post.location,
              feeling: post.feeling,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
              author: post.author,
              group: post.group,
              photos: post.photos,
              video: post.video,
              poll: pollResult,
              likesCount: post.likesCount,
              commentsCount: post.commentsCount,
              sharesCount: post.sharesCount,
              isLiked: post.isLiked,
              isSaved: post.isSaved,
              userVotedOption: optionIndex,
            );
            notifyListeners();
          } catch (e) {
            // Keep local state
          }
        }
      }
    }
  }

  /// Delete a post with API sync (`DELETE /community/post/:id`)
  Future<bool> deletePost(String postId) async {
    if (_communityRepository == null) return false;
    try {
      final success = await _communityRepository.deletePost(postId);
      if (success) {
        _posts.removeWhere((p) => p.id == postId);
        _myPosts.removeWhere((p) => p.id == postId);
        _persistFeed();
        _persistMyPosts();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }

  /// Fetch a single post by ID (`GET /community/post/:id`)
  Future<CommunityPostModel?> fetchPostById(String id) async {
    if (_communityRepository == null) return null;
    try {
      return await _communityRepository.getPostById(id);
    } catch (e) {
      debugPrint('Error fetching post by id: $e');
      return null;
    }
  }

  /// Fetch posts for a specific group (`GET /community/post/group/:groupId`)
  Future<List<CommunityPostModel>> fetchGroupPosts(
    String groupId, {
    int page = 1,
    int limit = 10,
    CommunityPostType? type,
  }) async {
    if (_communityRepository == null) return [];
    try {
      final res = await _communityRepository.getGroupPosts(
        groupId: groupId,
        page: page,
        limit: limit,
        type: type,
      );
      return res.data;
    } catch (e) {
      debugPrint('Error fetching group posts: $e');
      return [];
    }
  }

  static bool _isUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(str);
  }

  /// Add comment or reply (`POST /community/post/comment`)
  Future<CommunityCommentModel?> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index].commentsCount++;
      notifyListeners();
    }

    if (_communityRepository != null && _isUuid(postId)) {
      try {
        return await _communityRepository.createComment(
          postId: postId,
          content: content,
          parentId: _isUuid(parentId) ? parentId : null,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Fetch comments for a post (`GET /community/post/comment/:postId`)
  Future<List<CommunityCommentModel>> fetchPostComments({
    required String postId,
    int page = 1,
    int limit = 30,
    String? parentId,
  }) async {
    if (_communityRepository != null && _isUuid(postId)) {
      try {
        final response = await _communityRepository.getPostComments(
          postId: postId,
          page: page,
          limit: limit,
          parentId: _isUuid(parentId) ? parentId : null,
        );
        return response.data;
      } catch (e) {
        debugPrint('[CommunityViewModel] Error fetching post comments for $postId: $e');
        return [];
      }
    }
    return [];
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Active Post Comments State & Methods (MVVM BottomSheet)
  // ──────────────────────────────────────────────────────────────────────────
  List<CommunityCommentModel> _activeComments = [];
  List<CommunityCommentModel> get activeComments => _activeComments;

  bool _isLoadingComments = false;
  bool get isLoadingComments => _isLoadingComments;

  CommunityCommentModel? _replyingToComment;
  CommunityCommentModel? get replyingToComment => _replyingToComment;

  final TextEditingController commentInputController = TextEditingController();
  final ScrollController commentsScrollController = ScrollController();

  Future<void> loadCommentsForPost(String postId) async {
    _isLoadingComments = true;
    _replyingToComment = null;
    commentInputController.clear();
    notifyListeners();

    final apiComments = await fetchPostComments(postId: postId);
    _activeComments = apiComments;
    _isLoadingComments = false;
    notifyListeners();
  }

  void setReplyingTo(CommunityCommentModel? comment) {
    _replyingToComment = comment;
    notifyListeners();
  }

  void clearReplyingTo() {
    _replyingToComment = null;
    notifyListeners();
  }

  Future<void> submitActiveComment({
    required String postId,
    required dynamic currentUser,
  }) async {
    final text = commentInputController.text.trim();
    if (text.isEmpty) return;

    final newComment = CommunityCommentModel(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: currentUser?.id ?? 'user-me',
      parentId: _replyingToComment?.id,
      content: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: CommunityCommentUser(
        id: currentUser?.id ?? 'user-me',
        firstName: currentUser?.firstName ?? 'You',
        lastName: currentUser?.lastName,
        profilePhotoUrl: currentUser?.profilePhotoUrl,
      ),
    );

    _activeComments.add(newComment);
    commentInputController.clear();
    _replyingToComment = null;
    notifyListeners();

    // Call API via repository
    final created = await addComment(
      postId: postId,
      content: text,
      parentId: newComment.parentId,
    );
    if (created != null) {
      final idx = _activeComments.indexWhere((c) => c.id == newComment.id);
      if (idx != -1) {
        _activeComments[idx] = created;
        notifyListeners();
      }
    }

    // Smooth scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (commentsScrollController.hasClients) {
        commentsScrollController.animateTo(
          commentsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> deleteActiveComment(String commentId, {String? postId}) async {
    final index = _activeComments.indexWhere((c) => c.id == commentId);
    if (index == -1) return false;

    final removed = _activeComments.removeAt(index);
    if (postId != null) {
      final pIndex = _posts.indexWhere((p) => p.id == postId);
      if (pIndex != -1) {
        _posts[pIndex].commentsCount =
            (_posts[pIndex].commentsCount - 1).clamp(0, 999999);
      }
    }
    notifyListeners();

    if (_communityRepository != null && _isUuid(commentId)) {
      try {
        final success = await _communityRepository.deleteComment(commentId);
        if (!success) {
          _activeComments.insert(index, removed);
          notifyListeners();
          return false;
        }
        return true;
      } catch (e) {
        _activeComments.insert(index, removed);
        notifyListeners();
        return false;
      }
    }
    return true;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Gallery Preview State
  // ──────────────────────────────────────────────────────────────────────────
  int _activeGalleryIndex = 0;
  int get activeGalleryIndex => _activeGalleryIndex;

  void setActiveGalleryIndex(int index) {
    _activeGalleryIndex = index;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Post Community Form State & Methods
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController _postContentController = TextEditingController();
  TextEditingController get postContentController => _postContentController;

  final ImagePicker _postImagePicker = ImagePicker();

  String _selectedTab = 'Text'; // 'Text', 'Photo', 'Video', 'Poll'
  String get selectedTab => _selectedTab;

  String _selectedAudience = 'Public'; // 'Public', 'Group', 'Only Me'
  String get selectedAudience => _selectedAudience;

  String? _selectedGroupId;
  String? get selectedGroupId => _selectedGroupId;

  String _selectedGroupName = 'Select Group';
  String get selectedGroupName => _selectedGroupName;

  int _pollDurationDays = 7;
  int get pollDurationDays => _pollDurationDays;

  bool _isSubmittingPost = false;
  bool get isSubmittingPost => _isSubmittingPost;

  final List<File> _selectedPhotos = [];
  List<File> get selectedPhotos => _selectedPhotos;

  File? _selectedVideoFile;
  File? get selectedVideoFile => _selectedVideoFile;

  String? _selectedLocation;
  String? get selectedLocation => _selectedLocation;

  String? _selectedFeeling;
  String? get selectedFeeling => _selectedFeeling;

  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: ''),
    TextEditingController(text: ''),
  ];
  List<TextEditingController> get pollOptionControllers =>
      _pollOptionControllers;

  final List<Map<String, dynamic>> _audienceOptions = [
    {
      'label': 'Public',
      'icon': AppIcons.globalSvg,
      'iconColor': const Color(0xFF3B82F6),
      'desc': 'Anyone on DesiConnect',
      'visibility': CommunityPostVisibility.PUBLIC,
    },
    {
      'label': 'Group',
      'icon': AppIcons.peopleCommunitySvg,
      'iconColor': const Color(0xFF8B5CF6),
      'desc': 'Active members of selected group',
      'visibility': CommunityPostVisibility.GROUP,
    },
    {
      'label': 'Only Me',
      'icon': AppIcons.lockSvg,
      'iconColor': const Color(0xFFEF4444),
      'desc': 'Only visible to you (Private)',
      'visibility': CommunityPostVisibility.PRIVATE,
    },
  ];
  List<Map<String, dynamic>> get audienceOptions => _audienceOptions;

  final List<Map<String, String>> _availableGroups = [];
  List<Map<String, String>> get availableGroups {
    final Map<String, String> uniqueGroups = {};

    // 1. Explicitly added available groups
    for (final g in _availableGroups) {
      final id = g['id']?.trim() ?? '';
      final name = g['name']?.trim() ?? '';
      if (id.isNotEmpty && name.isNotEmpty) {
        uniqueGroups[id] = name;
      }
    }

    // 2. User's joined groups (_myGroupsList from GET /community/group/me)
    for (final g in _myGroupsList) {
      final id = (g['id'] ?? g['groupId'])?.toString().trim() ?? '';
      final name = (g['name'] ?? g['title'])?.toString().trim() ?? '';
      if (id.isNotEmpty && name.isNotEmpty) {
        uniqueGroups[id] = name;
      }
    }

    // 3. Discover groups where user is joined
    for (final g in _discoverGroupsList) {
      final isJoined = (g['isJoined'] as bool?) ?? false;
      if (isJoined) {
        final id = (g['id'] ?? g['groupId'])?.toString().trim() ?? '';
        final name = (g['name'] ?? g['title'])?.toString().trim() ?? '';
        if (id.isNotEmpty && name.isNotEmpty) {
          uniqueGroups[id] = name;
        }
      }
    }

    // 4. If an initial/selected group is already active, ensure it's in the list
    if (_selectedGroupId != null &&
        _selectedGroupId!.isNotEmpty &&
        _selectedGroupName.isNotEmpty &&
        _selectedGroupName != 'Select Group') {
      uniqueGroups[_selectedGroupId!] = _selectedGroupName;
    }

    return uniqueGroups.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  void setAvailableGroups(List<Map<String, String>> groups) {
    _availableGroups.clear();
    _availableGroups.addAll(groups);
    notifyListeners();
  }

  bool _postCommunityFormInitialized = false;
  String? _initializedGroupId;

  void initPostCommunityForm({
    String? initialGroupId,
    String? initialGroupName,
    bool force = false,
  }) {
    if (_postCommunityFormInitialized &&
        !force &&
        _initializedGroupId == initialGroupId) {
      return;
    }
    _postCommunityFormInitialized = true;
    _initializedGroupId = initialGroupId;

    _postContentController.text = '';
    _selectedTab = 'Text';
    _selectedPhotos.clear();
    _selectedVideoFile = null;
    _selectedLocation = null;
    _selectedFeeling = null;
    _pollDurationDays = 7;
    _isSubmittingPost = false;

    while (_pollOptionControllers.length > 2) {
      final last = _pollOptionControllers.removeLast();
      last.dispose();
    }
    for (final c in _pollOptionControllers) {
      c.clear();
    }

    // Always ensure user's joined groups are loaded so they're available immediately
    if (!_isLoadingMyGroups) {
      fetchMyGroups(force: true, limit: 50);
    }

    if (initialGroupId != null && initialGroupId.isNotEmpty) {
      _selectedAudience = 'Group';
      _selectedGroupId = initialGroupId;
      _selectedGroupName = initialGroupName ?? 'Group';
    } else {
      _selectedAudience = 'Public';
      final groups = availableGroups;
      _selectedGroupId = groups.isNotEmpty
          ? groups.first['id']
          : null;
      _selectedGroupName = groups.isNotEmpty
          ? (_availableGroups.isNotEmpty
              ? (_availableGroups.first['name'] ?? 'Select Group')
              : (groups.first['name'] ?? 'Select Group'))
          : 'Select Group';
    }
  }

  void resetPostCommunityForm() {
    _postCommunityFormInitialized = false;
    _initializedGroupId = null;
    _postContentController.clear();
    _selectedPhotos.clear();
    _selectedVideoFile = null;
    _selectedLocation = null;
    _selectedFeeling = null;
    _selectedTab = 'Text';
    _selectedAudience = 'Public';
    final groups = availableGroups;
    _selectedGroupId = groups.isNotEmpty
        ? groups.first['id']
        : null;
    _selectedGroupName = groups.isNotEmpty
        ? (groups.first['name'] ?? 'Select Group')
        : 'Select Group';
    _pollDurationDays = 7;
    _isSubmittingPost = false;

    while (_pollOptionControllers.length > 2) {
      final last = _pollOptionControllers.removeLast();
      last.dispose();
    }
    for (final c in _pollOptionControllers) {
      c.clear();
    }
  }

  Future<void> pickPhotos([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> picked = await _postImagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        _selectedTab = 'Photo';
        _selectedVideoFile = null;
        for (final xf in picked) {
          if (_selectedPhotos.length < 5) {
            _selectedPhotos.add(File(xf.path));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> pickSinglePhoto([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? picked = await _postImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        _selectedTab = 'Photo';
        _selectedVideoFile = null;
        if (_selectedPhotos.length < 5) {
          _selectedPhotos.add(File(picked.path));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> pickVideo([BuildContext? context]) async {
    final allowed = await PermissionService.requestVideo(context);
    if (!allowed) return;
    try {
      final XFile? picked = await _postImagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (picked != null) {
        _selectedTab = 'Video';
        _selectedPhotos.clear();
        _selectedVideoFile = File(picked.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  Future<void> onTabChanged(String tab) async {
    _selectedTab = tab;
    if (tab == 'Photo') {
      _selectedVideoFile = null;
      notifyListeners();
      if (_selectedPhotos.isEmpty) {
        await pickPhotos();
      }
    } else if (tab == 'Video') {
      _selectedPhotos.clear();
      notifyListeners();
      if (_selectedVideoFile == null) {
        await pickVideo();
      }
    } else if (tab == 'Poll') {
      _selectedPhotos.clear();
      _selectedVideoFile = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < _selectedPhotos.length) {
      _selectedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  void removeVideo() {
    _selectedVideoFile = null;
    notifyListeners();
  }

  void addPollOption() {
    if (_pollOptionControllers.length < 6) {
      _pollOptionControllers.add(TextEditingController(text: ''));
      notifyListeners();
    }
  }

  void removePollOption(int index) {
    if (_pollOptionControllers.length > 2 &&
        index >= 0 &&
        index < _pollOptionControllers.length) {
      _pollOptionControllers[index].dispose();
      _pollOptionControllers.removeAt(index);
      notifyListeners();
    }
  }

  void setSelectedAudience(String audience) {
    _selectedAudience = audience;
    if (_selectedAudience == 'Group') {
      if (!_isLoadingMyGroups && availableGroups.isEmpty) {
        fetchMyGroups(force: true, limit: 50);
      }
      final groups = availableGroups;
      if (groups.isNotEmpty &&
          (_selectedGroupId == null ||
              _selectedGroupId!.isEmpty ||
              !groups.any((g) => g['id'] == _selectedGroupId))) {
        _selectedGroupId = groups.first['id'];
        _selectedGroupName = groups.first['name'] ?? 'Select Group';
      }
    }
    notifyListeners();
  }

  void setSelectedGroup(String id, String name) {
    _selectedGroupId = id;
    _selectedGroupName = name;
    notifyListeners();
  }

  void setSelectedLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSelectedFeeling(String? feeling) {
    _selectedFeeling = feeling;
    notifyListeners();
  }

  void setPollDurationDays(int days) {
    _pollDurationDays = days;
    notifyListeners();
  }

  String? validateCommunityPost() {
    final text = _postContentController.text.trim();

    switch (_selectedTab) {
      case 'Photo':
        if (_selectedPhotos.isEmpty) {
          return 'Please select at least 1 photo (up to 5 photos).';
        }
        if (_selectedPhotos.length > 5) {
          return 'You can upload a maximum of 5 photos.';
        }
        break;

      case 'Video':
        if (_selectedVideoFile == null) {
          return 'Please select a video file.';
        }
        break;

      case 'Poll':
        if (text.isEmpty) {
          return 'Please enter a question for your poll.';
        }
        if (text.length > 500) {
          return 'Poll question must not exceed 500 characters.';
        }
        final options = _pollOptionControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (options.length < 2) {
          return 'A poll requires at least 2 options.';
        }
        if (options.length > 6) {
          return 'A poll can have at most 6 options.';
        }
        break;

      case 'Text':
      default:
        if (text.isEmpty) {
          return 'Please write something for your text post.';
        }
        if (text.length > 5000) {
          return 'Post content must not exceed 5000 characters.';
        }
        break;
    }

    if (_selectedAudience == 'Group') {
      if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
        return 'Please select a valid group to post to.';
      }
    }

    return null;
  }

  Future<bool> submitPostForm({
    required String userName,
    String? userProfilePhotoUrl,
  }) async {
    if (_isSubmittingPost) return false;

    final text = _postContentController.text.trim();

    final CommunityPostType postType;
    switch (_selectedTab) {
      case 'Photo':
        postType = CommunityPostType.PHOTO;
        break;
      case 'Video':
        postType = CommunityPostType.VIDEO;
        break;
      case 'Poll':
        postType = CommunityPostType.POLL;
        break;
      case 'Text':
      default:
        postType = CommunityPostType.TEXT;
        break;
    }

    List<File>? photosToSend;
    File? videoToSend;
    String? pollQuestionToSend;
    List<String>? pollOptionsToSend;
    DateTime? pollExpiresAtToSend;

    switch (postType) {
      case CommunityPostType.TEXT:
        photosToSend = null;
        videoToSend = null;
        break;

      case CommunityPostType.PHOTO:
        photosToSend = List.from(_selectedPhotos);
        videoToSend = null;
        break;

      case CommunityPostType.VIDEO:
        photosToSend = null;
        videoToSend = _selectedVideoFile;
        break;

      case CommunityPostType.POLL:
        final options = _pollOptionControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        pollQuestionToSend = text;
        pollOptionsToSend = options;
        if (_pollDurationDays > 0) {
          pollExpiresAtToSend = DateTime.now().add(
            Duration(days: _pollDurationDays),
          );
        }
        photosToSend = null;
        videoToSend = null;
        break;
    }

    final CommunityPostVisibility postVisibility;
    String? groupIdToSend;

    if (_selectedAudience == 'Group') {
      postVisibility = CommunityPostVisibility.GROUP;
      groupIdToSend = _selectedGroupId;
    } else if (_selectedAudience == 'Only Me') {
      postVisibility = CommunityPostVisibility.PRIVATE;
      groupIdToSend = null;
    } else {
      postVisibility = CommunityPostVisibility.PUBLIC;
      groupIdToSend = null;
    }

    _isSubmittingPost = true;
    notifyListeners();

    final fallbackPost = CommunityPostModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      authorName: userName,
      authorAvatarUrl: userProfilePhotoUrl,
      authorLocation: _selectedLocation ?? 'Madrid, Spain',
      isVerified: true,
      timeAgo: 'Just now',
      tag: postType == CommunityPostType.POLL
          ? 'Questions'
          : (postVisibility == CommunityPostVisibility.GROUP
                ? (_selectedGroupName.isNotEmpty &&
                          _selectedGroupName != 'Select Group'
                      ? _selectedGroupName
                      : 'Group')
                : 'General'),
      type: postType,
      visibility: postVisibility,
      content: text.isNotEmpty
          ? text
          : (postType == CommunityPostType.POLL
                ? (pollQuestionToSend ?? '')
                : ''),
      mediaUrl: photosToSend != null && photosToSend.isNotEmpty
          ? photosToSend.first.path
          : videoToSend?.path,
      photos: photosToSend != null
          ? photosToSend
                .map((f) => PostPhotoModel(id: f.path, url: f.path))
                .toList()
          : const [],
      video: videoToSend != null
          ? PostVideoModel(id: videoToSend.path, url: videoToSend.path)
          : null,
      pollOptions: pollOptionsToSend,
      location: _selectedLocation,
      feeling: _selectedFeeling,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
    );

    final success = await createPost(
      type: postType,
      visibility: postVisibility,
      content: text.isNotEmpty
          ? text
          : (postType == CommunityPostType.POLL ? pollQuestionToSend : null),
      groupId: groupIdToSend,
      pollQuestion: pollQuestionToSend,
      pollOptions: pollOptionsToSend,
      pollExpiresAt: pollExpiresAtToSend,
      photos: photosToSend,
      video: videoToSend,
      fallbackPost: fallbackPost,
    );

    _isSubmittingPost = false;
    notifyListeners();

    if (success) {
      resetPostCommunityForm();
    }
    return success;
  }

  @override
  void dispose() {
    createGroupNameController.dispose();
    createGroupDescController.dispose();
    _postContentController.dispose();
    commentInputController.dispose();
    commentsScrollController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }
}
