import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Cache Manager supporting the Stale-While-Revalidate pattern.
/// Enables 0ms cold-start rendering across Room, Job, Marketplace, Worker, Events, and Community modules.
class CacheService {
  final SharedPreferences _prefs;

  static CacheService? _instance;
  static bool get isInitialized => _instance != null;
  static CacheService get instance {
    if (_instance == null) {
      throw StateError('CacheService has not been initialized. Call CacheService.init() first.');
    }
    return _instance!;
  }

  CacheService(this._prefs) {
    _instance = this;
  }

  static void init(SharedPreferences prefs) {
    _instance = CacheService(prefs);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cache Keys
  // ──────────────────────────────────────────────────────────────────────────
  static const String keyPropertiesPublic = 'cache_properties_public';
  static const String keyPropertiesUser = 'cache_properties_user';
  static const String keyJobsPublic = 'cache_jobs_public';
  static const String keyJobsUser = 'cache_jobs_user';
  static const String keyMarketplacePublic = 'cache_marketplace_public';
  static const String keyMarketplaceMyAds = 'cache_marketplace_my_ads';
  static const String keyWorkersPublic = 'cache_workers_public';
  static const String keyNeedWorkersFeed = 'cache_need_workers_feed';
  static const String keyEventsPublic = 'cache_events_public';
  static const String keyCommunityFeed = 'cache_community_feed';
  static const String keyCommunityMyPosts = 'cache_community_my_posts';
  static const String keyCommunityMyComments = 'cache_community_my_comments';

  // ──────────────────────────────────────────────────────────────────────────
  // List Caching
  // ──────────────────────────────────────────────────────────────────────────

  /// Saves a list of JSON maps to cache with an envelope containing the timestamp.
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> items) async {
    try {
      final envelope = {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'count': items.length,
        'data': items,
      };
      final jsonString = jsonEncode(envelope);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('[CacheService] Error saving list for key $key: $e');
      return false;
    }
  }

  /// Retrieves a list of JSON maps from cache.
  /// If [maxAge] is provided, returns null if cached data is older than [maxAge].
  /// Otherwise, returns cached data regardless of age (Stale-While-Revalidate).
  List<Map<String, dynamic>>? getJsonList(String key, {Duration? maxAge}) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      if (maxAge != null && decoded['cachedAt'] is int) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(decoded['cachedAt'] as int);
        if (DateTime.now().difference(cachedAt) > maxAge) {
          return null; // Expired
        }
      }

      final dataList = decoded['data'];
      if (dataList is List) {
        return dataList
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint('[CacheService] Error reading list for key $key: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Single Map Caching
  // ──────────────────────────────────────────────────────────────────────────

  /// Saves a single JSON map to cache.
  Future<bool> saveJsonMap(String key, Map<String, dynamic> item) async {
    try {
      final envelope = {
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'data': item,
      };
      final jsonString = jsonEncode(envelope);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('[CacheService] Error saving map for key $key: $e');
      return false;
    }
  }

  /// Retrieves a single JSON map from cache.
  Map<String, dynamic>? getJsonMap(String key, {Duration? maxAge}) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      if (maxAge != null && decoded['cachedAt'] is int) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(decoded['cachedAt'] as int);
        if (DateTime.now().difference(cachedAt) > maxAge) {
          return null;
        }
      }

      return decoded['data'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[CacheService] Error reading map for key $key: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Cache Eviction & Cleanup
  // ──────────────────────────────────────────────────────────────────────────

  /// Removes a specific cached entry by key.
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      debugPrint('[CacheService] Error removing key $key: $e');
      return false;
    }
  }

  /// Clears all cached module data while preserving user authentication & session settings.
  Future<void> clearModuleCaches() async {
    final moduleKeys = [
      keyPropertiesPublic,
      keyPropertiesUser,
      keyJobsPublic,
      keyJobsUser,
      keyMarketplacePublic,
      keyMarketplaceMyAds,
      keyWorkersPublic,
      keyNeedWorkersFeed,
      keyEventsPublic,
      keyCommunityFeed,
      keyCommunityMyPosts,
      keyCommunityMyComments,
    ];
    for (final k in moduleKeys) {
      await _prefs.remove(k);
    }
  }
}
