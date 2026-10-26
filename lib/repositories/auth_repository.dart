import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';
import '../services/local/storage_service.dart';

class AuthRepository {
  final StorageService _storageService;
  final ApiService _apiService;

  AuthRepository(this._storageService, this._apiService);

  // Checks if user has an active session cached locally
  Future<UserModel?> getActiveSession() async {
    final token = _storageService.getToken();
    final user = _storageService.getUser();

    if (token != null && user != null) {
      return user;
    }
    return null;
  }

  // Check if session token exists
  bool get isAuthenticated => _storageService.getToken()?.isNotEmpty ?? false;
  String? getToken() => _storageService.getToken();

  // 1. Register User (POST /auth/register)
  Future<String> register({
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
    required String email,
    required String phone,
    required String address,
    required String postalCode,
    required String city,
    required String province,
    required String country,
    required String password,
    File? profilePhoto,
  }) async {
    final Map<String, String> fields = {
      'firstName': firstName,
      'lastName': lastName,
      'gender': _formatGender(gender),
      'dateOfBirth': _formatDob(dob),
      'email': email,
      'phoneNumber': _formatPhone(phone),
      'streetAddress': address,
      'postalCode': postalCode,
      'city': city,
      'province': province,
      'country': country,
      'password': password,
      'acceptTerms': 'true',
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.registerEndpoint,
      fields: fields,
      singleFile: profilePhoto,
      singleFileKey: 'profilePhoto',
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] ?? 'Registration initiated. Check your mailbox.';
  }

  // 2. Verify OTP (POST /auth/verify-otp)
  Future<UserModel> verifyOtp(String email, String otpCode) async {
    final response = await _apiService.post(ApiEndpoints.verifyOtpEndpoint, {
      'email': email,
      'otp': otpCode,
    });

    developer.log(
      'verifyOtp response status: ${response.statusCode}, body: ${response.body}',
      name: 'AuthRepository',
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    final user = UserModel.fromJson(data);

    developer.log(
      'Parsed user: ${user.email}, token length: ${user.token.length}',
      name: 'AuthRepository',
    );

    // Save session locally if token was returned
    if (user.token.isNotEmpty) {
      await _storageService.saveToken(user.token);
    }
    await _storageService.saveUser(user);

    return user;
  }

  // 3. Resend OTP (POST /auth/resend-otp)
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String purpose, // 'register' or 'reset-password'
  }) async {
    final response = await _apiService.post(ApiEndpoints.resendOtpEndpoint, {
      'email': email,
      'purpose': purpose,
    });

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  // 4. Login (POST /auth/login)
  Future<UserModel> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final String emailOrPhone = email ?? phoneNumber ?? '';
    final Map<String, dynamic> body = {
      'emailOrPhoneNumber': emailOrPhone,
      'password': password,
    };

    final response = await _apiService.post(ApiEndpoints.loginEndpoint, body);
    final Map<String, dynamic> data = jsonDecode(response.body);
    final user = UserModel.fromJson(data);

    // Cache locally
    await _storageService.saveToken(user.token);
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storageService.saveRefreshToken(refreshToken);
    }
    await _storageService.saveUser(user);

    return user;
  }

  // 5. Google Login (POST /auth/google-login)
  Future<UserModel> googleLogin(String idToken) async {
    developer.log(
      'AuthRepository: googleLogin called. Sending POST to ${ApiEndpoints.googleLoginEndpoint}...',
      name: 'AuthRepository',
    );
    try {
      final response = await _apiService.post(
        ApiEndpoints.googleLoginEndpoint,
        {'idToken': idToken},
      );
      developer.log(
        'AuthRepository: POST request finished with status ${response.statusCode}',
        name: 'AuthRepository',
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      developer.log(
        'AuthRepository: Response decoded. Parsing user model...',
        name: 'AuthRepository',
      );
      final user = UserModel.fromJson(data);
      developer.log(
        'AuthRepository: User parsed successfully. Token length: ${user.token.length}. Saving to storage...',
        name: 'AuthRepository',
      );
      await _storageService.saveToken(user.token);
      final refreshToken = data['refreshToken'] as String?;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storageService.saveRefreshToken(refreshToken);
      }
      await _storageService.saveUser(user);
      developer.log(
        'AuthRepository: Saved token and user model to storage. Returning user.',
        name: 'AuthRepository',
      );
      return user;
    } catch (e, stackTrace) {
      developer.log(
        'AuthRepository: Exception in googleLogin: $e',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // 6. Apple Login (POST /auth/apple-login)
  Future<UserModel> appleLogin(String idToken) async {
    final response = await _apiService.post(ApiEndpoints.appleLoginEndpoint, {
      'idToken': idToken,
    });
    final Map<String, dynamic> data = jsonDecode(response.body);
    final user = UserModel.fromJson(data);

    await _storageService.saveToken(user.token);
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storageService.saveRefreshToken(refreshToken);
    }
    await _storageService.saveUser(user);
    return user;
  }

  // 7. Facebook Login (POST /auth/facebook-login)
  Future<UserModel> facebookLogin(String accessToken) async {
    final response = await _apiService.post(
      ApiEndpoints.facebookLoginEndpoint,
      {'accessToken': accessToken},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    final user = UserModel.fromJson(data);

    await _storageService.saveToken(user.token);
    final refreshToken = data['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storageService.saveRefreshToken(refreshToken);
    }
    await _storageService.saveUser(user);
    return user;
  }


  // 6. Forgot Password (POST /auth/forgot-password)
  Future<String> sendResetLink(String email) async {
    final response = await _apiService.post(
      ApiEndpoints.forgotPasswordEndpoint,
      {'email': email},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] ?? 'Check your mailbox for OTP';
  }

  // 7. Reset Password (PATCH /auth/reset-password)
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.resetPasswordEndpoint,
      {'email': email, 'otp': otp, 'newPassword': newPassword},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] ?? 'Password reset successfully';
  }

  // 8. Change Password (PATCH /auth/change-password) - Authenticated
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.changePasswordEndpoint,
      {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    final newAccessToken = data['accessToken'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;
    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      await _storageService.saveToken(newAccessToken);
      final user = _storageService.getUser();
      if (user != null) {
        await _storageService.saveUser(user.copyWith(token: newAccessToken));
      }
    }
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _storageService.saveRefreshToken(newRefreshToken);
    }
    return data['message'] ?? 'Password changed successfully';
  }

  // 1. Get my profile (GET /user)
  Future<UserModel> fetchUserProfile() async {
    final response = await _apiService.get(ApiEndpoints.userProfileEndpoint);
    final Map<String, dynamic> data = jsonDecode(response.body);
    UserModel user = UserModel.fromJson(data);
    final cachedToken = _storageService.getToken() ?? '';
    if (user.token.isEmpty && cachedToken.isNotEmpty) {
      user = user.copyWith(token: cachedToken);
    }
    await updateCachedUser(user);
    return user;
  }

  // Fetch another user's profile by ID (GET /user/:id)
  Future<UserModel> fetchUserProfileById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.userProfileByIdEndpoint(id),
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    return UserModel.fromJson(data);
  }

  // 3. Edit my profile (PATCH /user - application/json)
  // Email is read-only on backend; all editable fields must be sent.
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
    String? email,
    required String phone,
    required String address,
    required String postalCode,
    required String city,
    required String province,
    required String country,
    File? profilePhoto,
    bool removeProfilePhoto = false,
  }) async {
    final Map<String, dynamic> body = {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'gender': _formatGender(gender),
      'dateOfBirth': _formatDob(dob),
      'phoneNumber': _formatPhone(phone),
      'streetAddress': address.trim(),
      'postalCode': postalCode.trim(),
      'city': city.trim(),
      'province': province.trim(),
      'country': country.trim(),
    };

    final response = await _apiService.patch(
      ApiEndpoints.userProfileEndpoint,
      body,
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    UserModel user = UserModel.fromJson(data);

    final cachedToken = _storageService.getToken() ?? '';
    if (user.token.isEmpty && cachedToken.isNotEmpty) {
      user = user.copyWith(token: cachedToken);
    }

    // If profile photo changes were requested, execute PATCH /user/profile-photo
    if (profilePhoto != null || removeProfilePhoto) {
      user = await updateProfilePhoto(
        profilePhoto: profilePhoto,
        removeProfilePhoto: removeProfilePhoto,
      );
    } else {
      await updateCachedUser(user);
    }

    return user;
  }

  // Update or Remove Profile Photo (PATCH /user/profile-photo - multipart/form-data)
  Future<UserModel> updateProfilePhoto({
    File? profilePhoto,
    bool removeProfilePhoto = false,
  }) async {
    final Map<String, String> fields = {};
    if (removeProfilePhoto) {
      fields['removeProfilePhoto'] = 'true';
    }

    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: ApiEndpoints.userProfilePhotoEndpoint,
      fields: fields,
      singleFile: profilePhoto,
      singleFileKey: 'profilePhoto',
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    final currentUser = _storageService.getUser();

    String? newPhotoUrl;
    if (data['profilePhoto'] is Map<String, dynamic>) {
      newPhotoUrl = data['profilePhoto']['url'] as String?;
      if (newPhotoUrl != null &&
          newPhotoUrl.isNotEmpty &&
          !newPhotoUrl.startsWith('http')) {
        final baseUrl = ApiEndpoints.baseUrl.endsWith('/')
            ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
            : ApiEndpoints.baseUrl;
        final path = newPhotoUrl.startsWith('/')
            ? newPhotoUrl
            : '/$newPhotoUrl';
        newPhotoUrl = '$baseUrl$path';
      }
    }

    final updatedUser = (currentUser ?? UserModel.empty()).copyWith(
      profilePhotoUrl: newPhotoUrl,
      clearProfilePhoto: newPhotoUrl == null,
    );

    await updateCachedUser(updatedUser);
    return updatedUser;
  }

  // Caches the updated user details locally
  Future<void> updateCachedUser(UserModel user) async {
    await _storageService.saveUser(user);
  }

  // Logs out user (POST /auth/logout)
  Future<void> logout() async {
    try {
      final refreshToken = _storageService.getRefreshToken() ?? '';
      await _apiService.post(ApiEndpoints.logoutEndpoint, {
        'refreshToken': refreshToken,
      });
    } catch (_) {
      // Ignore API errors on logout to ensure local session is always cleared
    } finally {
      await _storageService.clearSession();
    }
  }

  // 5. Delete my account (DELETE /user)
  Future<String> deleteAccount(String password) async {
    final response = await _apiService.delete(
      ApiEndpoints.deleteAccountEndpoint,
      body: {'password': password},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);
    await _storageService.clearSession();
    return data['message'] ?? 'Account deleted successfully';
  }

  // Check if onboarding was completed
  bool isOnboarded() {
    return _storageService.isOnboarded();
  }

  // Save onboarding completed status
  Future<bool> saveOnboarded(bool value) async {
    return await _storageService.saveOnboarded(value);
  }

  String _formatGender(String g) {
    final upper = g.trim().toUpperCase();
    if (upper == 'MALE' || upper == 'FEMALE' || upper == 'PREFER_NOT_TO_SAY') {
      return upper;
    }
    final lower = g.toLowerCase();
    return lower == 'male'
        ? 'MALE'
        : lower == 'female'
        ? 'FEMALE'
        : 'PREFER_NOT_TO_SAY';
  }

  String _formatDob(String dob) {
    final trimmed = dob.trim();
    if (trimmed.isEmpty) return trimmed;

    // Handle dd/mm/yyyy or dd/mm/yy format
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          int y = year;
          if (y < 100) {
            y += (y > (DateTime.now().year % 100)) ? 1900 : 2000;
          }
          final mStr = month.toString().padLeft(2, '0');
          final dStr = day.toString().padLeft(2, '0');
          return '$y-$mStr-$dStr';
        }
      }
    }

    // Try standard ISO or string parsing
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      final mStr = parsed.month.toString().padLeft(2, '0');
      final dStr = parsed.day.toString().padLeft(2, '0');
      return '${parsed.year}-$mStr-$dStr';
    }

    return trimmed;
  }

  String _formatPhone(String phone) {
    String cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    if (cleaned.isEmpty) return cleaned;

    // Handle 00 international prefix (e.g. 0034 -> +34)
    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    // If starts with +, ensure only digits follow
    if (cleaned.startsWith('+')) {
      final digits = cleaned.substring(1).replaceAll(RegExp(r'[^\d]'), '');
      return '+$digits';
    }

    // Pakistani numbers starting with 03 (e.g. 03001234567 -> +923001234567)
    if (cleaned.startsWith('03') && cleaned.length == 11) {
      return '+92${cleaned.substring(1)}';
    }

    // Spanish numbers: 9 digits starting with 6, 7, 8, 9 (e.g. 612345678 -> +34612345678)
    if (cleaned.length == 9 &&
        (cleaned.startsWith('6') ||
            cleaned.startsWith('7') ||
            cleaned.startsWith('8') ||
            cleaned.startsWith('9'))) {
      return '+34$cleaned';
    }

    // Numbers with country code without plus: 34... or 92...
    if (cleaned.startsWith('34') &&
        (cleaned.length == 11 || cleaned.length == 12)) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('92') && cleaned.length == 12) {
      return '+$cleaned';
    }

    // Fallback: prepend '+' to satisfy backend E.164 requirements
    return '+$cleaned';
  }
}
