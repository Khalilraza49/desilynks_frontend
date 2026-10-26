import 'package:flutter/material.dart';
import '../../models/community_enums.dart';
import '../../models/community_group_member_model.dart';
import '../../models/search_result_model.dart';
import '../../repositories/community_repository.dart';

/// ViewModel managing Group Members and Membership state.
class GroupMembersViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  GroupMembersViewModel(this._repository);

  // ──────────────────────────────────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _currentGroupId;
  String? get currentGroupId => _currentGroupId;

  // ──────────────────────────────────────────────────────────────────────────
  // Search Controller for GroupMembersView
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController membersSearchController = TextEditingController();

  // ──────────────────────────────────────────────────────────────────────────
  // Fallback state for GroupDetailView (when group is mock/local data)
  // ──────────────────────────────────────────────────────────────────────────
  bool _fallbackIsGroupJoined = false;
  bool get fallbackIsGroupJoined => _fallbackIsGroupJoined;

  void toggleFallbackGroupJoined() {
    _fallbackIsGroupJoined = !_fallbackIsGroupJoined;
    notifyListeners();
  }

  void setFallbackGroupJoined(bool val) {
    _fallbackIsGroupJoined = val;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Add Members Screen State
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController addMemberSearchController =
      TextEditingController();
  String _addMemberSearchQuery = '';
  String get addMemberSearchQuery => _addMemberSearchQuery;

  final Set<String> _selectedAddMemberNames = {};
  Set<String> get selectedAddMemberNames => _selectedAddMemberNames;

  final List<Map<String, String>> _suggestedPeople = [];
  List<Map<String, String>> get suggestedPeople => _suggestedPeople;

  void setSuggestedPeople(List<Map<String, String>> people) {
    _suggestedPeople.clear();
    _suggestedPeople.addAll(people);
    notifyListeners();
  }

  List<Map<String, String>> get filteredSuggestedPeople {
    if (_addMemberSearchQuery.trim().isEmpty) return _suggestedPeople;
    return _suggestedPeople.where((person) {
      return person['name']!.toLowerCase().contains(
        _addMemberSearchQuery.toLowerCase(),
      );
    }).toList();
  }

  void toggleAddMemberSelection(String name) {
    if (_selectedAddMemberNames.contains(name)) {
      _selectedAddMemberNames.remove(name);
    } else {
      _selectedAddMemberNames.add(name);
    }
    notifyListeners();
  }

  void clearSelectedAddMembers() {
    _selectedAddMemberNames.clear();
    notifyListeners();
  }

  void setAddMemberSearchQuery(String query) {
    _addMemberSearchQuery = query;
    notifyListeners();
  }

  void resetAddMembers() {
    _selectedAddMemberNames.clear();
    addMemberSearchController.clear();
    _addMemberSearchQuery = '';
    notifyListeners();
  }

  List<CommunityGroupMemberModel> _members = [];
  List<CommunityGroupMemberModel> get members => _members;

  List<CommunityGroupMemberModel> _adminMembers = [];
  List<CommunityGroupMemberModel> get adminMembers => _adminMembers;

  CommunityGroupMemberModel? _myMembership;
  CommunityGroupMemberModel? get myMembership => _myMembership;

  SearchMeta? _meta;
  SearchMeta? get meta => _meta;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // ──────────────────────────────────────────────────────────────────────────
  // Computed Getters for UI
  // ──────────────────────────────────────────────────────────────────────────
  bool get isCurrentUserJoined =>
      _myMembership != null && _myMembership!.isActive;

  bool get isCurrentUserPending =>
      _myMembership != null && _myMembership!.isPending;

  bool get isCurrentUserAdmin =>
      _myMembership != null && _myMembership!.isAdmin;

  bool get isCurrentUserModerator =>
      _myMembership != null && _myMembership!.isModerator;

  bool get canManageMembers => isCurrentUserAdmin || isCurrentUserModerator;

  /// Admins and Moderators (filtered by search query)
  List<CommunityGroupMemberModel> get filteredAdmins {
    // If admin members endpoint returned data, use it; otherwise filter from members
    final baseList = _adminMembers.isNotEmpty
        ? _adminMembers.where((m) => m.isAdmin || m.isModerator).toList()
        : _members.where((m) => m.isAdmin || m.isModerator).toList();

    if (_searchQuery.trim().isEmpty) return baseList;

    return baseList.where((m) {
      final name = m.displayName.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// Regular members (filtered by search query)
  List<CommunityGroupMemberModel> get filteredMembers {
    final baseList = _members.where((m) => m.isMember).toList();

    if (_searchQuery.trim().isEmpty) return baseList;

    return baseList.where((m) {
      final name = m.displayName.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Data Operations
  // ──────────────────────────────────────────────────────────────────────────

  bool _hasInitializedGroup = false;
  String? _membershipFetchedGroupId;
  bool _isFetchingMembership = false;

  /// Initialize group data only if not already loaded for this groupId
  void initGroupIfNeeded(String groupId) {
    if (_currentGroupId == groupId && (_isLoading || _hasInitializedGroup)) {
      return;
    }
    initGroup(groupId);
  }

  /// Initialize group data (fetches members, admin members, and current membership)
  Future<void> initGroup(String groupId) async {
    _currentGroupId = groupId;
    _hasInitializedGroup = true;
    _searchQuery = '';
    _errorMessage = null;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchMembers(groupId, refresh: true),
        fetchMyMembership(groupId, force: true),
        fetchAdminMembers(groupId),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh group data (e.g. from pull-to-refresh)
  Future<void> refreshGroup(String groupId) async {
    _currentGroupId = groupId;
    _membershipFetchedGroupId = null;
    _searchQuery = '';
    _errorMessage = null;

    try {
      await Future.wait([
        fetchMembers(groupId, refresh: true),
        fetchMyMembership(groupId, force: true),
        fetchAdminMembers(groupId),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Fetch Active Group Members
  Future<void> fetchMembers(String groupId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    try {
      final res = await _repository.getGroupMembers(
        groupId: groupId,
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _members = res.data;
      } else {
        _members.addAll(res.data);
      }

      _meta = res.meta;
      _hasMore = res.meta.page < res.meta.totalPages;
      if (_hasMore) _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Fetch Admin/Moderator Group Members
  Future<void> fetchAdminMembers(
    String groupId, {
    CommunityGroupMemberStatus? status,
    CommunityGroupMemberRole? role,
  }) async {
    try {
      final res = await _repository.getAdminGroupMembers(
        groupId: groupId,
        status: status,
        role: role,
        page: 1,
        limit: 50,
      );
      _adminMembers = res.data;
    } catch (_) {
      // If user is not admin/moderator, this endpoint might 403, which is expected
    }
    notifyListeners();
  }

  /// Fetch Current User's Membership
  Future<void> fetchMyMembership(String groupId, {bool force = false}) async {
    if ((_membershipFetchedGroupId == groupId && !force) || _isFetchingMembership) {
      return;
    }
    _isFetchingMembership = true;
    _membershipFetchedGroupId = groupId;

    try {
      _myMembership = await _repository.getMyMembership(groupId);
    } catch (e) {
      _myMembership = null;
    } finally {
      _isFetchingMembership = false;
      notifyListeners();
    }
  }

  /// Join Group
  Future<bool> joinGroup(String groupId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final member = await _repository.joinGroup(groupId);
      _myMembership = member;
      await fetchMembers(groupId, refresh: true);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Leave Group
  Future<bool> leaveGroup(String groupId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.leaveGroup(groupId);
      if (success) {
        _myMembership = null;
        await fetchMembers(groupId, refresh: true);
      }
      _isActionLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove Member (Admin/Mod action)
  Future<bool> removeMember({
    required String groupId,
    required String userId,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.removeMember(
        groupId: groupId,
        userId: userId,
      );
      if (success) {
        _members.removeWhere((m) => m.userId == userId || m.id == userId);
        _adminMembers.removeWhere((m) => m.userId == userId || m.id == userId);
      }
      _isActionLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update Member Status (e.g. Approve PENDING, BAN, etc.)
  Future<bool> updateMemberStatus({
    required String groupId,
    required String userId,
    required CommunityGroupMemberStatus status,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateMemberStatus(
        groupId: groupId,
        userId: userId,
        status: status,
      );

      final idx = _members.indexWhere(
        (m) => m.userId == userId || m.id == userId,
      );
      if (idx != -1) {
        _members[idx] = updated;
      }

      final adminIdx = _adminMembers.indexWhere(
        (m) => m.userId == userId || m.id == userId,
      );
      if (adminIdx != -1) {
        _adminMembers[adminIdx] = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update Member Role (Promote to MODERATOR / ADMIN / MEMBER)
  Future<bool> updateMemberRole({
    required String groupId,
    required String userId,
    required CommunityGroupMemberRole role,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateMemberRole(
        groupId: groupId,
        userId: userId,
        role: role,
      );

      final idx = _members.indexWhere(
        (m) => m.userId == userId || m.id == userId,
      );
      if (idx != -1) {
        _members[idx] = updated;
      }

      final adminIdx = _adminMembers.indexWhere(
        (m) => m.userId == userId || m.id == userId,
      );
      if (adminIdx != -1) {
        _adminMembers[adminIdx] = updated;
      } else if (updated.isAdmin || updated.isModerator) {
        _adminMembers.add(updated);
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
