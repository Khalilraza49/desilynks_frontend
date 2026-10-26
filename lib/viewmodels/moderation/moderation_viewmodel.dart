import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desilynks/models/moderation_models.dart';
import 'package:desilynks/repositories/moderation_repository.dart';

class ModerationViewModel extends ChangeNotifier {
  final ModerationRepository _repository;

  ModerationViewModel(this._repository);

  final List<BlockedUserModel> _blockedUsers = [];
  final Set<String> _blockedUserIds = {};

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmittingReport = false;
  bool _isProcessingBlock = false;
  String? _errorMessage;
  String? _successMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalBlocked = 0;

  // Getters
  List<BlockedUserModel> get blockedUsers => List.unmodifiable(_blockedUsers);
  Set<String> get blockedUserIds => Set.unmodifiable(_blockedUserIds);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmittingReport => _isSubmittingReport;
  bool get isProcessingBlock => _isProcessingBlock;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalBlocked => _totalBlocked;
  bool get hasMore => _currentPage < _totalPages;

  bool isUserBlocked(String userId) => _blockedUserIds.contains(userId);

  /// Fetch Blocked Users (GET /block)
  Future<void> fetchBlockedUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _totalPages = 1;
    }

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getBlockedUsers(
        page: _currentPage,
        limit: 20,
      );

      if (_currentPage == 1) {
        _blockedUsers.clear();
        _blockedUserIds.clear();
      }

      _blockedUsers.addAll(result.data);
      for (final u in result.data) {
        _blockedUserIds.add(u.id);
      }

      _totalBlocked = result.total;
      _totalPages = result.totalPages;
      _currentPage = result.page;
    } on HttpException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load Next Page of Blocked Users
  Future<void> loadMoreBlockedUsers() async {
    if (_isLoadingMore || !hasMore) return;
    _currentPage++;
    await fetchBlockedUsers();
  }

  /// Block a User (POST /block/:userId)
  Future<bool> blockUser(String userId) async {
    if (userId.isEmpty) return false;

    _isProcessingBlock = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.blockUser(userId);
      if (success) {
        _blockedUserIds.add(userId);
      }
      return success;
    } on HttpException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isProcessingBlock = false;
      notifyListeners();
    }
  }

  /// Unblock a User (DELETE /block/:userId)
  Future<bool> unblockUser(String userId) async {
    if (userId.isEmpty) return false;

    _isProcessingBlock = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final unblocked = await _repository.unblockUser(userId);
      if (unblocked) {
        _blockedUserIds.remove(userId);
        _blockedUsers.removeWhere((u) => u.id == userId);
        if (_totalBlocked > 0) _totalBlocked--;
      }
      return unblocked;
    } on HttpException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isProcessingBlock = false;
      notifyListeners();
    }
  }

  /// Submit Content Report (POST /report)
  Future<String?> submitReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    _isSubmittingReport = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final msg = await _repository.reportContent(
        targetType: targetType,
        targetId: targetId,
        reason: reason,
        details: details,
      );
      _successMessage = msg;
      return msg;
    } on HttpException catch (e) {
      // 409 means user already reported this item
      if (e.message.toLowerCase().contains('already reported')) {
        _successMessage = "You've already reported this";
        return _successMessage;
      }
      _errorMessage = e.message;
      return null;
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (err.toLowerCase().contains('already reported')) {
        _successMessage = "You've already reported this";
        return _successMessage;
      }
      _errorMessage = err;
      return null;
    } finally {
      _isSubmittingReport = false;
      notifyListeners();
    }
  }

  void clearStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
