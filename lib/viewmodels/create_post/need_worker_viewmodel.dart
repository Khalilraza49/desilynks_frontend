import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_icons.dart';
import '../../models/need_worker_model.dart';
import '../../models/need_worker_application_model.dart';
import '../../models/need_worker_enums.dart';
import '../../models/search_result_model.dart';
import '../../repositories/need_worker_repository.dart';
import '../auth/auth_viewmodel.dart';
import '../categories/categories_viewmodel.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/local/cache_service.dart';

class NeedWorkerViewModel extends ChangeNotifier {
  final NeedWorkerRepository _repository;

  NeedWorkerViewModel(this._repository) {
    _hydrateFromCache();
  }

  void _hydrateFromCache() {
    try {
      final cached = CacheService.instance.getJsonList(CacheService.keyNeedWorkersFeed);
      if (cached != null && cached.isNotEmpty) {
        _feedPosts = cached.map((json) => NeedWorkerModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[NeedWorkerViewModel] Hydration error: $e');
    }
  }

  void _persistFeedPosts() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyNeedWorkersFeed,
        _feedPosts.take(30).map((p) => p.toJson()).toList(),
      );
    } catch (_) {}
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ─── Posts State ───
  List<NeedWorkerModel> _myPosts = [];
  List<NeedWorkerModel> get myPosts => _myPosts;
  bool _hasFetchedMyPosts = false;
  bool get hasFetchedMyPosts => _hasFetchedMyPosts;
  bool _isMyPostsLoading = false;
  bool get isMyPostsLoading => _isMyPostsLoading;

  List<NeedWorkerModel> _feedPosts = [];
  List<NeedWorkerModel> get feedPosts => _feedPosts;
  bool _hasFetchedFeed = false;
  bool get hasFetchedFeed => _hasFetchedFeed;

  String? _fetchedPostApplicationsId;
  String? get fetchedPostApplicationsId => _fetchedPostApplicationsId;

  /// Sort work requests so those matching the user's city/location appear first.
  List<NeedWorkerModel> getSortedNeedWorkers(AuthViewModel authVM) {
    final userCity =
        authVM.currentUser?.address?.city?.trim().toLowerCase() ?? '';
    final userProvince =
        authVM.currentUser?.address?.province?.trim().toLowerCase() ?? '';
    final userCountry =
        authVM.currentUser?.address?.country?.trim().toLowerCase() ?? '';

    final effectiveCity = userCity.isNotEmpty ? userCity : 'madrid';
    final effectiveCountry = userCountry.isNotEmpty ? userCountry : 'spain';

    var filtered = _feedPosts;
    if (_feedWorkerTypeFilter != 'All') {
      final filterNorm = _feedWorkerTypeFilter.trim().toLowerCase();
      filtered = filtered.where((p) {
        final wt = p.workerType.trim().toLowerCase();
        final disp = WorkerTypeX.fromString(p.workerType).displayName.toLowerCase();
        return wt == filterNorm || disp == filterNorm;
      }).toList();
    }

    final sorted = List<NeedWorkerModel>.from(filtered);
    sorted.sort((a, b) {
      final aLoc = a.location.toLowerCase();
      final bLoc = b.location.toLowerCase();

      final aCity = aLoc.contains(effectiveCity);
      final bCity = bLoc.contains(effectiveCity);
      if (aCity && !bCity) return -1;
      if (!aCity && bCity) return 1;

      if (userProvince.isNotEmpty) {
        final aProv = aLoc.contains(userProvince);
        final bProv = bLoc.contains(userProvince);
        if (aProv && !bProv) return -1;
        if (!aProv && bProv) return 1;
      }

      final aCountry = aLoc.contains(effectiveCountry);
      final bCountry = bLoc.contains(effectiveCountry);
      if (aCountry && !bCountry) return -1;
      if (!aCountry && bCountry) return 1;

      return 0;
    });
    return sorted;
  }

  NeedWorkerModel? _currentPost;
  NeedWorkerModel? get currentPost => _currentPost;

  SearchMeta? _postsMeta;
  SearchMeta? get postsMeta => _postsMeta;

  // ─── Applications State ───
  List<NeedWorkerApplicationModel> _myApplications = [];
  List<NeedWorkerApplicationModel> get myApplications => _myApplications;

  List<NeedWorkerApplicationModel> _postApplications = [];
  List<NeedWorkerApplicationModel> get postApplications => _postApplications;

  NeedWorkerModel? _selectedWorkerPost;
  NeedWorkerModel? get selectedWorkerPost => _selectedWorkerPost;

  void setSelectedWorkerPost(NeedWorkerModel? post) {
    if (_selectedWorkerPost?.id == post?.id) return;
    _selectedWorkerPost = post;
    notifyListeners();
  }

  NeedAWorkerApplicationStatus? _workerRequestsFilter;
  NeedAWorkerApplicationStatus? get workerRequestsFilter =>
      _workerRequestsFilter;

  void setWorkerRequestsFilter(NeedAWorkerApplicationStatus? filter) {
    _workerRequestsFilter = filter;
    notifyListeners();
  }

  List<NeedWorkerApplicationModel> get filteredPostApplications {
    if (_workerRequestsFilter == null) return _postApplications;
    return _postApplications.where((a) {
      final s = NeedAWorkerApplicationStatusX.fromString(a.status);
      return s == _workerRequestsFilter;
    }).toList();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Chat Starting State (Worker Request Detail) ───
  bool _isChatStarting = false;
  bool get isChatStarting => _isChatStarting;

  void setIsChatStarting(bool value) {
    _isChatStarting = value;
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
  // POST NEED WORKER FORM STATE & CONTROLLERS
  // ===========================================================================
  final GlobalKey<FormState> postNeedWorkerFormKey = GlobalKey<FormState>();

  final TextEditingController needWorkerLocationController =
      TextEditingController();
  final TextEditingController needWorkerDateController =
      TextEditingController();
  final TextEditingController needWorkerBudgetController =
      TextEditingController();
  final TextEditingController needWorkerDescriptionController =
      TextEditingController();

  final FocusNode needWorkerBudgetFocusNode = FocusNode();
  final LayerLink budgetTypeLayerLink = LayerLink();

  String _selectedCategory = 'Electrician';
  String get selectedCategory => _selectedCategory;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  String _feedWorkerTypeFilter = 'All';
  String get feedWorkerTypeFilter => _feedWorkerTypeFilter;

  void setFeedWorkerTypeFilter(String type) {
    _feedWorkerTypeFilter = type;
    notifyListeners();
    fetchFeed(workerType: type == 'All' ? null : type, force: true);
  }

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;
  String _selectedBudgetType = 'Fixed';
  String get selectedBudgetType => _selectedBudgetType;

  bool _isUrgent = false;
  bool get isUrgent => _isUrgent;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedPhotoFiles = [];
  List<XFile> get selectedPhotoFiles => List.unmodifiable(_selectedPhotoFiles);

  final List<NeedWorkerPhoto> _existingPhotos = [];
  List<NeedWorkerPhoto> get existingPhotos =>
      List.unmodifiable(_existingPhotos);

  final List<String> _photosToRemove = [];
  List<String> get photosToRemove => List.unmodifiable(_photosToRemove);

  bool _formInitialized = false;
  String? _initializedPostId;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Electrician', 'svg': AppIcons.electricianSvg},
    {'name': 'Plumber', 'svg': AppIcons.plumberSvg},
    {'name': 'Painter', 'svg': AppIcons.PainterSvg},
    {'name': 'Cleaner', 'svg': AppIcons.cleanerSvg},
    {'name': 'Driver', 'svg': AppIcons.driverSvg},
    {'name': 'Cook', 'svg': AppIcons.cookSvg},
    {'name': 'Labour', 'svg': AppIcons.labourSvg},
    {'name': 'Gardener', 'svg': AppIcons.GardernerSvg},
    {'name': 'Other', 'svg': AppIcons.briefcaseSvg},
  ];

  static const List<String> budgetTypes = ['Fixed', 'Per Hour', 'Negotiable'];

  void initPostNeedWorkerForm(NeedWorkerModel? post) {
    final postId = post?.id ?? 'NEW_NEED_WORKER_POST';
    if (_formInitialized && _initializedPostId == postId) {
      return;
    }
    _formInitialized = true;
    _initializedPostId = postId;

    _selectedCategory = post != null
        ? WorkerTypeX.fromString(post.workerType).displayName
        : 'Electrician';
    _selectedCategoryId = null;
    needWorkerLocationController.text = post?.location ?? '';
    _selectedDate = post?.dateNeeded;
    needWorkerDateController.text = _selectedDate != null
        ? '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}'
        : '';

    needWorkerBudgetController.text = post?.budget ?? '50';
    _selectedBudgetType = post != null
        ? BudgetTypeX.fromString(post.budgetType).displayName
        : 'Fixed';
    _isUrgent = post?.isUrgentRequest ?? false;
    needWorkerDescriptionController.text = post?.description ?? '';

    _selectedPhotoFiles.clear();
    _existingPhotos.clear();
    _photosToRemove.clear();
    if (post != null) {
      _existingPhotos.addAll(post.referencePhotos);
    }

    notifyListeners();
  }

  void resetPostNeedWorkerForm() {
    _formInitialized = false;
    _initializedPostId = null;
    _selectedCategory = 'Electrician';
    _selectedCategoryId = null;
    needWorkerLocationController.clear();
    needWorkerDateController.clear();
    _selectedDate = null;

    needWorkerBudgetController.text = '50';
    _selectedBudgetType = 'Fixed';
    _isUrgent = false;
    needWorkerDescriptionController.clear();
    _selectedPhotoFiles.clear();
    _existingPhotos.clear();
    _photosToRemove.clear();
    notifyListeners();
  }

  void setSelectedCategory(String category, {String? categoryId}) {
    _selectedCategory = category;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    if (date != null) {
      needWorkerDateController.text =
          '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
    notifyListeners();
  }

  void setSelectedBudgetType(String budgetType) {
    _selectedBudgetType = budgetType;
    notifyListeners();
  }

  void setIsUrgent(bool urgent) {
    _isUrgent = urgent;
    notifyListeners();
  }

  Future<String?> pickPhoto([BuildContext? context]) async {
    final totalCount = _existingPhotos.length + _selectedPhotoFiles.length;
    if (totalCount >= 6) {
      return 'Maximum 6 reference photos allowed';
    }

    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return null;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        _selectedPhotoFiles.add(image);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
    return null;
  }

  void removeSelectedPhoto(int index) {
    if (index >= 0 && index < _selectedPhotoFiles.length) {
      _selectedPhotoFiles.removeAt(index);
      notifyListeners();
    }
  }

  void removeExistingPhoto(int index) {
    if (index >= 0 && index < _existingPhotos.length) {
      final photo = _existingPhotos.removeAt(index);
      if (photo.id.isNotEmpty) {
        _photosToRemove.add(photo.id);
      }
      notifyListeners();
    }
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  TimeOfDay? parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    try {
      final input = timeStr.trim().toUpperCase();
      final isPm = input.contains('PM');
      final isAm = input.contains('AM');
      final clean = input.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = clean.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  String mapBudgetTypeToApi(String uiBudgetType) {
    switch (uiBudgetType) {
      case 'Hourly':
      case 'Per Hour':
        return BudgetType.perHour.toApiKey();
      case 'Per Day':
      case 'Negotiable':
        return BudgetType.negotiable.toApiKey();
      case 'Fixed':
      default:
        return BudgetType.fixed.toApiKey();
    }
  }

  String? validateForm() {
    if (needWorkerLocationController.text.trim().isEmpty) {
      return 'Please enter your location or area';
    }

    if (_selectedDate == null &&
        needWorkerDateController.text.trim().isNotEmpty) {
      try {
        final parts = needWorkerDateController.text.trim().split('/');
        if (parts.length == 3) {
          final m = int.parse(parts[0]);
          final d = int.parse(parts[1]);
          final y = int.parse(parts[2]);
          _selectedDate = DateTime(y, m, d);
        }
      } catch (_) {}
    }

    if (needWorkerDateController.text.trim().isEmpty || _selectedDate == null) {
      return 'Please select the date needed';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );
    if (selected.isBefore(today)) {
      return 'Selected date cannot be in the past';
    }

    if (needWorkerDescriptionController.text.trim().isEmpty) {
      return 'Please enter a description of the work needed';
    }

    return null;
  }

  Future<bool> submitNeedWorkerPost(
    NeedWorkerModel? existingPost, {
    CategoriesViewModel? categoriesVM,
  }) async {
    final workerType = WorkerTypeX.fromString(_selectedCategory).toApiKey();
    final budgetType = mapBudgetTypeToApi(_selectedBudgetType);
    final dateNeeded =
        _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String();

    final budget = needWorkerBudgetController.text.trim().isEmpty
        ? '50'
        : needWorkerBudgetController.text.trim();

    final List<File> photoFiles = _selectedPhotoFiles
        .map((x) => File(x.path))
        .toList();

    final bool isEdit = existingPost != null;

    final resolvedWorkerTypeId = _selectedCategoryId ??
        categoriesVM?.findWorkerTypeId(_selectedCategory) ??
        existingPost?.workerTypeId ??
        categoriesVM?.needWorkerTypes.firstOrNull?.id;

    bool success = false;
    if (isEdit) {
      success = await updatePost(
        existingPost.id,
        workerType: workerType,
        workerTypeId: resolvedWorkerTypeId,
        location: needWorkerLocationController.text.trim(),
        dateNeeded: dateNeeded,
        budget: budget,
        budgetType: budgetType,
        isUrgentRequest: _isUrgent,
        description: needWorkerDescriptionController.text.trim(),
      );

      if (photoFiles.isNotEmpty || _photosToRemove.isNotEmpty) {
        await updateReferencePhotos(
          existingPost.id,
          newPhotos: photoFiles.isNotEmpty ? photoFiles : null,
          photosToRemove: _photosToRemove.isNotEmpty ? _photosToRemove : null,
        );
      }
    } else {
      success = await createPost(
        workerType: workerType,
        workerTypeId: resolvedWorkerTypeId,
        location: needWorkerLocationController.text.trim(),
        dateNeeded: dateNeeded,
        budget: budget,
        budgetType: budgetType,
        isUrgentRequest: _isUrgent,
        description: needWorkerDescriptionController.text.trim(),
        referencePhotos: photoFiles.isNotEmpty ? photoFiles : null,
      );
    }
    return success;
  }

  // ─── Post Management ───

  Future<bool> createPost({
    String? workerType,
    String? workerTypeId,
    String? needWorkerTypeId,
    required String location,
    required String dateNeeded,
    required String budget,
    required String budgetType,
    required bool isUrgentRequest,
    required String description,
    List<File>? referencePhotos,
  }) async {
    final post = await _runAsync(
      () => _repository.createPost(
        workerType: workerType,
        workerTypeId: workerTypeId ?? needWorkerTypeId,
        location: location,
        dateNeeded: dateNeeded,
        budget: budget,
        budgetType: budgetType,
        isUrgentRequest: isUrgentRequest,
        description: description,
        referencePhotos: referencePhotos,
      ),
    );
    if (post != null) {
      _currentPost = post;
      _feedPosts.removeWhere((p) => p.id == post.id);
      _feedPosts.insert(0, post);
      _myPosts.removeWhere((p) => p.id == post.id);
      _myPosts.insert(0, post);
      _persistFeedPosts();
      _hasFetchedFeed = true;
      _hasFetchedMyPosts = true;
      _successMessage = 'Worker request posted successfully!';
      notifyListeners();
      fetchFeed(force: true);
      fetchMyPosts(force: true);
      return true;
    }
    return false;
  }

  Future<bool> updatePost(
    String id, {
    String? workerType,
    String? workerTypeId,
    String? needWorkerTypeId,
    required String location,
    required String dateNeeded,
    required String budget,
    required String budgetType,
    required bool isUrgentRequest,
    required String description,
  }) async {
    final post = await _runAsync(
      () => _repository.updatePost(
        id,
        workerType: workerType,
        workerTypeId: workerTypeId ?? needWorkerTypeId,
        location: location,
        dateNeeded: dateNeeded,
        budget: budget,
        budgetType: budgetType,
        isUrgentRequest: isUrgentRequest,
        description: description,
      ),
    );
    if (post != null) {
      _currentPost = post;
      _successMessage = 'Worker request updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateReferencePhotos(
    String id, {
    List<File>? newPhotos,
    List<String>? photosToRemove,
  }) async {
    final post = await _runAsync(
      () => _repository.updateReferencePhotos(
        id,
        newPhotos: newPhotos,
        photosToRemove: photosToRemove,
      ),
    );
    if (post != null) {
      _currentPost = post;
      _successMessage = 'Reference photos updated successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deletePost(String id) async {
    final result = await _runAsync(() async {
      await _repository.deletePost(id);
      return true;
    });
    if (result == true) {
      _myPosts.removeWhere((p) => p.id == id);
      _feedPosts.removeWhere((p) => p.id == id);
      _persistFeedPosts();
      _successMessage = 'Worker request deleted successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Fetching ───

  Future<void> fetchMyPosts({
    int page = 1,
    String? budgetType,
    bool force = false,
  }) async {
    if ((_hasFetchedMyPosts && !force && page == 1) || _isMyPostsLoading) {
      return;
    }
    _isMyPostsLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _repository.getMyPosts(
        page: page,
        budgetType: budgetType,
      );
      if (page == 1) {
        _myPosts = result.data;
      } else {
        _myPosts.addAll(result.data);
      }
      _postsMeta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching my worker posts: $e');
    } finally {
      _hasFetchedMyPosts = true;
      _isMyPostsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeed({
    int page = 1,
    String? budgetType,
    String? workerType,
    bool force = false,
  }) async {
    final effectiveWorkerType = workerType ??
        (_feedWorkerTypeFilter == 'All' ? null : _feedWorkerTypeFilter);
    if ((_hasFetchedFeed && !force && page == 1 && effectiveWorkerType == null) ||
        _isLoading) {
      return;
    }
    final result = await _runAsync(
      () => _repository.getFeed(
        page: page,
        budgetType: budgetType,
        workerType: effectiveWorkerType,
      ),
    );
    _hasFetchedFeed = true;
    if (result != null) {
      if (page == 1) {
        _feedPosts = result.data;
        if (effectiveWorkerType == null) {
          _persistFeedPosts();
        }
      } else {
        _feedPosts.addAll(result.data);
      }
      _postsMeta = result.meta;
      notifyListeners();
    }
  }

  Future<void> fetchPostById(String id) async {
    final post = await _runAsync(() => _repository.getPostById(id));
    if (post != null) {
      _currentPost = post;
      notifyListeners();
    }
  }

  // ─── Worker Application Actions ───

  Future<bool> applyToPost(
    String postId, {
    String? coverLetter,
    String? proposedPrice,
  }) async {
    final app = await _runAsync(
      () => _repository.applyToPost(
        postId,
        coverLetter: coverLetter,
        proposedPrice: proposedPrice,
      ),
    );
    if (app != null) {
      _successMessage = 'Applied successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchMyApplications({int page = 1, String? status}) async {
    final result = await _runAsync(
      () => _repository.getMyApplications(page: page, status: status),
    );
    if (result != null) {
      if (page == 1) {
        _myApplications = result.data;
      } else {
        _myApplications.addAll(result.data);
      }
      notifyListeners();
    }
  }

  Future<bool> withdrawApplication(String applicationId) async {
    final app = await _runAsync(
      () => _repository.withdrawApplication(applicationId),
    );
    if (app != null) {
      final idx = _myApplications.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _myApplications[idx] = app;
      }
      _successMessage = 'Application withdrawn successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Requester Application Management ───

  bool _isFetchingPostApplications = false;
  bool get isFetchingPostApplications => _isFetchingPostApplications;

  Future<void> fetchPostApplications(
    String postId, {
    int page = 1,
    String? status,
    bool force = false,
  }) async {
    if (!force && _isFetchingPostApplications) return;
    if (!force && _fetchedPostApplicationsId == postId && page == 1) return;
    _isFetchingPostApplications = true;
    try {
      final result = await _runAsync(
        () => _repository.getPostApplications(postId, page: page, status: status),
      );
      if (result != null) {
        if (page == 1) {
          _postApplications = result.data;
        } else {
          _postApplications.addAll(result.data);
        }
        _fetchedPostApplicationsId = postId;
        notifyListeners();
      }
    } finally {
      _isFetchingPostApplications = false;
    }
  }

  // ─── Worker Requests Screen Initialization (MVVM) ───
  bool _hasInitializedWorkerRequests = false;
  bool get hasInitializedWorkerRequests => _hasInitializedWorkerRequests;

  Future<void> initWorkerRequests({
    NeedWorkerModel? initialPost,
    String? initialPostId,
    bool force = false,
  }) async {
    final targetId = initialPostId ?? initialPost?.id;

    if (!force && _hasInitializedWorkerRequests) {
      if (targetId != null && _fetchedPostApplicationsId == targetId) return;
      if (targetId == null && _fetchedPostApplicationsId == 'all') return;
    }
    if (!force && (_isFetchingPostApplications || _isLoading)) return;

    _hasInitializedWorkerRequests = true;

    if (initialPost != null) {
      _selectedWorkerPost = initialPost;
    } else if (targetId == null) {
      _selectedWorkerPost = null;
    }

    if (targetId != null && targetId.isNotEmpty) {
      await fetchPostApplications(targetId, force: force);
      if (_selectedWorkerPost == null) {
        if (!_hasFetchedMyPosts || force) {
          await fetchMyPosts(force: force);
        }
        final match =
            _myPosts.where((p) => p.id == targetId).firstOrNull;
        if (match != null) {
          _selectedWorkerPost = match;
          notifyListeners();
        }
      }
    } else {
      await fetchAllIncomingApplications(force: force);
    }
  }

  /// Fetches incoming applications across all of the user's posts
  Future<void> fetchAllIncomingApplications({
    String? status,
    bool force = false,
  }) async {
    if (!force && _fetchedPostApplicationsId == 'all' && _postApplications.isNotEmpty) {
      return;
    }
    if (_isFetchingPostApplications || _isLoading) return;

    if (_myPosts.isEmpty || force) {
      await fetchMyPosts(force: force);
    }
    if (_myPosts.isEmpty) {
      _postApplications = [];
      _fetchedPostApplicationsId = 'all';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<NeedWorkerApplicationModel> combined = [];
      for (final post in _myPosts) {
        try {
          final res = await _repository.getPostApplications(
            post.id,
            status: status,
          );
          // Attach workRequest to each application if missing
          for (final app in res.data) {
            combined.add(
              app.workRequest == null ? app.copyWith(workRequest: post) : app,
            );
          }
        } catch (_) {
          // Ignore individual post error
        }
      }
      _postApplications = combined;
      _fetchedPostApplicationsId = 'all';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptApplication(String applicationId) async {
    final app = await _runAsync(
      () => _repository.acceptApplication(applicationId),
    );
    if (app != null) {
      // Update the accepted app and mark all other pending applications for this request as rejected
      for (int i = 0; i < _postApplications.length; i++) {
        if (_postApplications[i].id == applicationId) {
          _postApplications[i] = app;
        } else if (_postApplications[i].workRequestId == app.workRequestId &&
            _postApplications[i].status == 'PENDING') {
          _postApplications[i] = _postApplications[i].copyWith(
            status: 'REJECTED',
            updatedAt: DateTime.now(),
          );
        }
      }
      _successMessage = 'Application accepted successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> rejectApplication(String applicationId) async {
    final app = await _runAsync(
      () => _repository.rejectApplication(applicationId),
    );
    if (app != null) {
      final idx = _postApplications.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _postApplications[idx] = app;
      }
      _successMessage = 'Application rejected successfully!';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ===========================================================================
  // APPLY WORK REQUEST FORM STATE & CONTROLLERS
  // ===========================================================================
  final TextEditingController applyPriceController = TextEditingController();
  final TextEditingController applyCoverLetterController =
      TextEditingController();

  bool _isApplying = false;
  bool get isApplying => _isApplying;

  void setIsApplying(bool value) {
    _isApplying = value;
    notifyListeners();
  }

  void initApplyForm(String defaultBudget) {
    applyPriceController.text = defaultBudget;
    applyCoverLetterController.clear();
    _isApplying = false;
  }

  void clearApplyForm() {
    applyPriceController.clear();
    applyCoverLetterController.clear();
    _isApplying = false;
  }

  @override
  void dispose() {
    needWorkerBudgetFocusNode.dispose();
    needWorkerLocationController.dispose();
    needWorkerDateController.dispose();
    needWorkerBudgetController.dispose();
    needWorkerDescriptionController.dispose();
    applyPriceController.dispose();
    applyCoverLetterController.dispose();
    super.dispose();
  }
}
