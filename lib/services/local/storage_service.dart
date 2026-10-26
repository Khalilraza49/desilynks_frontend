import 'dart:convert';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Save authentication token
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(AppStrings.keyUserToken, token);
  }

  // Get authentication token
  String? getToken() {
    return _prefs.getString(AppStrings.keyUserToken);
  }

  // Delete token
  Future<bool> deleteToken() async {
    return await _prefs.remove(AppStrings.keyUserToken);
  }

  // Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(AppStrings.keyRefreshToken, token);
  }

  // Get refresh token
  String? getRefreshToken() {
    return _prefs.getString(AppStrings.keyRefreshToken);
  }

  // Delete refresh token
  Future<bool> deleteRefreshToken() async {
    return await _prefs.remove(AppStrings.keyRefreshToken);
  }

  // Save FCM token
  Future<bool> saveFcmToken(String token) async {
    return await _prefs.setString(AppStrings.keyFcmToken, token);
  }

  // Get FCM token
  String? getFcmToken() {
    return _prefs.getString(AppStrings.keyFcmToken);
  }

  // Delete FCM token
  Future<bool> deleteFcmToken() async {
    return await _prefs.remove(AppStrings.keyFcmToken);
  }

  // Save full user model data
  Future<bool> saveUser(UserModel user) async {
    final String userJson = jsonEncode(user.toJson());
    return await _prefs.setString(AppStrings.keyUserData, userJson);
  }

  // Get full user model data
  UserModel? getUser() {
    final String? userJson = _prefs.getString(AppStrings.keyUserData);
    if (userJson == null) return null;
    try {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }

  // Clear all persisted session data on logout
  Future<void> clearSession() async {
    await _prefs.remove(AppStrings.keyUserToken);
    await _prefs.remove(AppStrings.keyRefreshToken);
    await _prefs.remove(AppStrings.keyUserData);
  }

  // Save onboarding completion status
  Future<bool> saveOnboarded(bool value) async {
    return await _prefs.setBool(AppStrings.keyIsOnboarded, value);
  }

  // Check if user has completed onboarding
  bool isOnboarded() {
    return _prefs.getBool(AppStrings.keyIsOnboarded) ?? false;
  }
}
