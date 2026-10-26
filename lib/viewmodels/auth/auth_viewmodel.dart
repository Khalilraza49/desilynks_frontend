import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/property_model.dart';
import '../../repositories/auth_repository.dart';
import '../../core/constants/app_strings.dart';
import '../../services/chat_socket_service.dart';
import '../../services/notification_socket_service.dart';
import '../../services/awesome_notification_service.dart';
import '../../services/background_sync_service.dart';
import '../../services/api/chat_service.dart';
import '../../services/local/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ChatSocketService? _chatSocketService;
  final NotificationSocketService? _notificationSocketService;
  final ChatApiService? _chatApiService;
  final StorageService? _storageService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _registrationEmail;
  String? _registrationPassword;
  int _resendsRemaining = 5;
  bool _availableForHire = true;
  int _loyaltyPoints = 1250;

  // Public Profile State
  UserModel? _publicUserProfile;
  String _publicProfileActiveTab = 'Overview';
  final Set<String> _publicProfileLikedPosts = {};
  String? _currentPublicOwnerId;
  bool _isLoadingPublicProfile = false;

  AuthViewModel(
    this._authRepository, {
    ChatSocketService? chatSocketService,
    NotificationSocketService? notificationSocketService,
    ChatApiService? chatApiService,
    StorageService? storageService,
  })  : _chatSocketService = chatSocketService,
        _notificationSocketService = notificationSocketService,
        _chatApiService = chatApiService,
        _storageService = storageService {
    _currentUser = _storageService?.getUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnboarded => _authRepository.isOnboarded();
  bool get isAvailableForHire => _availableForHire;
  int get loyaltyPoints => _loyaltyPoints;
  int get resendsRemaining => _resendsRemaining;
  UserModel? get publicUserProfile => _publicUserProfile;
  String get publicProfileActiveTab => _publicProfileActiveTab;
  Set<String> get publicProfileLikedPosts => _publicProfileLikedPosts;
  bool get isLoadingPublicProfile => _isLoadingPublicProfile;

  void setAvailableForHire(bool value) {
    _availableForHire = value;
    notifyListeners();
  }

  void setPublicProfileActiveTab(String tab) {
    _publicProfileActiveTab = tab;
    notifyListeners();
  }

  void togglePublicProfilePostLike(String postId) {
    if (_publicProfileLikedPosts.contains(postId)) {
      _publicProfileLikedPosts.remove(postId);
    } else {
      _publicProfileLikedPosts.add(postId);
    }
    notifyListeners();
  }

  bool shouldInitPublicProfile(PropertyOwner owner) {
    final String ownerKey =
        owner.id.isNotEmpty ? owner.id : owner.fullName.trim();
    if (_isLoadingPublicProfile) return false;
    if (_currentPublicOwnerId == ownerKey && _publicUserProfile != null) {
      return false;
    }
    if (_currentPublicOwnerId == ownerKey && owner.id.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> initPublicProfile(PropertyOwner owner) async {
    final String ownerKey =
        owner.id.isNotEmpty ? owner.id : owner.fullName.trim();
    if (!shouldInitPublicProfile(owner)) return;

    _isLoadingPublicProfile = true;
    _currentPublicOwnerId = ownerKey;
    _publicProfileActiveTab = 'Overview';

    final currentUserId = _currentUser?.id;
    final bool isCurrentUser =
        currentUserId != null &&
        (owner.id == currentUserId ||
            (owner.id.isEmpty &&
                owner.fullName.trim() == _currentUser?.username));

    if (isCurrentUser && _currentUser != null) {
      _publicUserProfile = _currentUser;
      _isLoadingPublicProfile = false;
      notifyListeners();
      return;
    }

    if (owner.id.isEmpty) {
      _isLoadingPublicProfile = false;
      _publicUserProfile = null;
      notifyListeners();
      return;
    }

    try {
      final profile = await fetchUserProfileById(owner.id);
      if (profile != null) {
        if (isCurrentUser &&
            profile.address == null &&
            _currentUser?.address != null) {
          _publicUserProfile = profile.copyWith(
            address: _currentUser!.address,
          );
        } else {
          _publicUserProfile = profile;
        }
      }
    } catch (e) {
      debugPrint('Error fetching public user profile: $e');
    } finally {
      _isLoadingPublicProfile = false;
      notifyListeners();
    }
  }

  bool redeemLoyaltyPoints(int pointsCost) {
    if (_loyaltyPoints >= pointsCost) {
      _loyaltyPoints -= pointsCost;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Helper to execute async actions with uniform loading/error handling
  Future<T?> _runAsync<T>(Future<T> Function() action) async {
    _setLoading(true);
    _clearStatus();
    try {
      return await action();
    } catch (e, stackTrace) {
      developer.log(
        'AuthViewModel error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _connectSockets() {
    final token = _storageService?.getToken();
    if (token != null && token.isNotEmpty) {
      final currentUserId = _currentUser?.id ?? _storageService?.getUser()?.id;
      _chatSocketService?.connect(token, currentUserId: currentUserId);
      _notificationSocketService?.connect(
        token,
        currentUserId: currentUserId,
      );
      AwesomeNotificationService.instance.requestPermission();
      BackgroundSyncService.instance.updateToken(token, userId: currentUserId);
    }
  }

  Future<bool> checkSession() async {
    final user = await _runAsync(() => _authRepository.getActiveSession());
    if (user != null) {
      _currentUser = user;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final isEmail = email.contains('@');
    final user = await _runAsync(
      () => _authRepository.login(
        email: isEmail ? email : null,
        phoneNumber: !isEmail ? email : null,
        password: password,
      ),
    );
    if (user != null) {
      _currentUser = user;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> googleLogin(String idToken) async {
    final user = await _runAsync(() => _authRepository.googleLogin(idToken));
    if (user != null) {
      _currentUser = user;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> appleLogin(String idToken) async {
    final user = await _runAsync(() => _authRepository.appleLogin(idToken));
    if (user != null) {
      _currentUser = user;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> facebookLogin(String accessToken) async {
    final user = await _runAsync(
      () => _authRepository.facebookLogin(accessToken),
    );
    if (user != null) {
      _currentUser = user;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final fcmToken = _storageService?.getFcmToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      try {
        await _chatApiService?.removeFcmToken(fcmToken);
      } catch (_) {}
      await _storageService?.deleteFcmToken();
    }
    _chatSocketService?.disconnect();
    _notificationSocketService?.disconnect();
    BackgroundSyncService.instance.stop();

    await _runAsync(() => _authRepository.logout());
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> deleteAccount(String password) async {
    final result =
        await _runAsync(() => _authRepository.deleteAccount(password));
    if (result != null) {
      final fcmToken = _storageService?.getFcmToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        try {
          await _chatApiService?.removeFcmToken(fcmToken);
        } catch (_) {}
        await _storageService?.deleteFcmToken();
      }
      _chatSocketService?.disconnect();
      _notificationSocketService?.disconnect();
      BackgroundSyncService.instance.stop();
      _currentUser = null;
      _successMessage = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  void handleSessionExpired() {
    _chatSocketService?.disconnect();
    _notificationSocketService?.disconnect();
    BackgroundSyncService.instance.stop();
    _currentUser = null;
    _errorMessage = 'Session expired. Please log in again.';
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _authRepository.saveOnboarded(true);
    notifyListeners();
  }

  Future<bool> register({
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
    _registrationEmail = email.trim();
    _registrationPassword = password;

    final msg = await _runAsync(
      () => _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
        email: email,
        phone: phone,
        address: address,
        postalCode: postalCode,
        city: city,
        province: province,
        country: country,
        password: password,
        profilePhoto: profilePhoto,
      ),
    );
    if (msg != null) {
      _successMessage = msg;
      return true;
    }
    return false;
  }

  Future<bool> sendResetLink(String emailOrPhone) async {
    final msg = await _runAsync(
      () => _authRepository.sendResetLink(emailOrPhone),
    );
    if (msg != null) {
      _successMessage = msg;
      return true;
    }
    return false;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final msg = await _runAsync(
      () => _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      ),
    );
    if (msg != null) {
      _successMessage = msg;
      return true;
    }
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final msg = await _runAsync(
      () => _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    if (msg != null) {
      _successMessage = msg;
      return true;
    }
    return false;
  }

  Future<bool> verifyOtp(String code, {String? email, String? password}) async {
    final targetEmail = (email != null && email.isNotEmpty)
        ? email.trim()
        : (_registrationEmail ?? _currentUser?.email ?? '');
    final targetPassword = (password != null && password.isNotEmpty)
        ? password
        : _registrationPassword;

    if (targetEmail.isEmpty) {
      _setError(AppStrings.errEmailContextNotFound);
      return false;
    }

    final user = await _runAsync(() async {
      // Step 1: Confirm OTP & create account
      final u = await _authRepository.verifyOtp(targetEmail, code);
      // Step 2: Seamless auto-login to obtain session tokens
      if (targetPassword != null && targetPassword.isNotEmpty) {
        try {
          return await _authRepository.login(
            email: targetEmail,
            password: targetPassword,
          );
        } catch (e) {
          developer.log(
            'Auto-login after verifyOtp failed: $e',
            name: 'AuthViewModel',
          );
        }
      }
      return u;
    });

    if (user != null) {
      _currentUser = user;
      _registrationPassword = null;
      _connectSockets();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resendOtp({
    String? email,
    String purpose = 'register',
  }) async {
    final targetEmail = (email != null && email.isNotEmpty)
        ? email.trim()
        : (_registrationEmail ?? _currentUser?.email ?? '');

    if (targetEmail.isEmpty) {
      _setError(AppStrings.errEmailContextNotFound);
      return false;
    }

    final data = await _runAsync(
      () => _authRepository.resendOtp(
        email: targetEmail,
        purpose: purpose,
      ),
    );

    if (data != null) {
      if (data['resendsRemaining'] is int) {
        _resendsRemaining = data['resendsRemaining'] as int;
      }
      _successMessage =
          data['message'] as String? ?? AppStrings.verificationCodeResent;
      startVerifyCountdown(60);
      return true;
    }
    return false;
  }

  Future<bool> fetchUserProfile() async {
    final user = await _runAsync(() => _authRepository.fetchUserProfile());
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<UserModel?> fetchUserProfileById(String id) async {
    try {
      return await _authRepository.fetchUserProfileById(id);
    } catch (e) {
      debugPrint('Error fetching user profile by id $id: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    required String phone,
    required String gender,
    required String dob,
    required String location,
    String? postalCode,
    String? city,
    String? province,
    String? country,
    File? profilePhoto,
    bool removeProfilePhoto = false,
  }) async {
    final updatedUser = await _runAsync(
      () => _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dob: dob,
        email: email,
        phone: phone,
        address: location,
        postalCode: postalCode ?? _currentUser?.address?.postalCode ?? '',
        city: city ?? _currentUser?.address?.city ?? '',
        province: province ?? _currentUser?.address?.province ?? '',
        country: country ?? _currentUser?.address?.country ?? '',
        profilePhoto: profilePhoto,
        removeProfilePhoto: removeProfilePhoto,
      ),
    );
    if (updatedUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateProfilePhoto({
    File? profilePhoto,
    bool removeProfilePhoto = false,
  }) async {
    final updatedUser = await _runAsync(
      () => _authRepository.updateProfilePhoto(
        profilePhoto: profilePhoto,
        removeProfilePhoto: removeProfilePhoto,
      ),
    );
    if (updatedUser != null) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearStatus() {
    _errorMessage = null;
    _successMessage = null;
  }

  // ===========================================================================
  // AUTH FORM CONTROLLERS & LOCAL UI STATE
  // ===========================================================================

  // ─── Login ───
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool get loginObscurePassword => _loginObscurePassword;
  void toggleLoginObscurePassword() {
    _loginObscurePassword = !_loginObscurePassword;
    notifyListeners();
  }

  bool _loginRememberMe = false;
  bool get loginRememberMe => _loginRememberMe;
  void toggleLoginRememberMe() {
    _loginRememberMe = !_loginRememberMe;
    notifyListeners();
  }

  // ─── Register ───
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController registerFirstNameController =
      TextEditingController();
  final TextEditingController registerLastNameController =
      TextEditingController();
  final TextEditingController registerDobController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerAddressController =
      TextEditingController();
  final TextEditingController registerPostalController =
      TextEditingController();
  final TextEditingController registerCityController = TextEditingController();
  final TextEditingController registerProvinceController =
      TextEditingController();
  final TextEditingController registerCountryController =
      TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();
  final TextEditingController registerGenderController =
      TextEditingController(text: 'Select');

  bool _registerObscurePassword = true;
  bool get registerObscurePassword => _registerObscurePassword;
  void toggleRegisterObscurePassword() {
    _registerObscurePassword = !_registerObscurePassword;
    notifyListeners();
  }

  bool _registerObscureConfirmPassword = true;
  bool get registerObscureConfirmPassword => _registerObscureConfirmPassword;
  void toggleRegisterObscureConfirmPassword() {
    _registerObscureConfirmPassword = !_registerObscureConfirmPassword;
    notifyListeners();
  }

  bool _registerAcceptedTerms = false;
  bool get registerAcceptedTerms => _registerAcceptedTerms;
  void toggleRegisterAcceptedTerms() {
    _registerAcceptedTerms = !_registerAcceptedTerms;
    notifyListeners();
  }

  void clearRegisterForm() {
    registerFirstNameController.clear();
    registerLastNameController.clear();
    registerDobController.clear();
    registerEmailController.clear();
    registerPhoneController.clear();
    registerAddressController.clear();
    registerPostalController.clear();
    registerCityController.clear();
    registerProvinceController.clear();
    registerCountryController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerGenderController.text = 'Select';
    _registerObscurePassword = true;
    _registerObscureConfirmPassword = true;
    _registerAcceptedTerms = false;
  }

  // ─── Forgot Password ───
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  // ─── Reset Password ───
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController resetOtpController = TextEditingController();
  final TextEditingController resetPasswordController = TextEditingController();
  final TextEditingController resetConfirmPasswordController =
      TextEditingController();

  bool _resetObscurePassword = true;
  bool get resetObscurePassword => _resetObscurePassword;
  void toggleResetObscurePassword() {
    _resetObscurePassword = !_resetObscurePassword;
    notifyListeners();
  }

  bool _resetObscureConfirmPassword = true;
  bool get resetObscureConfirmPassword => _resetObscureConfirmPassword;
  void toggleResetObscureConfirmPassword() {
    _resetObscureConfirmPassword = !_resetObscureConfirmPassword;
    notifyListeners();
  }

  // ─── Verify ───
  final List<TextEditingController> verifyOtpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> verifyOtpFocusNodes =
      List.generate(6, (_) => FocusNode());
  Timer? _verifyTimer;
  int _verifyResendCountdown = 60;
  int get verifyResendCountdown => _verifyResendCountdown;

  void startVerifyCountdown([int seconds = 60]) {
    _verifyResendCountdown = seconds;
    notifyListeners();
    _verifyTimer?.cancel();
    _verifyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_verifyResendCountdown <= 0) {
        _verifyTimer?.cancel();
      } else {
        _verifyResendCountdown--;
        notifyListeners();
      }
    });
  }

  void cancelVerifyTimer() {
    _verifyTimer?.cancel();
  }

  void setVerifyResendCountdown(int value) {
    _verifyResendCountdown = value;
    notifyListeners();
  }

  bool _isVerifyTimerInitialized = false;
  void initVerifyScreen() {
    if (!_isVerifyTimerInitialized) {
      _isVerifyTimerInitialized = true;
      startVerifyCountdown(60);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (verifyOtpFocusNodes.isNotEmpty &&
            verifyOtpFocusNodes[0].canRequestFocus) {
          verifyOtpFocusNodes[0].requestFocus();
        }
      });
    }
  }

  void resetVerifyState() {
    _isVerifyTimerInitialized = false;
    _verifyTimer?.cancel();
    _verifyResendCountdown = 60;
    clearOtpFields();
  }

  void clearOtpFields() {
    for (final c in verifyOtpControllers) {
      c.clear();
    }
  }

  // ─── Create Profile ───
  final GlobalKey<FormState> createProfileFormKey = GlobalKey<FormState>();
  final TextEditingController profileFirstNameController =
      TextEditingController();
  final TextEditingController profileLastNameController =
      TextEditingController();
  final TextEditingController profilePhoneController = TextEditingController();
  final TextEditingController profileEmailController = TextEditingController();
  final TextEditingController profileGenderController =
      TextEditingController(text: 'Select');
  final TextEditingController profileDobController = TextEditingController();
  final TextEditingController profileLocationController =
      TextEditingController();
  final TextEditingController profileAddressController =
      TextEditingController();
  final TextEditingController profileCityController = TextEditingController();
  final TextEditingController profileProvinceController =
      TextEditingController();
  final TextEditingController profilePostalCodeController =
      TextEditingController();
  final TextEditingController profileCountryController =
      TextEditingController();

  File? _profileSelectedImage;
  File? get profileSelectedImage => _profileSelectedImage;
  void setProfileSelectedImage(File? file) {
    _profileSelectedImage = file;
    notifyListeners();
  }

  bool _isCreateProfileInitialized = false;
  void initCreateProfile(Map<String, dynamic>? registrationData) {
    if (!_isCreateProfileInitialized) {
      _isCreateProfileInitialized = true;
      final String firstName =
          registrationData?['firstName'] as String? ?? '';
      final String lastName =
          registrationData?['lastName'] as String? ?? '';
      final String phone = registrationData?['phone'] as String? ?? '';
      final String email = registrationData?['email'] as String? ?? '';
      final String gender =
          registrationData?['gender'] as String? ?? 'Select';
      final String dob = registrationData?['dob'] as String? ?? '';

      String location = '';
      if (registrationData != null) {
        final city = registrationData['city'] as String? ?? '';
        final country = registrationData['country'] as String? ?? '';
        if (city.isNotEmpty && country.isNotEmpty) {
          location = '$city , $country';
        } else if (city.isNotEmpty) {
          location = city;
        } else if (country.isNotEmpty) {
          location = country;
        }
      }

      profileFirstNameController.text = firstName;
      profileLastNameController.text = lastName;
      profilePhoneController.text = phone;
      profileEmailController.text = email;
      profileGenderController.text = gender;
      profileDobController.text = dob;
      profileLocationController.text = location;
    }
  }

  void clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
    _loginObscurePassword = true;
    _loginRememberMe = false;
  }

  void clearForgotPasswordForm() {
    forgotPasswordEmailController.clear();
  }

  void clearResetPasswordForm() {
    resetOtpController.clear();
    resetPasswordController.clear();
    resetConfirmPasswordController.clear();
    _resetObscurePassword = true;
    _resetObscureConfirmPassword = true;
  }

  void clearCreateProfileForm() {
    _isCreateProfileInitialized = false;
    profileFirstNameController.clear();
    profileLastNameController.clear();
    profilePhoneController.clear();
    profileEmailController.clear();
    profileGenderController.text = 'Select';
    profileDobController.clear();
    profileLocationController.clear();
    profileAddressController.clear();
    profileCityController.clear();
    profileProvinceController.clear();
    profilePostalCodeController.clear();
    profileCountryController.clear();
    _profileSelectedImage = null;
  }

  @override
  void dispose() {
    _verifyTimer?.cancel();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerFirstNameController.dispose();
    registerLastNameController.dispose();
    registerDobController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerAddressController.dispose();
    registerPostalController.dispose();
    registerCityController.dispose();
    registerProvinceController.dispose();
    registerCountryController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerGenderController.dispose();
    forgotPasswordEmailController.dispose();
    resetOtpController.dispose();
    resetPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    for (final c in verifyOtpControllers) {
      c.dispose();
    }
    for (final n in verifyOtpFocusNodes) {
      n.dispose();
    }
    profileFirstNameController.dispose();
    profileLastNameController.dispose();
    profilePhoneController.dispose();
    profileEmailController.dispose();
    profileGenderController.dispose();
    profileDobController.dispose();
    profileLocationController.dispose();
    profileAddressController.dispose();
    profileCityController.dispose();
    profileProvinceController.dispose();
    profilePostalCodeController.dispose();
    profileCountryController.dispose();
    super.dispose();
  }
}
