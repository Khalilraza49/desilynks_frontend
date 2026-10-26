import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_icons.dart';
import '../../models/need_worker_enums.dart';
import '../../models/need_worker_model.dart';
import '../../models/user_model.dart';
import '../../models/worker_profile_model.dart';
import '../../repositories/worker_repository.dart';
import 'need_worker_viewmodel.dart';
import 'post_room_viewmodel.dart';
import '../categories/categories_viewmodel.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/local/cache_service.dart';

class WorkerViewModel extends ChangeNotifier {
  final WorkerRepository _workerRepository;

  WorkerViewModel(this._workerRepository) {
    _initControllers();
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    try {
      final cached = CacheService.instance.getJsonList(
        CacheService.keyWorkersPublic,
      );
      if (cached != null && cached.isNotEmpty) {
        _publicProfiles = cached
            .map((json) => WorkerProfileModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('[WorkerViewModel] Hydration error: $e');
    }
  }

  void _persistWorkers() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyWorkersPublic,
        _publicProfiles.take(30).map((w) => w.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _initControllers() {
    workerHourlyRateController.addListener(notifyListeners);
    workerDailyRateController.addListener(notifyListeners);
    workerAreaCoveredController.addListener(notifyListeners);
    workerAboutMeController.addListener(notifyListeners);
    workerSearchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = workerSearchController.text.trim().toLowerCase();
    if (_workerSearchQuery != query) {
      _workerSearchQuery = query;
      notifyListeners();
    }
  }

  // ===========================================================================
  // BASE STATE & MESSAGES
  // ===========================================================================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  WorkerProfileModel? _currentProfile;
  WorkerProfileModel? get currentProfile => _currentProfile;

  List<WorkerProfileModel> _publicProfiles = [];
  List<WorkerProfileModel> get publicProfiles => _publicProfiles;

  bool _isHireSubmitting = false;
  bool get isHireSubmitting => _isHireSubmitting;
  void setIsHireSubmitting(bool value) {
    _isHireSubmitting = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<T?> _runAsync<T>(Future<T> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      final msg = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('HttpException: ', '');
      if (msg.contains('413') || msg.toLowerCase().contains('too large')) {
        _errorMessage = msg.contains('MB')
            ? msg
            : 'Selected image/file size is too large. Please compress your photos before uploading.';
      } else {
        _errorMessage = msg;
      }
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // HIRE WORKERS FEED / SEARCH / FILTERS STATE & LOGIC
  // ===========================================================================
  final TextEditingController workerSearchController = TextEditingController();
  String _workerSearchQuery = '';
  String get workerSearchQuery => _workerSearchQuery;

  String _selectedWorkerCategory = 'All';
  String get selectedWorkerCategory => _selectedWorkerCategory;

  bool _hireWorkersInitialized = false;
  bool get hireWorkersInitialized => _hireWorkersInitialized;

  void initHireWorkersView({bool forceRefresh = false}) {
    if (!_hireWorkersInitialized || forceRefresh) {
      _hireWorkersInitialized = true;
      fetchPublicWorkerProfiles();
    }
  }

  void setSelectedWorkerCategory(String category, {bool fetch = true}) {
    _selectedWorkerCategory = category;
    notifyListeners();
    if (fetch) {
      final serviceFilter = category == 'All' ? null : category.toUpperCase();
      fetchPublicWorkerProfiles(service: serviceFilter);
    }
  }

  void resetWorkerFilters(PostRoomViewModel roomViewModel) {
    roomViewModel.resetFilters();
    workerSearchController.clear();
    _workerSearchQuery = '';
    _selectedWorkerCategory = 'All';
    notifyListeners();
    fetchPublicWorkerProfiles();
  }

  String getUserLocation(UserModel? user) {
    if (user == null || user.address == null) return 'Barcelona, Spain';
    final addr = user.address!;
    final parts = <String>[];
    if (addr.city != null && addr.city!.trim().isNotEmpty) {
      parts.add(addr.city!.trim());
    } else if (addr.province != null && addr.province!.trim().isNotEmpty) {
      parts.add(addr.province!.trim());
    }
    if (addr.country != null && addr.country!.trim().isNotEmpty) {
      parts.add(addr.country!.trim());
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Barcelona, Spain';
  }

  double? extractRateNumber(String rateStr) {
    if (rateStr.trim().isEmpty) return null;
    final cleaned = rateStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  List<WorkerProfileModel> getFilteredWorkers(PostRoomViewModel roomViewModel) {
    final hasFilters = roomViewModel.isFilterApplied;
    final maxRate = roomViewModel.appliedMaxWorkerRate;
    final availableTodayOnly = roomViewModel.appliedAvailableTodayOnly;
    final hasVehicleOnly = roomViewModel.appliedHasVehicleOnly;
    final hasToolsOnly = roomViewModel.appliedHasToolsOnly;
    final minExp = roomViewModel.appliedMinExperience;
    final filterLocation = roomViewModel.appliedLocation.trim().toLowerCase();
    final sortBy = roomViewModel.appliedSortBy;

    final filtered = _publicProfiles.where((p) {
      // 1. Search Query
      if (_workerSearchQuery.isNotEmpty) {
        final nameMatches = p.name.toLowerCase().contains(_workerSearchQuery);
        final profMatches = p.profession.toLowerCase().contains(
          _workerSearchQuery,
        );
        final aboutMatches = p.aboutMe.toLowerCase().contains(
          _workerSearchQuery,
        );
        final skillMatches = p.skills.any(
          (s) => s.toLowerCase().contains(_workerSearchQuery),
        );
        if (!nameMatches && !profMatches && !aboutMatches && !skillMatches) {
          return false;
        }
      }

      // 2. Category Filter
      final categoryFilter = _selectedWorkerCategory;
      if (categoryFilter != 'All') {
        if (p.profession.toLowerCase() != categoryFilter.toLowerCase()) {
          return false;
        }
      }

      // 3. Location Filter
      if (hasFilters &&
          filterLocation.isNotEmpty &&
          filterLocation != 'madrid, spain') {
        if (!p.areaCovered.toLowerCase().contains(filterLocation)) {
          return false;
        }
      }

      // 4. Hourly Rate Filter
      if (hasFilters && maxRate < 150.0) {
        final rateNum = extractRateNumber(p.hourlyRate);
        if (rateNum != null && rateNum > maxRate) {
          return false;
        }
      }

      // 5. Availability Filter
      if (hasFilters && availableTodayOnly && !p.isAvailableToday) {
        return false;
      }

      // 6. Has Vehicle Filter
      if (hasFilters && hasVehicleOnly && !p.hasVehicle) {
        return false;
      }

      // 7. Has Tools Filter
      if (hasFilters && hasToolsOnly && !p.hasTools) {
        return false;
      }

      // 8. Minimum Experience Filter
      if (hasFilters && minExp > 0 && p.yearsOfExperience < minExp) {
        return false;
      }

      return true;
    }).toList();

    // 9. Sorting
    if (sortBy == 'Price: Low to High') {
      filtered.sort((a, b) {
        final rA = extractRateNumber(a.hourlyRate) ?? 0.0;
        final rB = extractRateNumber(b.hourlyRate) ?? 0.0;
        return rA.compareTo(rB);
      });
    } else if (sortBy == 'Price: High to Low') {
      filtered.sort((a, b) {
        final rA = extractRateNumber(a.hourlyRate) ?? 0.0;
        final rB = extractRateNumber(b.hourlyRate) ?? 0.0;
        return rB.compareTo(rA);
      });
    } else if (sortBy == 'Most Experienced') {
      filtered.sort(
        (a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience),
      );
    } else if (sortBy == 'Newest First') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  // ===========================================================================
  // POST / EDIT WORKER PROFILE STATE & OPERATIONS
  // ===========================================================================
  final GlobalKey<FormState> postWorkerProfileFormKey = GlobalKey<FormState>();

  final TextEditingController workerHourlyRateController =
      TextEditingController();
  final TextEditingController workerDailyRateController =
      TextEditingController();
  final TextEditingController workerAreaCoveredController =
      TextEditingController();
  final TextEditingController workerAboutMeController = TextEditingController();

  String? _profileSelectedProfession;
  String? get profileSelectedProfession => _profileSelectedProfession;

  int _profileYearsOfExperience = 1;
  int get profileYearsOfExperience => _profileYearsOfExperience;

  final List<String> _profileSelectedLanguages = ['Urdu'];
  List<String> get profileSelectedLanguages =>
      List.unmodifiable(_profileSelectedLanguages);

  bool _profileIsAvailableToday = true;
  bool get profileIsAvailableToday => _profileIsAvailableToday;

  bool _profileHasVehicle = false;
  bool get profileHasVehicle => _profileHasVehicle;

  bool _profileHasTools = false;
  bool get profileHasTools => _profileHasTools;

  File? _profilePhotoFile;
  File? get profilePhotoFile => _profilePhotoFile;

  List<File> _workPhotoFiles = [];
  List<File> get workPhotoFiles => List.unmodifiable(_workPhotoFiles);

  final List<File> _certificateFiles = [];
  List<File> get certificateFiles => List.unmodifiable(_certificateFiles);

  final ImagePicker _picker = ImagePicker();
  bool _postProfileFormInitialized = false;
  String? _initializedProfileId;

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'PK', 'name': 'Urdu'},
    {'code': 'GB', 'name': 'English'},
    {'code': 'ES', 'name': 'Spanish'},
    {'code': 'IN', 'name': 'Hindi'},
    {'code': 'SA', 'name': 'Arabic'},
    {'code': 'BD', 'name': 'Bengali'},
    {'code': 'FR', 'name': 'French'},
    {'code': 'DE', 'name': 'German'},
  ];

  static const List<Map<String, dynamic>> professionItems = [
    {
      'name': 'Electrician',
      'apiKey': 'ELECTRICIAN',
      'svg': AppIcons.boostRocketSvg,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Plumber',
      'apiKey': 'PLUMBER',
      'svg': AppIcons.bathTubSvg,
      'color': Color(0xFF3B82F6),
    },
    {
      'name': 'Painter',
      'apiKey': 'PAINTER',
      'svg': AppIcons.brushSvg,
      'color': Color(0xFFEC4899),
    },
    {
      'name': 'Cleaner',
      'apiKey': 'CLEANER',
      'svg': AppIcons.washingMachineSvg,
      'color': Color(0xFF10B981),
    },
    {
      'name': 'Driver',
      'apiKey': 'DRIVER',
      'svg': AppIcons.carSvg,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Chef / Cook',
      'apiKey': 'CHEF',
      'svg': AppIcons.spoonForkSvg,
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Construction Worker / Labour',
      'apiKey': 'CONSTRUCTION_WORKER',
      'svg': AppIcons.workerSvg,
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Gardener',
      'apiKey': 'GARDENER',
      'svg': AppIcons.gardnerSvg,
      'color': Color(0xFF059669),
    },
    {
      'name': 'Courier / Delivery',
      'apiKey': 'COURIER',
      'svg': AppIcons.bikeSvg,
      'color': Color(0xFF0284C7),
    },
    {
      'name': 'Handyman',
      'apiKey': 'HANDYMAN',
      'svg': AppIcons.workerSvg,
      'color': Color(0xFFD97706),
    },
    {
      'name': 'Barber / Hair Stylist',
      'apiKey': 'BARBER',
      'svg': AppIcons.brushSvg,
      'color': Color(0xFF9333EA),
    },
    {
      'name': 'Pet Sitter',
      'apiKey': 'PET_SITTER',
      'svg': AppIcons.petsSvg,
      'color': Color(0xFF14B8A6),
    },
    {
      'name': 'IT Support / Tech',
      'apiKey': 'IT_SUPPORT',
      'svg': AppIcons.supportSvg,
      'color': Color(0xFF2563EB),
    },
    {
      'name': 'Photographer',
      'apiKey': 'PHOTOGRAPHER',
      'svg': AppIcons.cameraSvg,
      'color': Color(0xFFEA580C),
    },
    {
      'name': 'Other',
      'apiKey': 'OTHER',
      'svg': AppIcons.briefcaseSvg,
      'color': Color(0xFF64748B),
    },
  ];

  void initPostWorkerProfileForm(WorkerProfileModel? profile) {
    final profileId = profile?.id ?? 'NEW_WORKER_PROFILE';
    if (_postProfileFormInitialized && _initializedProfileId == profileId) {
      return;
    }
    _postProfileFormInitialized = true;
    _initializedProfileId = profileId;

    if (profile?.profession != null) {
      final matched = professionItems.firstWhere(
        (e) =>
            (e['apiKey'] as String).toLowerCase() ==
                profile!.profession.toLowerCase() ||
            (e['name'] as String).toLowerCase() ==
                profile.profession.toLowerCase(),
        orElse: () => {'name': profile!.profession},
      );
      _profileSelectedProfession = matched['name'] as String;
    } else {
      _profileSelectedProfession = null;
    }

    _profileYearsOfExperience = profile?.yearsOfExperience ?? 2;
    workerHourlyRateController.text = profile?.hourlyRate ?? '';
    workerDailyRateController.text = profile?.dailyRate ?? '';
    workerAreaCoveredController.text = profile?.areaCovered ?? '';
    workerAboutMeController.text = profile?.aboutMe ?? '';

    _profileSelectedLanguages.clear();
    if (profile != null && profile.languages.isNotEmpty) {
      _profileSelectedLanguages.addAll(profile.languages);
    } else {
      _profileSelectedLanguages.clear();
    }

    _profileIsAvailableToday = profile?.isAvailableToday ?? true;
    _profileHasVehicle = profile?.hasVehicle ?? false;
    _profileHasTools = profile?.hasTools ?? false;

    _profilePhotoFile = null;
    _workPhotoFiles.clear();
    _certificateFiles.clear();

    notifyListeners();
  }

  void resetPostWorkerProfileForm() {
    _postProfileFormInitialized = false;
    _initializedProfileId = null;
    _profileSelectedProfession = null;
    _profileYearsOfExperience = 2;
    workerHourlyRateController.clear();
    workerDailyRateController.clear();
    workerAreaCoveredController.clear();
    workerAboutMeController.clear();
    _profileSelectedLanguages.clear();
    _profileSelectedLanguages.add('Urdu');
    _profileIsAvailableToday = true;
    _profileHasVehicle = false;
    _profileHasTools = false;
    _profilePhotoFile = null;
    _workPhotoFiles.clear();
    _certificateFiles.clear();
    notifyListeners();
  }

  double calculateProfileProgress(WorkerProfileModel? initialProfile) {
    double progress = 0.0;

    if (_profileSelectedProfession != null &&
        _profileSelectedProfession!.isNotEmpty) {
      progress += 0.20;
    }
    if (_profilePhotoFile != null ||
        (initialProfile?.profilePhotoUrl?.isNotEmpty == true)) {
      progress += 0.20;
    }
    if (workerHourlyRateController.text.trim().isNotEmpty ||
        workerDailyRateController.text.trim().isNotEmpty) {
      progress += 0.20;
    }
    if (workerAreaCoveredController.text.trim().isNotEmpty) progress += 0.20;
    if (workerAboutMeController.text.trim().isNotEmpty) progress += 0.20;

    return progress.clamp(0.0, 1.0);
  }

  String getSelectedApiKey() {
    if (_profileSelectedProfession == null ||
        _profileSelectedProfession!.trim().isEmpty) {
      return 'OTHER';
    }

    final raw = _profileSelectedProfession!.trim().toUpperCase();

    const validEnums = [
      'ELECTRICIAN',
      'PLUMBER',
      'PAINTER',
      'CLEANER',
      'DRIVER',
      'CHEF',
      'CONSTRUCTION_WORKER',
      'GARDENER',
      'COURIER',
      'HANDYMAN',
      'BARBER',
      'PET_SITTER',
      'IT_SUPPORT',
      'PHOTOGRAPHER',
      'OTHER',
    ];

    if (validEnums.contains(raw)) return raw;

    final item = professionItems.firstWhere(
      (e) =>
          (e['name'] as String).toLowerCase() ==
              _profileSelectedProfession!.toLowerCase() ||
          (e['apiKey'] as String).toLowerCase() ==
              _profileSelectedProfession!.toLowerCase(),
      orElse: () => {},
    );
    if (item.isNotEmpty && item['apiKey'] != null) {
      return item['apiKey'] as String;
    }

    final lower = _profileSelectedProfession!.toLowerCase();
    if (lower.contains('electric')) return 'ELECTRICIAN';
    if (lower.contains('plumb')) return 'PLUMBER';
    if (lower.contains('paint')) return 'PAINTER';
    if (lower.contains('clean') || lower.contains('maid')) return 'CLEANER';
    if (lower.contains('driv') || lower.contains('chauffeur')) return 'DRIVER';
    if (lower.contains('chef') || lower.contains('cook')) return 'CHEF';
    if (lower.contains('construct') ||
        lower.contains('labour') ||
        lower.contains('labor') ||
        lower.contains('mason')) {
      return 'CONSTRUCTION_WORKER';
    }
    if (lower.contains('garden')) return 'GARDENER';
    if (lower.contains('courier') ||
        lower.contains('deliver') ||
        lower.contains('rider')) {
      return 'COURIER';
    }
    if (lower.contains('handy') ||
        lower.contains('carpent') ||
        lower.contains('repair')) {
      return 'HANDYMAN';
    }
    if (lower.contains('barber') ||
        lower.contains('hair') ||
        lower.contains('salon')) {
      return 'BARBER';
    }
    if (lower.contains('pet')) return 'PET_SITTER';
    if (lower.contains('it') ||
        lower.contains('tech') ||
        lower.contains('comput') ||
        lower.contains('develop')) {
      return 'IT_SUPPORT';
    }
    if (lower.contains('photo')) return 'PHOTOGRAPHER';

    return 'OTHER';
  }

  String? _profileSelectedProfessionId;
  String? get profileSelectedProfessionId => _profileSelectedProfessionId;

  void setProfileSelectedProfession(
    String? profession, {
    String? professionId,
  }) {
    _profileSelectedProfession = profession;
    _profileSelectedProfessionId = professionId;
    notifyListeners();
  }

  void incrementExperience() {
    _profileYearsOfExperience++;
    notifyListeners();
  }

  void decrementExperience() {
    if (_profileYearsOfExperience > 0) {
      _profileYearsOfExperience--;
      notifyListeners();
    }
  }

  void toggleWorkerLanguage(String name) {
    if (_profileSelectedLanguages.contains(name)) {
      if (_profileSelectedLanguages.length > 1) {
        _profileSelectedLanguages.remove(name);
        notifyListeners();
      }
    } else {
      _profileSelectedLanguages.add(name);
      notifyListeners();
    }
  }

  void setProfileIsAvailableToday(bool val) {
    _profileIsAvailableToday = val;
    notifyListeners();
  }

  void setProfileHasVehicle(bool val) {
    _profileHasVehicle = val;
    notifyListeners();
  }

  void setProfileHasTools(bool val) {
    _profileHasTools = val;
    notifyListeners();
  }

  Future<void> pickProfilePhoto([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        _profilePhotoFile = File(file.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile photo: $e');
    }
  }

  Future<void> pickWorkPhotos([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (files.isNotEmpty) {
        _workPhotoFiles.addAll(files.map((x) => File(x.path)));
        if (_workPhotoFiles.length > 6) {
          _workPhotoFiles = _workPhotoFiles.sublist(0, 6);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking work photos: $e');
    }
  }

  void removeWorkPhoto(int index) {
    if (index >= 0 && index < _workPhotoFiles.length) {
      _workPhotoFiles.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> pickCertificateFiles([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        if (_certificateFiles.length < 5) {
          _certificateFiles.add(File(file.path));
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error picking certificate file: $e');
    }
  }

  void removeCertificateFile(int index) {
    if (index >= 0 && index < _certificateFiles.length) {
      _certificateFiles.removeAt(index);
      notifyListeners();
    }
  }

  String? validateWorkerProfileForm(WorkerProfileModel? existingProfile) {
    if (_profileSelectedProfession == null ||
        _profileSelectedProfession!.isEmpty) {
      return 'Please select your profession / service';
    }
    if (workerAreaCoveredController.text.trim().isEmpty) {
      return 'Please specify the area covered';
    }
    if (workerAboutMeController.text.trim().isEmpty) {
      return 'Please fill in the About Me section';
    }
    if (existingProfile == null && _profilePhotoFile == null) {
      return 'Please add a profile photo';
    }
    return null;
  }

  Future<bool> submitWorkerProfile(WorkerProfileModel? existingProfile) async {
    final String serviceApiKey = getSelectedApiKey();
    final bool success;

    if (existingProfile != null) {
      success = await updateWorkerProfileDetails(
        existingProfile.id,
        profilePhoto: _profilePhotoFile,
        service: serviceApiKey,
        experienceInYears: _profileYearsOfExperience.toString(),
        hourlyRate: workerHourlyRateController.text.trim(),
        dailyRate: workerDailyRateController.text.trim(),
        languagesSpoken: _profileSelectedLanguages,
        isAvailableToday: _profileIsAvailableToday,
        ownVehicle: _profileHasVehicle,
        ownTools: _profileHasTools,
        areaCovered: workerAreaCoveredController.text.trim(),
        about: workerAboutMeController.text.trim(),
      );

      if (success && _workPhotoFiles.isNotEmpty) {
        await updateWorkPhotos(
          existingProfile.id,
          newWorkPhotos: _workPhotoFiles,
        );
      }

      if (success && _certificateFiles.isNotEmpty) {
        await updateCertificates(
          existingProfile.id,
          newCertificates: _certificateFiles,
        );
      }
    } else {
      success = await createWorkerProfile(
        profilePhoto: _profilePhotoFile!,
        workPhotos: _workPhotoFiles.isNotEmpty ? _workPhotoFiles : null,
        certificates: _certificateFiles.isNotEmpty ? _certificateFiles : null,
        service: serviceApiKey,
        experienceInYears: _profileYearsOfExperience.toString(),
        hourlyRate: workerHourlyRateController.text.trim(),
        dailyRate: workerDailyRateController.text.trim(),
        languagesSpoken: _profileSelectedLanguages,
        isAvailableToday: _profileIsAvailableToday,
        ownVehicle: _profileHasVehicle,
        ownTools: _profileHasTools,
        areaCovered: workerAreaCoveredController.text.trim(),
        about: workerAboutMeController.text.trim(),
      );
    }

    return success;
  }

  // ===========================================================================
  // HIRE WORKER FORM STATE & OPERATIONS
  // ===========================================================================
  final TextEditingController hireDescriptionController =
      TextEditingController();
  final TextEditingController hireLocationController = TextEditingController();
  final TextEditingController hireBudgetController = TextEditingController();

  String _hireSelectedService = '';
  String get hireSelectedService => _hireSelectedService;

  String? _hireSelectedWorkerTypeId;
  String? get hireSelectedWorkerTypeId => _hireSelectedWorkerTypeId;

  bool _hireIsOneTime = true;
  bool get hireIsOneTime => _hireIsOneTime;

  bool _hireFormInitialized = false;
  String? _initializedHireWorkerId;

  Map<String, dynamic>? _lastHireRequestData;
  Map<String, dynamic>? get lastHireRequestData => _lastHireRequestData;

  void setLastHireRequestData(Map<String, dynamic> data) {
    _lastHireRequestData = data;
    notifyListeners();
  }

  void initHireWorkerForm(
    Map<String, dynamic>? worker, {
    NeedWorkerModel? needWorkerPost,
    CategoriesViewModel? categoriesVM,
  }) {
    final workerId = needWorkerPost?.id ?? worker?['id'] as String? ?? 'w1';
    if (_hireFormInitialized && _initializedHireWorkerId == workerId) {
      return;
    }
    _hireFormInitialized = true;
    _initializedHireWorkerId = workerId;

    if (needWorkerPost != null) {
      final tradeName = WorkerTypeX.fromString(
        needWorkerPost.workerType,
      ).displayName;
      hireDescriptionController.text = needWorkerPost.description.isNotEmpty
          ? needWorkerPost.description
          : 'I need an $tradeName to fix the wiring issue in my apartment';
      hireLocationController.text = needWorkerPost.location;
      hireBudgetController.text = needWorkerPost.budget;
      _hireSelectedService = tradeName;
      _hireSelectedWorkerTypeId =
          needWorkerPost.workerTypeId ??
          categoriesVM?.findWorkerTypeId(tradeName);
      _hireIsOneTime = needWorkerPost.budgetType.toUpperCase() != 'HOURLY';
    } else {
      final profession = worker?['profession'] as String? ?? 'Electrician';
      final desc = worker?['description'] as String?;
      final loc = worker?['location'] as String?;
      final budget = worker?['budget']?.toString();
      final service = worker?['service'] as String?;
      final isOneTime = worker?['isOneTime'] as bool?;
      final workerTypeId = worker?['workerTypeId'] as String?;

      hireDescriptionController.text = (desc != null && desc.isNotEmpty)
          ? desc
          : 'I need an $profession to fix the wiring issue in my apartment';
      hireLocationController.text = (loc != null && loc.isNotEmpty)
          ? loc
          : (worker?['location'] as String? ?? 'Madrid, Spain');
      hireBudgetController.text = (budget != null && budget.isNotEmpty)
          ? budget
          : (worker?['hourlyRate']?.toString() ?? '100');
      _hireSelectedService = (service != null && service.isNotEmpty)
          ? service
          : profession;
      _hireSelectedWorkerTypeId =
          workerTypeId ?? categoriesVM?.findWorkerTypeId(_hireSelectedService);
      _hireIsOneTime = isOneTime ?? true;
    }
    notifyListeners();
  }

  void setHireSelectedService(String service, {String? workerTypeId}) {
    _hireSelectedService = service;
    if (workerTypeId != null && workerTypeId.isNotEmpty) {
      _hireSelectedWorkerTypeId = workerTypeId;
    }
    notifyListeners();
  }

  void setHireSelectedWorkerTypeId(String? id) {
    _hireSelectedWorkerTypeId = id;
    notifyListeners();
  }

  void setHireIsOneTime(bool isOneTime) {
    _hireIsOneTime = isOneTime;
    notifyListeners();
  }

  void resetHireWorkerForm() {
    _hireFormInitialized = false;
    _initializedHireWorkerId = null;
    hireDescriptionController.clear();
    hireLocationController.clear();
    hireBudgetController.clear();
    _hireSelectedService = '';
    _hireSelectedWorkerTypeId = null;
    _hireIsOneTime = true;
    notifyListeners();
  }

  Future<bool> submitHireRequest({
    required Map<String, dynamic>? worker,
    NeedWorkerModel? needWorkerPost,
    required NeedWorkerViewModel needWorkerVM,
    CategoriesViewModel? categoriesVM,
  }) async {
    final post = needWorkerPost ?? (worker?['post'] as NeedWorkerModel?);
    final tradeName = post != null
        ? WorkerTypeX.fromString(post.workerType).displayName
        : null;

    final workerName = tradeName != null
        ? tradeName.toUpperCase()
        : (worker?['name'] as String? ?? 'Ali Khan');
    final profession = tradeName != null
        ? tradeName.toUpperCase()
        : (worker?['profession'] as String? ?? 'Electrician');
    final hourlyRate = post != null
        ? post.budget
        : (worker?['hourlyRate']?.toString() ?? '18');
    final avatar = post != null
        ? (post.referencePhotos.isNotEmpty
              ? post.referencePhotos.first.url
              : (post.requester?.profilePhotoUrl ?? ''))
        : (worker?['avatar'] as String? ?? '');
    final service = _hireSelectedService.isNotEmpty
        ? _hireSelectedService
        : (tradeName ?? profession);
    final location = hireLocationController.text.trim().isEmpty
        ? (post?.location ?? 'Madrid, Spain')
        : hireLocationController.text.trim();
    final budget = hireBudgetController.text.trim().isEmpty
        ? (post?.budget ?? '100')
        : hireBudgetController.text.trim();
    final description = hireDescriptionController.text.trim().isEmpty
        ? (post?.description ??
              'I need an $profession to fix the wiring issue in my apartment')
        : hireDescriptionController.text.trim();

    // Ensure categories are loaded so we have admin UUIDs
    if (categoriesVM != null && categoriesVM.needWorkerTypes.isEmpty) {
      await categoriesVM.fetchNeedWorkerTypes();
    }

    // Resolve the admin workerTypeId UUID
    String? resolvedWorkerTypeId = _hireSelectedWorkerTypeId;
    if (resolvedWorkerTypeId == null || resolvedWorkerTypeId.isEmpty) {
      resolvedWorkerTypeId = categoriesVM?.findWorkerTypeId(service);
    }
    if (resolvedWorkerTypeId == null || resolvedWorkerTypeId.isEmpty) {
      resolvedWorkerTypeId = worker?['workerTypeId'] as String?;
    }
    if (resolvedWorkerTypeId == null || resolvedWorkerTypeId.isEmpty) {
      resolvedWorkerTypeId = categoriesVM?.findWorkerTypeId(profession);
    }
    if (resolvedWorkerTypeId == null || resolvedWorkerTypeId.isEmpty) {
      resolvedWorkerTypeId = post?.workerTypeId;
    }
    if (resolvedWorkerTypeId == null || resolvedWorkerTypeId.isEmpty) {
      resolvedWorkerTypeId = categoriesVM?.needWorkerTypes.firstOrNull?.id;
    }

    bool success = false;
    final postId = post?.id ?? worker?['postId'] as String?;

    if (postId != null && postId.isNotEmpty) {
      success = await needWorkerVM.applyToPost(
        postId,
        coverLetter: description,
        proposedPrice: budget,
      );
    } else {
      final workerId = worker?['id'] as String? ?? 'w1';
      final workerType = WorkerTypeX.fromString(profession).toApiKey();

      bool hireEndpointSuccess = false;
      try {
        final res = await _workerRepository.hireWorker(
          workerId,
          taskDescription: description,
          dateNeeded: DateTime.now().toIso8601String(),
          durationHours: '4',
          contactPhone: '+34600000000',
          offerPrice: budget,
        );
        hireEndpointSuccess = res;
      } catch (e) {
        debugPrint('WorkerViewModel: /hire endpoint not found or failed: $e');
      }

      // Create need-worker post with admin workerTypeId UUID
      final needWorkerSuccess = await needWorkerVM.createPost(
        workerType: workerType,
        workerTypeId: resolvedWorkerTypeId,
        location: location,
        dateNeeded: DateTime.now().toIso8601String(),
        budget: budget,
        budgetType: BudgetType.fixed.toApiKey(),
        isUrgentRequest: false,
        description: description,
      );

      success = hireEndpointSuccess || needWorkerSuccess;
      if (success) {
        _errorMessage = null;
        _successMessage = 'Hire request submitted successfully!';
      }
    }

    _lastHireRequestData = {
      'workerName': workerName,
      'profession': profession,
      'hourlyRate': hourlyRate,
      'avatar': avatar,
      'service': service,
      'location': location,
      'budget': budget,
    };
    notifyListeners();

    return success;
  }

  // ===========================================================================
  // API REPOSITORY METHODS
  // ===========================================================================
  Future<bool> createWorkerProfile({
    required File profilePhoto,
    List<File>? workPhotos,
    List<File>? certificates,
    required String service,
    required String experienceInYears,
    required String hourlyRate,
    required String dailyRate,
    required List<String> languagesSpoken,
    required bool isAvailableToday,
    required bool ownVehicle,
    required bool ownTools,
    required String areaCovered,
    required String about,
  }) async {
    final profile = await _runAsync(
      () => _workerRepository.createWorkerProfile(
        profilePhoto: profilePhoto,
        workPhotos: workPhotos,
        certificates: certificates,
        service: service,
        experienceInYears: experienceInYears,
        hourlyRate: hourlyRate,
        dailyRate: dailyRate,
        languagesSpoken: languagesSpoken,
        isAvailableToday: isAvailableToday,
        ownVehicle: ownVehicle,
        ownTools: ownTools,
        areaCovered: areaCovered,
        about: about,
      ),
    );
    if (profile != null) {
      _currentProfile = profile;
      _successMessage = 'Worker profile created successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateWorkerProfileDetails(
    String id, {
    File? profilePhoto,
    required String service,
    required String experienceInYears,
    required String hourlyRate,
    required String dailyRate,
    required List<String> languagesSpoken,
    required bool isAvailableToday,
    required bool ownVehicle,
    required bool ownTools,
    required String areaCovered,
    required String about,
  }) async {
    final updated = await _runAsync(
      () => _workerRepository.updateWorkerProfileDetails(
        id,
        profilePhoto: profilePhoto,
        service: service,
        experienceInYears: experienceInYears,
        hourlyRate: hourlyRate,
        dailyRate: dailyRate,
        languagesSpoken: languagesSpoken,
        isAvailableToday: isAvailableToday,
        ownVehicle: ownVehicle,
        ownTools: ownTools,
        areaCovered: areaCovered,
        about: about,
      ),
    );
    if (updated != null) {
      _currentProfile = updated;
      _successMessage = 'Worker profile updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateWorkPhotos(
    String id, {
    List<File>? newWorkPhotos,
    List<String>? photosToRemove,
  }) async {
    final updated = await _runAsync(
      () => _workerRepository.updateWorkPhotos(
        id,
        newWorkPhotos: newWorkPhotos,
        photosToRemove: photosToRemove,
      ),
    );
    if (updated != null) {
      _currentProfile = updated;
      _successMessage = 'Work photos updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateCertificates(
    String id, {
    List<File>? newCertificates,
    List<String>? certificatesToRemove,
  }) async {
    final updated = await _runAsync(
      () => _workerRepository.updateCertificates(
        id,
        newCertificates: newCertificates,
        certificatesToRemove: certificatesToRemove,
      ),
    );
    if (updated != null) {
      _currentProfile = updated;
      _successMessage = 'Certificates updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchMyWorkerProfile() async {
    final profile = await _runAsync(
      () => _workerRepository.getMyWorkerProfile(),
    );
    if (profile != null) {
      _currentProfile = profile;
      notifyListeners();
    }
  }

  Future<void> fetchPublicWorkerProfiles({String? service}) async {
    final list = await _runAsync(
      () => _workerRepository.getPublicWorkerProfiles(service: service),
    );
    if (list != null) {
      _publicProfiles = list;
      if (service == null) {
        _persistWorkers();
      }
      notifyListeners();
    }
  }

  Future<bool> hireWorker(
    String workerId, {
    required String taskDescription,
    required String dateNeeded,
    required String durationHours,
    required String contactPhone,
    required String offerPrice,
  }) async {
    final result = await _runAsync(
      () => _workerRepository.hireWorker(
        workerId,
        taskDescription: taskDescription,
        dateNeeded: dateNeeded,
        durationHours: durationHours,
        contactPhone: contactPhone,
        offerPrice: offerPrice,
      ),
    );
    if (result == true) {
      _successMessage = 'Hire request submitted successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    workerHourlyRateController.dispose();
    workerDailyRateController.dispose();
    workerAreaCoveredController.dispose();
    workerAboutMeController.dispose();
    workerSearchController.dispose();
    hireDescriptionController.dispose();
    hireLocationController.dispose();
    hireBudgetController.dispose();
    super.dispose();
  }
}
