import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/job_application_model.dart';
import '../../models/job_enums.dart';
import '../../models/job_model.dart';
import '../../repositories/job_repository.dart';
import '../auth/auth_viewmodel.dart';
import '../create_post/need_worker_viewmodel.dart';
import '../profile/favourite_ads_viewmodel.dart';
import '../../services/permissions/permission_service.dart';
import '../../services/local/cache_service.dart';

class JobsViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  FavouriteAdsViewModel? _favouriteAdsViewModel;

  JobsViewModel(this._jobRepository) {
    _initControllers();
    _hydrateFromCache();
    _loadBookmarkedJobIds();
  }

  void bindFavouriteAdsViewModel(FavouriteAdsViewModel favVM) {
    _favouriteAdsViewModel = favVM;
  }

  void _loadBookmarkedJobIds() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        final ids = prefs.getStringList('key_bookmarked_job_ids');
        if (ids != null && ids.isNotEmpty) {
          _bookmarkedJobIds.addAll(ids);
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('[JobsViewModel] Error loading bookmarked job IDs: $e');
    }
  }

  void _initControllers() {
    postTitleController.addListener(notifyListeners);
    postCompanyController.addListener(notifyListeners);
    postSalaryController.addListener(notifyListeners);
    postCategoryController.addListener(notifyListeners);
    postLocationController.addListener(notifyListeners);
    postDescriptionController.addListener(notifyListeners);
    postSkillsController.addListener(notifyListeners);
  }

  void _hydrateFromCache() {
    try {
      final cachedPublic = CacheService.instance.getJsonList(CacheService.keyJobsPublic);
      if (cachedPublic != null && cachedPublic.isNotEmpty) {
        _publicJobs = cachedPublic.map((json) => JobModel.fromJson(json)).toList();
      }
      final cachedUser = CacheService.instance.getJsonList(CacheService.keyJobsUser);
      if (cachedUser != null && cachedUser.isNotEmpty) {
        _userJobs = cachedUser.map((json) => JobModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[JobsViewModel] Hydration error: $e');
    }
  }

  void _persistPublicJobs() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyJobsPublic,
        _publicJobs.take(30).map((j) => j.toJson()).toList(),
      );
    } catch (_) {}
  }

  void _persistUserJobs() {
    try {
      CacheService.instance.saveJsonList(
        CacheService.keyJobsUser,
        _userJobs.take(30).map((j) => j.toJson()).toList(),
      );
    } catch (_) {}
  }

  // Cover Letter Controller & Dialog State for JobDetailView
  final TextEditingController coverLetterController = TextEditingController();
  void clearCoverLetter() => coverLetterController.clear();

  JobModel? getJobModel(dynamic job) {
    if (job is JobModel) {
      if (_selectedJob != null && _selectedJob!.id == job.id) {
        return _selectedJob;
      }
      return job;
    } else if (job is Map<String, dynamic>) {
      try {
        final parsed = JobModel.fromJson(job);
        if (_selectedJob != null && _selectedJob!.id == parsed.id) {
          return _selectedJob;
        }
        return parsed;
      } catch (_) {
        return null;
      }
    } else if (job is String) {
      if (_selectedJob != null && _selectedJob!.id == job) {
        return _selectedJob;
      }
      final pubMatch = _publicJobs.cast<JobModel?>().firstWhere(
        (j) => j?.id == job,
        orElse: () => null,
      );
      if (pubMatch != null) return pubMatch;
      final userMatch = _userJobs.cast<JobModel?>().firstWhere(
        (j) => j?.id == job,
        orElse: () => null,
      );
      if (userMatch != null) return userMatch;
      return _selectedJob;
    }
    return _selectedJob;
  }

  // Loading & Error States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Data lists & metadata
  List<JobModel> _publicJobs = [];
  List<JobModel> get publicJobs => _publicJobs;
  bool _hasFetchedPublicJobs = false;
  bool get hasFetchedPublicJobs => _hasFetchedPublicJobs;

  Map<String, dynamic> _publicMeta = {};
  Map<String, dynamic> get publicMeta => _publicMeta;

  List<JobModel> _userJobs = [];
  List<JobModel> get userJobs => _userJobs;
  bool _hasFetchedUserJobs = false;
  bool get hasFetchedUserJobs => _hasFetchedUserJobs;

  bool _isFetchingUserJobs = false;
  bool get isFetchingUserJobs => _isFetchingUserJobs;
  bool _hasInitializedUserJobs = false;
  bool get hasInitializedUserJobs => _hasInitializedUserJobs;

  Future<void> initUserJobs({bool force = false}) async {
    if (!force && _hasInitializedUserJobs) return;
    if (!force && (_isFetchingUserJobs || _isLoading)) return;
    _hasInitializedUserJobs = true;
    await fetchUserJobs(force: force);
  }

  Future<void> initMyJobs({bool force = false}) => initUserJobs(force: force);

  String _myJobsSelectedTab = 'All';
  String get myJobsSelectedTab => _myJobsSelectedTab;

  void setMyJobsSelectedTab(String tab) {
    if (_myJobsSelectedTab == tab) return;
    _myJobsSelectedTab = tab;
    notifyListeners();
  }

  List<JobModel> get filteredUserJobs {
    return _userJobs.where((job) {
      if (_myJobsSelectedTab == 'All') {
        return true;
      } else if (_myJobsSelectedTab == 'Active') {
        return job.status == JobStatus.open;
      } else if (_myJobsSelectedTab == 'Pending') {
        return job.status == JobStatus.pending;
      } else if (_myJobsSelectedTab == 'Expired') {
        return job.status == JobStatus.closed ||
            job.status == JobStatus.archived;
      }
      return true;
    }).toList();
  }

  Map<String, dynamic> _userMeta = {};
  Map<String, dynamic> get userMeta => _userMeta;

  List<JobApplicationModel> _applicantApplications = [];
  List<JobApplicationModel> get applicantApplications => _applicantApplications;
  bool _hasFetchedApplicantApplications = false;
  bool get hasFetchedApplicantApplications => _hasFetchedApplicantApplications;

  JobApplicationStatus? _applicationsFilter;
  JobApplicationStatus? get applicationsFilter => _applicationsFilter;

  void setApplicationsFilter(JobApplicationStatus? filter) {
    _applicationsFilter = filter;
    notifyListeners();
  }

  List<JobApplicationModel> get filteredApplicantApplications {
    if (_applicationsFilter == null) return _applicantApplications;
    return _applicantApplications
        .where((app) => app.status == _applicationsFilter)
        .toList();
  }

  List<JobApplicationModel> _jobApplications = [];
  List<JobApplicationModel> get jobApplications => _jobApplications;
  String? _fetchedJobApplicationsId;
  String? get fetchedJobApplicationsId => _fetchedJobApplicationsId;

  JobApplicationStatus? _jobApplicantsFilter;
  JobApplicationStatus? get jobApplicantsFilter => _jobApplicantsFilter;

  void setJobApplicantsFilter(JobApplicationStatus? filter) {
    _jobApplicantsFilter = filter;
    notifyListeners();
  }

  List<JobApplicationModel> get filteredJobApplications {
    if (_jobApplicantsFilter == null) return _jobApplications;
    return _jobApplications
        .where((a) => a.status == _jobApplicantsFilter)
        .toList();
  }

  JobModel? _selectedJob;
  JobModel? get selectedJob => _selectedJob;

  JobApplicationModel? _selectedApplication;
  JobApplicationModel? get selectedApplication => _selectedApplication;

  ApplicationStatsModel? _employerStats;
  ApplicationStatsModel? get employerStats => _employerStats;

  ApplicationStatsModel? _applicantStats;
  ApplicationStatsModel? get applicantStats => _applicantStats;

  // Filter parameters for Public Feed
  JobCategory? selectedCategory;
  JobType? selectedType;
  Experience? selectedExperience;
  Education? selectedEducation;
  WorkMode? selectedWorkMode;
  double? minSalaryFilter;
  double? maxSalaryFilter;
  String searchQuery = '';

  void setCategoryFilter(JobCategory? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setTypeFilter(JobType? type) {
    selectedType = type;
    notifyListeners();
  }

  void resetFilters() {
    selectedCategory = null;
    selectedType = null;
    selectedExperience = null;
    selectedEducation = null;
    selectedWorkMode = null;
    minSalaryFilter = null;
    maxSalaryFilter = null;
    searchQuery = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<T?> _runAsync<T>(Future<T> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      return await action();
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('HttpException: ', '')
          .replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 1. Fetch Public Jobs Feed
  Future<void> fetchPublicJobs({int page = 1, int limit = 10, bool force = false}) async {
    if ((_hasFetchedPublicJobs && !force && page == 1) || _isLoading) return;
    final res = await _runAsync(
      () => _jobRepository.getPublicJobs(
        page: page,
        limit: limit,
        category: selectedCategory,
        type: selectedType,
        experience: selectedExperience,
        education: selectedEducation,
        workMode: selectedWorkMode,
        minSalary: minSalaryFilter,
        maxSalary: maxSalaryFilter,
      ),
    );
    _hasFetchedPublicJobs = true;
    if (res != null) {
      final allJobs = res['jobs'] as List<JobModel>;
      _publicJobs = allJobs.where((job) => job.status == JobStatus.open).map((
        job,
      ) {
        if (job.isApplied != null) return job;
        final hasApp = _applicantApplications.any(
          (a) =>
              a.jobId == job.id && a.status != JobApplicationStatus.withdrawn,
        );
        return hasApp ? job.copyWith(isApplied: true) : job;
      }).toList();
      _publicMeta = res['meta'] as Map<String, dynamic>;
      if (page == 1) {
        _persistPublicJobs();
      }
      notifyListeners();
    }
  }

  // 2. Fetch User's Own Jobs (Employer view)
  Future<void> fetchUserJobs({int page = 1, int limit = 10, bool force = false}) async {
    if (!force && _isFetchingUserJobs) return;
    if (!force && ((_hasFetchedUserJobs && page == 1) || _isLoading)) return;

    _isFetchingUserJobs = true;
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _jobRepository.getUserJobs(page: page, limit: limit);
      final List<JobModel> jobs = res['jobs'] as List<JobModel>;
      if (page == 1) {
        _userJobs = jobs;
        _persistUserJobs();
      } else {
        _userJobs.addAll(jobs);
      }
      _userMeta = res['meta'] as Map<String, dynamic>;
      _hasFetchedUserJobs = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isFetchingUserJobs = false;
      _setLoading(false);
    }
  }

  // 3. Fetch Job Details by ID
  Future<void> fetchJobDetails(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _selectedJob = await _jobRepository.getJobById(id);
      if (_applicantApplications.isEmpty) {
        try {
          await fetchApplicantApplications();
        } catch (_) {}
      }
      if (_selectedJob != null) {
        final hasApp = _applicantApplications.any((a) => a.jobId == id);
        if (hasApp) {
          _selectedJob = _selectedJob!.copyWith(isApplied: true);
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // 4. Create Job (Employer)
  Future<bool> createJob({
    File? posterFile,
    required String title,
    required String companyName,
    JobCategory? category,
    String? categoryId,
    String? salary,
    String? minSalary,
    String? maxSalary,
    required SalaryPeriod salaryPeriod,
    required JobType type,
    required Experience experience,
    Education? education,
    required List<Language> languages,
    required String location,
    required WorkMode workMode,
    required String description,
    required String requiredSkills,
    List<Benefit>? benefits,
    DateTime? applicationDeadline,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newJob = await _jobRepository.createJob(
        posterFile: posterFile,
        title: title,
        companyName: companyName,
        category: category,
        categoryId: categoryId,
        salary: salary,
        minSalary: minSalary,
        maxSalary: maxSalary,
        salaryPeriod: salaryPeriod,
        type: type,
        experience: experience,
        education: education,
        languages: languages,
        location: location,
        workMode: workMode,
        description: description,
        requiredSkills: requiredSkills,
        benefits: benefits,
        applicationDeadline: applicationDeadline,
      );
      _userJobs.insert(0, newJob);
      _persistUserJobs();
      _successMessage = 'Job posted successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Update Job (Employer)
  Future<bool> updateJob(
    String id, {
    required String title,
    required String companyName,
    JobCategory? category,
    String? categoryId,
    String? salary,
    String? minSalary,
    String? maxSalary,
    required SalaryPeriod salaryPeriod,
    required JobType type,
    required Experience experience,
    Education? education,
    required List<Language> languages,
    required String location,
    required WorkMode workMode,
    required String description,
    required String requiredSkills,
    List<Benefit>? benefits,
    DateTime? applicationDeadline,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updatedJob = await _jobRepository.updateJob(
        id,
        title: title,
        companyName: companyName,
        category: category,
        categoryId: categoryId,
        salary: salary,
        minSalary: minSalary,
        maxSalary: maxSalary,
        salaryPeriod: salaryPeriod,
        type: type,
        experience: experience,
        education: education,
        languages: languages,
        location: location,
        workMode: workMode,
        description: description,
        requiredSkills: requiredSkills,
        benefits: benefits,
        applicationDeadline: applicationDeadline,
      );
      _selectedJob = updatedJob;

      final index = _userJobs.indexWhere((j) => j.id == id);
      if (index != -1) _userJobs[index] = updatedJob;

      final pubIndex = _publicJobs.indexWhere((j) => j.id == id);
      if (pubIndex != -1) {
        if (updatedJob.status == JobStatus.open) {
          _publicJobs[pubIndex] = updatedJob;
        } else {
          _publicJobs.removeAt(pubIndex);
        }
      }
      _persistUserJobs();
      _persistPublicJobs();

      _successMessage = 'Job updated successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5b. Update Job Poster Image (Employer)
  Future<bool> updateJobPoster(String id, File posterFile) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updatedJob = await _jobRepository.updateJobPoster(id, posterFile);
      _selectedJob = updatedJob;

      final index = _userJobs.indexWhere((j) => j.id == id);
      if (index != -1) _userJobs[index] = updatedJob;
      _persistUserJobs();

      _successMessage = 'Job poster updated successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Mark Job Closed
  Future<bool> markJobClosed(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final msg = await _jobRepository.markJobClosed(id);
      _successMessage = msg;
      if (_selectedJob != null && _selectedJob!.id == id) {
        _selectedJob = _selectedJob!.copyWith(status: JobStatus.closed);
      }
      final index = _userJobs.indexWhere((j) => j.id == id);
      if (index != -1) {
        _userJobs[index] = _userJobs[index].copyWith(status: JobStatus.closed);
      }
      _publicJobs.removeWhere((j) => j.id == id);
      _persistUserJobs();
      _persistPublicJobs();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 7. Mark Job Archived
  Future<bool> markJobArchived(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final msg = await _jobRepository.markJobArchived(id);
      _successMessage = msg;
      if (_selectedJob != null && _selectedJob!.id == id) {
        _selectedJob = _selectedJob!.copyWith(status: JobStatus.archived);
      }
      final index = _userJobs.indexWhere((j) => j.id == id);
      if (index != -1) {
        _userJobs[index] = _userJobs[index].copyWith(
          status: JobStatus.archived,
        );
      }
      _publicJobs.removeWhere((j) => j.id == id);
      _persistUserJobs();
      _persistPublicJobs();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 8. Delete Job
  Future<bool> deleteJob(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final msg = await _jobRepository.deleteJob(id);
      _successMessage = msg;
      _userJobs.removeWhere((j) => j.id == id);
      _publicJobs.removeWhere((j) => j.id == id);
      if (_selectedJob != null && _selectedJob!.id == id) {
        _selectedJob = null;
      }
      _persistUserJobs();
      _persistPublicJobs();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 9. Apply for Job
  Future<bool> applyForJob(String jobId, {String? coverLetter}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final app = await _jobRepository.applyForJob(
        jobId,
        coverLetter: coverLetter,
      );
      _applicantApplications.insert(0, app);
      if (_selectedJob != null && _selectedJob!.id == jobId) {
        _selectedJob = _selectedJob!.copyWith(isApplied: true);
      }
      final pubIndex = _publicJobs.indexWhere((j) => j.id == jobId);
      if (pubIndex != -1) {
        _publicJobs[pubIndex] = _publicJobs[pubIndex].copyWith(isApplied: true);
      }
      _successMessage = 'Successfully applied for the job!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('HttpException: ', '')
          .replaceAll('Exception: ', '');
      if (_errorMessage != null &&
          _errorMessage!.toLowerCase().contains('already applied')) {
        if (_selectedJob != null && _selectedJob!.id == jobId) {
          _selectedJob = _selectedJob!.copyWith(isApplied: true);
        }
        final pubIndex = _publicJobs.indexWhere((j) => j.id == jobId);
        if (pubIndex != -1) {
          _publicJobs[pubIndex] = _publicJobs[pubIndex].copyWith(
            isApplied: true,
          );
        }
      }
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool _isFetchingApplicantApplications = false;
  bool _isFetchingApplicantStats = false;
  bool _hasInitializedApplicantApplications = false;
  bool get hasInitializedApplicantApplications =>
      _hasInitializedApplicantApplications;

  Future<void> initApplicantApplications({bool force = false}) async {
    if (!force && _hasInitializedApplicantApplications) {
      return;
    }
    if (!force &&
        (_isFetchingApplicantApplications ||
            _isFetchingApplicantStats ||
            _isLoading)) {
      return;
    }
    _hasInitializedApplicantApplications = true;
    await Future.wait([
      fetchApplicantApplications(force: force),
      fetchApplicantStats(force: force),
    ]);
  }

  // 10. Fetch Applicant Applications
  Future<void> fetchApplicantApplications({
    int page = 1,
    int limit = 10,
    JobApplicationStatus? status,
    bool force = false,
  }) async {
    if (!force && _isFetchingApplicantApplications) return;
    if (!force &&
        ((_hasFetchedApplicantApplications && page == 1 && status == null) ||
            _isLoading)) {
      return;
    }
    _isFetchingApplicantApplications = true;
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _jobRepository.getApplicantApplications(
        page: page,
        limit: limit,
        status: status,
      );
      final List<JobApplicationModel> apps =
          res['applications'] as List<JobApplicationModel>;
      if (page == 1) {
        _applicantApplications = apps;
      } else {
        _applicantApplications.addAll(apps);
      }
      _hasFetchedApplicantApplications = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isFetchingApplicantApplications = false;
      _setLoading(false);
    }
  }

  // 11. Fetch Application by ID
  Future<void> fetchApplicationById(String id) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _selectedApplication = await _jobRepository.getApplicationById(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // 12. Withdraw Application
  Future<bool> withdrawApplication(String applicationId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updatedApp = await _jobRepository.withdrawApplication(
        applicationId,
      );
      String jobId = updatedApp.jobId;
      final index = _applicantApplications.indexWhere(
        (a) => a.id == applicationId,
      );
      if (index != -1) {
        final existing = _applicantApplications[index];
        if (jobId.isEmpty) jobId = existing.jobId;
        _applicantApplications[index] = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }
      final jobAppIndex = _jobApplications.indexWhere(
        (a) => a.id == applicationId,
      );
      if (jobAppIndex != -1) {
        final existing = _jobApplications[jobAppIndex];
        if (jobId.isEmpty) jobId = existing.jobId;
        _jobApplications[jobAppIndex] = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }
      if (_selectedApplication != null &&
          _selectedApplication!.id == applicationId) {
        final existing = _selectedApplication!;
        if (jobId.isEmpty) jobId = existing.jobId;
        _selectedApplication = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }

      // Reset isApplied status for the job so user can re-apply if desired
      if (jobId.isNotEmpty) {
        if (_selectedJob != null && _selectedJob!.id == jobId) {
          _selectedJob = _selectedJob!.copyWith(isApplied: false);
        }
        final pubIndex = _publicJobs.indexWhere((j) => j.id == jobId);
        if (pubIndex != -1) {
          _publicJobs[pubIndex] = _publicJobs[pubIndex].copyWith(
            isApplied: false,
          );
        }
      }

      _hasFetchedApplicantApplications = false;
      _applicantStats = null;
      _successMessage = 'Application withdrawn successfully!';
      try {
        fetchApplicantStats();
      } catch (_) {}
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if current user has an active (non-withdrawn) application for a job
  bool isUserAppliedToJob(String jobId) {
    if (jobId.isEmpty) return false;
    final hasApp = _applicantApplications.any(
      (a) => a.jobId == jobId && a.status != JobApplicationStatus.withdrawn,
    );
    if (hasApp) return true;
    if (_selectedJob != null && _selectedJob!.id == jobId) {
      return _selectedJob!.isApplied ?? false;
    }
    final pubMatch = _publicJobs.cast<JobModel?>().firstWhere(
      (j) => j?.id == jobId,
      orElse: () => null,
    );
    if (pubMatch?.isApplied == true) return true;
    return false;
  }

  // 13. Update Application Status (Employer)
  Future<bool> updateApplicationStatus(
    String applicationId,
    JobApplicationStatus status,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final updatedApp = await _jobRepository.updateApplicationStatus(
        applicationId,
        status,
      );
      final index = _jobApplications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        final existing = _jobApplications[index];
        _jobApplications[index] = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }
      final appIndex = _applicantApplications.indexWhere(
        (a) => a.id == applicationId,
      );
      if (appIndex != -1) {
        final existing = _applicantApplications[appIndex];
        _applicantApplications[appIndex] = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }
      if (_selectedApplication != null &&
          _selectedApplication!.id == applicationId) {
        final existing = _selectedApplication!;
        _selectedApplication = updatedApp.copyWith(
          applicant: updatedApp.applicant ?? existing.applicant,
          job: updatedApp.job ?? existing.job,
        );
      }
      _hasFetchedApplicantApplications = false;
      _applicantStats = null;
      _employerStats = null;
      _successMessage = 'Application status updated successfully!';
      try {
        fetchEmployerStats();
      } catch (_) {}
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 14. Bulk Update Application Status (Employer)
  Future<bool> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    JobApplicationStatus status,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _jobRepository.bulkUpdateApplicationStatus(
        applicationIds,
        status,
      );
      final count = res['updatedCount'] ?? applicationIds.length;
      _successMessage = '$count application(s) updated successfully!';

      // Update local state
      for (final id in applicationIds) {
        final idx = _jobApplications.indexWhere((a) => a.id == id);
        if (idx != -1) {
          final old = _jobApplications[idx];
          _jobApplications[idx] = old.copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }
      }
      _hasFetchedApplicantApplications = false;
      _applicantStats = null;
      _employerStats = null;
      try {
        fetchEmployerStats();
      } catch (_) {}
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 15. Fetch Employer Stats
  Future<void> fetchEmployerStats() async {
    try {
      _employerStats = await _jobRepository.getEmployerStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
  }

  // 16. Fetch Applicant Stats
  Future<void> fetchApplicantStats({bool force = false}) async {
    if (!force && (_isFetchingApplicantStats || _applicantStats != null)) return;
    _isFetchingApplicantStats = true;
    try {
      _applicantStats = await _jobRepository.getApplicantStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isFetchingApplicantStats = false;
    }
  }

  // 17. Fetch Applications for a Specific Job (Employer view)
  Future<void> fetchJobApplications(
    String jobId, {
    int page = 1,
    int limit = 10,
    JobApplicationStatus? status,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final res = await _jobRepository.getJobApplications(
        jobId,
        page: page,
        limit: limit,
        status: status,
      );
      _jobApplications = res['applications'] as List<JobApplicationModel>;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _fetchedJobApplicationsId = jobId;
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab Filter & Bookmark Management
  // ──────────────────────────────────────────────────────────────────────────
  String _selectedTab = 'All';
  String get selectedTab => _selectedTab;

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  final Set<String> _bookmarkedJobIds = {};
  bool isJobBookmarked(String id) => _bookmarkedJobIds.contains(id);

  bool toggleBookmarkJob(
    String id, {
    JobModel? job,
    FavouriteAdsViewModel? favViewModel,
  }) {
    final bool currentlyBookmarked = _bookmarkedJobIds.contains(id);
    final bool nowBookmarked = !currentlyBookmarked;

    if (nowBookmarked) {
      _bookmarkedJobIds.add(id);
    } else {
      _bookmarkedJobIds.remove(id);
    }

    // Persist bookmark IDs locally
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(
        'key_bookmarked_job_ids',
        _bookmarkedJobIds.toList(),
      );
    }).catchError((_) {});

    // Resolve job model
    final resolvedJob = job ??
        _publicJobs.where((j) => j.id == id).firstOrNull ??
        _userJobs.where((j) => j.id == id).firstOrNull ??
        (_selectedJob?.id == id ? _selectedJob : null);

    // Synchronize instantly with FavouriteAdsViewModel (0ms optimistic)
    final targetFavVM = favViewModel ?? _favouriteAdsViewModel;
    if (targetFavVM != null) {
      if (resolvedJob != null) {
        targetFavVM.syncJobBookmark(resolvedJob, nowBookmarked);
      } else {
        targetFavVM.toggleFavourite(id);
      }
    }

    notifyListeners();
    return nowBookmarked;
  }

  void syncBookmarkStatus(String id, bool isBookmarked) {
    if (isBookmarked) {
      _bookmarkedJobIds.add(id);
    } else {
      _bookmarkedJobIds.remove(id);
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(
        'key_bookmarked_job_ids',
        _bookmarkedJobIds.toList(),
      );
    }).catchError((_) {});
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Jobs View Mode, Filters & Location Helpers (MVVM)
  // ──────────────────────────────────────────────────────────────────────────
  int _selectedViewMode = 0; // 0 = Job Vacancies, 1 = Work Requests (Need-a-Worker)
  int get selectedViewMode => _selectedViewMode;

  void setSelectedViewMode(int mode) {
    if (_selectedViewMode != mode) {
      _selectedViewMode = mode;
      notifyListeners();
    }
  }

  static const List<String> defaultFilters = [
    'All',
    'Full Time',
    'Part Time',
    'Freelance',
    'Contract',
    'Internship',
  ];
  List<String> get filters => defaultFilters;

  JobType? getJobTypeFromFilter(String filter) {
    switch (filter) {
      case 'Full Time':
        return JobType.fullTime;
      case 'Part Time':
        return JobType.partTime;
      case 'Freelance':
        return JobType.freelance;
      case 'Contract':
        return JobType.contract;
      case 'Internship':
        return JobType.internship;
      default:
        return null;
    }
  }

  void onFilterSelected(String filter) {
    setSelectedTab(filter);
    setTypeFilter(getJobTypeFromFilter(filter));
    fetchPublicJobs(force: true);
  }

  /// Build a short location label from the user's address.
  String getUserLocationLabel(AuthViewModel authVM) {
    final address = authVM.currentUser?.address;
    final city = address?.city?.trim() ?? '';
    final country = address?.country?.trim() ?? '';
    final province = address?.province?.trim() ?? '';
    final street = address?.streetAddress.trim() ?? '';

    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    }
    if (city.isNotEmpty) return city;
    if (province.isNotEmpty && country.isNotEmpty) {
      return '$province, $country';
    }
    if (country.isNotEmpty) return country;
    if (province.isNotEmpty) return province;
    if (street.isNotEmpty) return street;

    return 'Madrid, Spain';
  }

  /// Sort jobs so those matching the user's city/location appear first.
  List<JobModel> getSortedJobs(AuthViewModel authVM) {
    final userCity =
        authVM.currentUser?.address?.city?.trim().toLowerCase() ?? '';
    final userProvince =
        authVM.currentUser?.address?.province?.trim().toLowerCase() ?? '';
    final userCountry =
        authVM.currentUser?.address?.country?.trim().toLowerCase() ?? '';

    final effectiveCity = userCity.isNotEmpty ? userCity : 'madrid';
    final effectiveCountry = userCountry.isNotEmpty ? userCountry : 'spain';

    final sorted = List<JobModel>.from(_publicJobs);
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

  bool _hasLoadedJobsView = false;
  bool _isLoadingJobsView = false;
  bool get hasLoadedJobsView => _hasLoadedJobsView;
  bool get isLoadingJobsView => _isLoadingJobsView;

  Future<void> initializeJobsView({
    required AuthViewModel authVM,
    required NeedWorkerViewModel needWorkerVM,
    bool force = false,
  }) async {
    if ((_hasLoadedJobsView && !force) || _isLoadingJobsView) return;
    _isLoadingJobsView = true;

    try {
      if (authVM.currentUser == null) {
        await authVM.checkSession();
      }
      if (authVM.currentUser != null && authVM.currentUser?.address == null) {
        await authVM.fetchUserProfile();
      }
    } catch (_) {}

    try {
      await Future.wait([
        fetchPublicJobs(force: force),
        needWorkerVM.fetchFeed(force: force),
      ]);
    } finally {
      _hasLoadedJobsView = true;
      _isLoadingJobsView = false;
      notifyListeners();
    }
  }

  void resetJobsView() {
    _hasLoadedJobsView = false;
    _isLoadingJobsView = false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Post Job Form State Management (MVVM)
  // ──────────────────────────────────────────────────────────────────────────
  final GlobalKey<FormState> postJobFormKey = GlobalKey<FormState>();

  final TextEditingController postTitleController = TextEditingController();
  final TextEditingController postCompanyController = TextEditingController();
  final TextEditingController postSalaryController = TextEditingController();
  final TextEditingController postCategoryController = TextEditingController();
  final TextEditingController postLocationController = TextEditingController();
  final TextEditingController postDescriptionController = TextEditingController();
  final TextEditingController postSkillsController = TextEditingController();

  File? _postPosterFile;
  File? get postPosterFile => _postPosterFile;

  void setPostPosterFile(File? file) {
    _postPosterFile = file;
    notifyListeners();
  }

  Future<void> pickPosterImage([BuildContext? context]) async {
    final allowed = await PermissionService.requestGallery(context);
    if (!allowed) return;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (pickedFile != null) {
        _postPosterFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking poster image: $e');
    }
  }

  String? _postCategoryId;
  String? get postCategoryId => _postCategoryId;
  void setPostCategoryId(String? id) {
    _postCategoryId = id;
    notifyListeners();
  }

  String _postJobType = 'Full Time';
  String get postJobType => _postJobType;

  String _postExperience = 'Any';
  String get postExperience => _postExperience;

  String _postEducation = 'Any';
  String get postEducation => _postEducation;

  String _postSalaryPeriod = 'Month';
  String get postSalaryPeriod => _postSalaryPeriod;

  String _postWorkLocation = 'Remote';
  String get postWorkLocation => _postWorkLocation;

  final List<String> _postLanguages = ['English'];
  List<String> get postLanguages => List.unmodifiable(_postLanguages);

  final List<String> _postBenefits = [];
  List<String> get postBenefits => List.unmodifiable(_postBenefits);

  DateTime? _postDeadlineDate;
  DateTime? get postDeadlineDate => _postDeadlineDate;

  bool _postIsBoosted = false;
  bool get postIsBoosted => _postIsBoosted;

  JobStatus _postStatus = JobStatus.open;
  JobStatus get postStatus => _postStatus;

  List<String> get postJobTypes => const [
    'Full Time',
    'Part Time',
    'Freelance',
    'Contract',
    'Internship',
  ];

  List<String> get postExperienceOptions => const [
    'Any',
    'Entry Level',
    '1+ Years',
    '1-2 Years',
    '2+ Years',
    '3+ Years',
    '3-5 Years',
    '5+ Years',
  ];

  List<String> get postSalaryPeriods => const [
    'Hour',
    'Day',
    'Week',
    'Month',
    'Year',
  ];

  String? _currentEditingJobId;
  String? get currentEditingJobId => _currentEditingJobId;

  JobModel? _editingJob;
  JobModel? get editingJob => _editingJob;

  double get formProgress {
    int filled = 0;
    const int totalFields = 8;

    if (_postPosterFile != null ||
        (_editingJob?.posterUrl != null &&
            _editingJob!.posterUrl!.isNotEmpty)) {
      filled++;
    }
    if (postTitleController.text.trim().isNotEmpty) filled++;
    if (postCompanyController.text.trim().isNotEmpty) filled++;
    if (postCategoryController.text.trim().isNotEmpty) filled++;
    if (postSalaryController.text.trim().isNotEmpty) filled++;
    if (postLocationController.text.trim().isNotEmpty) filled++;
    if (postDescriptionController.text.trim().isNotEmpty) filled++;
    if (postSkillsController.text.trim().isNotEmpty) filled++;

    return (filled / totalFields).clamp(0.0, 1.0);
  }

  void setPostJobType(String val) {
    _postJobType = val;
    notifyListeners();
  }

  void setPostExperience(String val) {
    _postExperience = val;
    notifyListeners();
  }

  void setPostEducation(String val) {
    _postEducation = val;
    notifyListeners();
  }

  void setPostSalaryPeriod(String val) {
    _postSalaryPeriod = val;
    notifyListeners();
  }

  void setPostWorkLocation(String val) {
    _postWorkLocation = val;
    notifyListeners();
  }

  void togglePostLanguage(String lang) {
    if (_postLanguages.contains(lang)) {
      if (_postLanguages.length > 1) {
        _postLanguages.remove(lang);
      }
    } else {
      _postLanguages.add(lang);
    }
    notifyListeners();
  }

  void togglePostBenefit(String benefit) {
    if (_postBenefits.contains(benefit)) {
      _postBenefits.remove(benefit);
    } else {
      _postBenefits.add(benefit);
    }
    notifyListeners();
  }

  void setPostDeadlineDate(DateTime? date) {
    _postDeadlineDate = date;
    notifyListeners();
  }

  void togglePostIsBoosted() {
    _postIsBoosted = !_postIsBoosted;
    notifyListeners();
  }

  void setPostStatus(JobStatus status) {
    _postStatus = status;
    notifyListeners();
  }

  void initPostJobForm(JobModel? job, {bool notify = true}) {
    _currentEditingJobId = job?.id ?? 'NEW_JOB';
    _editingJob = job;
    _postPosterFile = null;
    _postCategoryId = job?.categoryId;

    postTitleController.text = job?.title ?? '';
    postCompanyController.text = job?.companyName ?? '';
    postSalaryController.text = job != null ? job.salary : '';
    postCategoryController.text = job?.category.displayName ?? '';
    postLocationController.text = job?.location ?? '';
    postDescriptionController.text = job?.description ?? '';
    postSkillsController.text = job?.requiredSkills ?? '';

    if (job != null) {
      _postStatus = job.status;
      _postJobType = job.type.displayName;
      if (!postJobTypes.contains(_postJobType)) {
        _postJobType = postJobTypes.first;
      }

      _postExperience = job.experience == Experience.noExperience
          ? 'Any'
          : job.experience.displayName;
      if (!postExperienceOptions.contains(_postExperience)) {
        _postExperience = postExperienceOptions.first;
      }

      _postSalaryPeriod = job.salaryPeriod.displayName.replaceAll('Per ', '');
      if (!postSalaryPeriods.contains(_postSalaryPeriod)) {
        _postSalaryPeriod = postSalaryPeriods.first;
      }

      _postWorkLocation = job.workMode.displayName;
      _postLanguages.clear();
      _postLanguages.addAll(job.languages.map((l) => l.displayName));
      _postBenefits.clear();
      _postBenefits.addAll(job.benefits.map((b) => b.displayName));
      _postDeadlineDate = null;
      _postIsBoosted = false;
    } else {
      _postStatus = JobStatus.open;
      _postJobType = 'Full Time';
      _postExperience = 'Any';
      _postEducation = 'Any';
      _postSalaryPeriod = 'Month';
      _postWorkLocation = 'Remote';
      _postLanguages.clear();
      _postLanguages.add('English');
      _postBenefits.clear();
      _postDeadlineDate = null;
      _postIsBoosted = false;
    }
    if (notify) {
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
    }
  }

  void resetPostJobForm() {
    _currentEditingJobId = null;
    _editingJob = null;
    _postPosterFile = null;
    _postCategoryId = null;
    postTitleController.clear();
    postCompanyController.clear();
    postSalaryController.clear();
    postCategoryController.clear();
    postLocationController.clear();
    postDescriptionController.clear();
    postSkillsController.clear();
    _postStatus = JobStatus.open;
    _postJobType = 'Full Time';
    _postExperience = 'Any';
    _postEducation = 'Any';
    _postSalaryPeriod = 'Month';
    _postWorkLocation = 'Remote';
    _postLanguages.clear();
    _postLanguages.add('English');
    _postBenefits.clear();
    _postDeadlineDate = null;
    _postIsBoosted = false;
    notifyListeners();
  }

  Future<bool> submitJobForm({JobModel? initialJob}) async {
    final targetJob = initialJob ?? _editingJob;
    if (targetJob != null) {
      final bool mainUpdateSuccess = await updateJob(
        targetJob.id,
        title: postTitleController.text.trim(),
        companyName: postCompanyController.text.trim().isNotEmpty
            ? postCompanyController.text.trim()
            : 'Company',
        category: JobCategoryX.fromString(postCategoryController.text.trim()),
        categoryId: _postCategoryId ?? targetJob.categoryId,
        salary: postSalaryController.text.trim(),
        minSalary: postSalaryController.text.trim(),
        maxSalary: postSalaryController.text.trim(),
        salaryPeriod: SalaryPeriodX.fromString(_postSalaryPeriod),
        type: JobTypeX.fromString(_postJobType),
        experience: ExperienceX.fromString(_postExperience),
        languages: _postLanguages.isEmpty
            ? [Language.english]
            : _postLanguages
                .map((l) => LanguageX.fromString(l))
                .toSet()
                .toList(),
        location: postLocationController.text.trim(),
        workMode: WorkModeX.fromString(_postWorkLocation),
        description: postDescriptionController.text.trim(),
        requiredSkills: postSkillsController.text.trim(),
        benefits: targetJob.benefits,
      );

      bool statusUpdateSuccess = true;
      if (mainUpdateSuccess && _postStatus != targetJob.status) {
        if (targetJob.status == JobStatus.open) {
          if (_postStatus == JobStatus.closed) {
            statusUpdateSuccess = await markJobClosed(targetJob.id);
          } else if (_postStatus == JobStatus.archived) {
            statusUpdateSuccess = await markJobArchived(targetJob.id);
          }
        }
      }

      bool posterUpdateSuccess = true;
      if (mainUpdateSuccess && _postPosterFile != null) {
        posterUpdateSuccess = await updateJobPoster(
          targetJob.id,
          _postPosterFile!,
        );
      }

      return mainUpdateSuccess && statusUpdateSuccess && posterUpdateSuccess;
    } else {
      return await createJob(
        posterFile: _postPosterFile,
        title: postTitleController.text.trim(),
        companyName: postCompanyController.text.trim().isNotEmpty
            ? postCompanyController.text.trim()
            : 'Company',
        category: JobCategoryX.fromString(postCategoryController.text.trim()),
        categoryId: _postCategoryId,
        salary: postSalaryController.text.trim(),
        minSalary: postSalaryController.text.trim(),
        maxSalary: postSalaryController.text.trim(),
        salaryPeriod: SalaryPeriodX.fromString(_postSalaryPeriod),
        type: JobTypeX.fromString(_postJobType),
        experience: ExperienceX.fromString(_postExperience),
        education: Education.highSchool,
        languages: _postLanguages.isEmpty
            ? [Language.english]
            : _postLanguages
                .map((l) => LanguageX.fromString(l))
                .toSet()
                .toList(),
        location: postLocationController.text.trim(),
        workMode: WorkModeX.fromString(_postWorkLocation),
        description: postDescriptionController.text.trim(),
        requiredSkills: postSkillsController.text.trim(),
        benefits: _postBenefits.isEmpty
            ? const [Benefit.paidLeave]
            : _postBenefits
                .map((b) => BenefitX.fromString(b))
                .toSet()
                .toList(),
        applicationDeadline: _postDeadlineDate ??
            DateTime.now().add(const Duration(days: 30)),
      );
    }
  }

  // ─── Edit Job Form State & Handlers ───
  JobModel? _resolvedEditJob;
  JobModel? get resolvedEditJob => _resolvedEditJob;
  bool _isSavingJob = false;
  bool get isSavingJob => _isSavingJob;
  List<String> _editJobRequirements = [];
  List<String> get editJobRequirements => _editJobRequirements;
  final TextEditingController editJobAddRequirementController =
      TextEditingController();
  dynamic _lastEditJobArg;

  void initEditJob(dynamic arg) {
    if (_lastEditJobArg == arg && _resolvedEditJob != null) return;
    _lastEditJobArg = arg;

    if (arg is JobModel) {
      _resolvedEditJob = arg;
      _initEditJobRequirements(arg);
      initPostJobForm(arg);
    } else if (arg is String) {
      fetchJobDetails(arg).then((_) {
        if (selectedJob != null) {
          _resolvedEditJob = selectedJob;
          _initEditJobRequirements(selectedJob!);
          initPostJobForm(selectedJob);
          notifyListeners();
        }
      });
    } else if (arg is Map<String, dynamic>) {
      try {
        final model = JobModel.fromJson(arg);
        _resolvedEditJob = model;
        _initEditJobRequirements(model);
        initPostJobForm(model);
      } catch (_) {}
    } else {
      if (selectedJob != null) {
        _resolvedEditJob = selectedJob;
        _initEditJobRequirements(selectedJob!);
        initPostJobForm(selectedJob);
      }
    }
    notifyListeners();
  }

  void _initEditJobRequirements(JobModel job) {
    if (job.requiredSkills.isNotEmpty) {
      _editJobRequirements = job.requiredSkills
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      _editJobRequirements = [
        'Experience in cooking',
        'Must be hardworking',
        'Able to work in team',
      ];
    }
  }

  void addEditJobRequirement(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty && !_editJobRequirements.contains(trimmed)) {
      _editJobRequirements.add(trimmed);
      postSkillsController.text = _editJobRequirements.join(', ');
      notifyListeners();
    }
  }

  void removeEditJobRequirement(int index) {
    if (index >= 0 && index < _editJobRequirements.length) {
      _editJobRequirements.removeAt(index);
      postSkillsController.text = _editJobRequirements.join(', ');
      notifyListeners();
    }
  }

  Future<bool> saveJobChanges() async {
    _isSavingJob = true;
    notifyListeners();

    postSkillsController.text = _editJobRequirements.join(', ');
    final effectiveJob = _resolvedEditJob ?? _editingJob ?? _selectedJob;
    final bool success = await submitJobForm(initialJob: effectiveJob);

    _isSavingJob = false;
    notifyListeners();
    return success;
  }
}
