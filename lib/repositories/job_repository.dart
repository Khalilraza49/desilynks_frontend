import 'dart:convert';
import 'dart:io';
import '../models/job_application_model.dart';
import '../models/job_enums.dart';
import '../models/job_model.dart';
import '../services/api/api_endpoints.dart';
import '../services/api/api_service.dart';

class JobRepository {
  final ApiService _apiService;

  JobRepository(this._apiService);

  // 1. Create Job (POST /job - multipart/form-data)
  Future<JobModel> createJob({
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
    Education? education, // Deprecated: removed from backend
    required List<Language> languages,
    required String location,
    required WorkMode workMode,
    required String description,
    required String requiredSkills,
    List<Benefit>? benefits, // Deprecated: removed from backend
    DateTime? applicationDeadline, // Deprecated: removed from backend
  }) async {
    final rawSalary = (salary != null && salary.trim().isNotEmpty)
        ? salary
        : (minSalary != null && minSalary.trim().isNotEmpty)
        ? minSalary
        : (maxSalary != null && maxSalary.trim().isNotEmpty)
        ? maxSalary
        : '0';

    final cleanSalary = rawSalary.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final double parsedSalary = double.tryParse(cleanSalary) ?? 0.0;
    final String formattedSalary = parsedSalary.toStringAsFixed(2);

    final String resolvedCategoryId =
        (categoryId != null && JobCategoryHelper.isUuid(categoryId))
        ? categoryId
        : JobCategoryHelper.toUuid(category ?? JobCategory.other);

    final fields = <String, String>{
      'title': title,
      'companyName': companyName,
      'categoryId': resolvedCategoryId,
      'salary': formattedSalary,
      'salaryPeriod': salaryPeriod.toApiKey(),
      'type': type.toApiKey(),
      'experience': experience.toApiKey(),
      'languages': jsonEncode(languages.map((l) => l.toApiKey()).toList()),
      'location': location,
      'workMode': workMode.toApiKey(),
      'description': description,
      'requiredSkills': requiredSkills,
    };

    final response = await _apiService.multipartRequest(
      method: 'POST',
      endpoint: ApiEndpoints.jobEndpoint,
      fields: fields,
      singleFile: posterFile,
      singleFileKey: 'poster',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = (resBody['data'] is Map<String, dynamic>)
        ? resBody['data'] as Map<String, dynamic>
        : resBody;
    return JobModel.fromJson(data);
  }

  // 2. Get User's Own Jobs (GET /job/user)
  Future<Map<String, dynamic>> getUserJobs({
    int page = 1,
    int limit = 10,
  }) async {
    final query = '?page=$page&limit=$limit';
    final response = await _apiService.get(
      '${ApiEndpoints.userJobsEndpoint}$query',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final jobs = dataList
        .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return {'jobs': jobs, 'meta': body['meta'] ?? {}};
  }

  // 3. Get All Jobs / Public Feed (GET /job)
  Future<Map<String, dynamic>> getPublicJobs({
    int page = 1,
    int limit = 10,
    JobCategory? category,
    JobType? type,
    Experience? experience,
    Education? education,
    WorkMode? workMode,
    double? minSalary,
    double? maxSalary,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];

    if (category != null) queryParams.add('category=${category.toApiKey()}');
    if (type != null) queryParams.add('type=${type.toApiKey()}');
    if (experience != null) {
      queryParams.add('experience=${experience.toApiKey()}');
    }
    if (education != null) queryParams.add('education=${education.toApiKey()}');
    if (workMode != null) queryParams.add('workMode=${workMode.toApiKey()}');
    if (minSalary != null) queryParams.add('minSalary=$minSalary');
    if (maxSalary != null) queryParams.add('maxSalary=$maxSalary');

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.jobEndpoint}$queryString',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final jobs = dataList
        .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return {'jobs': jobs, 'meta': body['meta'] ?? {}};
  }

  // 4. Get Job by ID (GET /job/:id)
  Future<JobModel> getJobById(String id) async {
    final response = await _apiService.get(ApiEndpoints.jobDetailsEndpoint(id));
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = (body['data'] is Map<String, dynamic>)
        ? body['data'] as Map<String, dynamic>
        : body;
    return JobModel.fromJson(data);
  }

  // 5. Update Job Details (PATCH /job/:id)
  Future<JobModel> updateJob(
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
    Education? education, // Deprecated
    required List<Language> languages,
    required String location,
    required WorkMode workMode,
    required String description,
    required String requiredSkills,
    List<Benefit>? benefits, // Deprecated
    DateTime? applicationDeadline, // Deprecated
  }) async {
    final rawSalary = (salary != null && salary.trim().isNotEmpty)
        ? salary
        : (minSalary != null && minSalary.trim().isNotEmpty)
        ? minSalary
        : (maxSalary != null && maxSalary.trim().isNotEmpty)
        ? maxSalary
        : '0';

    final cleanSalary = rawSalary.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    final double parsedSalary = double.tryParse(cleanSalary) ?? 0.0;
    final String formattedSalary = parsedSalary.toStringAsFixed(2);

    final String resolvedCategoryId =
        (categoryId != null && JobCategoryHelper.isUuid(categoryId))
        ? categoryId
        : JobCategoryHelper.toUuid(category ?? JobCategory.other);

    final body = {
      'title': title,
      'companyName': companyName,
      'categoryId': resolvedCategoryId,
      'salary': formattedSalary,
      'salaryPeriod': salaryPeriod.toApiKey(),
      'type': type.toApiKey(),
      'experience': experience.toApiKey(),
      'languages': languages.map((l) => l.toApiKey()).toList(),
      'location': location,
      'workMode': workMode.toApiKey(),
      'description': description,
      'requiredSkills': requiredSkills,
    };

    final response = await _apiService.patch(
      ApiEndpoints.jobDetailsEndpoint(id),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = (resBody['data'] is Map<String, dynamic>)
        ? resBody['data'] as Map<String, dynamic>
        : resBody;
    return JobModel.fromJson(data);
  }

  // 5b. Update Job Poster Image (PATCH /job/:id/poster)
  Future<JobModel> updateJobPoster(String id, File posterFile) async {
    final response = await _apiService.multipartRequest(
      method: 'PATCH',
      endpoint: '${ApiEndpoints.jobDetailsEndpoint(id)}/poster',
      fields: {},
      singleFile: posterFile,
      singleFileKey: 'poster',
    );

    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return JobModel.fromJson(data);
  }

  // 6. Mark Job as Closed (PATCH /job/:id/mark-closed)
  Future<String> markJobClosed(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.jobMarkClosedEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] as String? ?? 'Job marked as closed successfully';
  }

  // 7. Mark Job as Archived (PATCH /job/:id/mark-archived)
  Future<String> markJobArchived(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.jobMarkArchivedEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] as String? ?? 'Job archived successfully';
  }

  // 8. Delete Job (DELETE /job/:id)
  Future<String> deleteJob(String id) async {
    final response = await _apiService.delete(
      ApiEndpoints.jobDetailsEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['message'] as String? ?? 'Job deleted successfully';
  }

  // 9. Apply for Job (POST /job/:id/apply)
  Future<JobApplicationModel> applyForJob(
    String jobId, {
    String? coverLetter,
  }) async {
    final body = <String, dynamic>{};
    if (coverLetter != null && coverLetter.isNotEmpty) {
      body['coverLetter'] = coverLetter;
    }

    final response = await _apiService.post(
      ApiEndpoints.jobApplyEndpoint(jobId),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return JobApplicationModel.fromJson(data);
  }

  // 10. Get User's Own Applications (GET /job/applications/me)
  Future<Map<String, dynamic>> getApplicantApplications({
    int page = 1,
    int limit = 10,
    JobApplicationStatus? status,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];

    if (status != null) {
      queryParams.add('status=${status.toApiKey()}');
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.userApplicationsEndpoint}$queryString',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final applications = dataList
        .map(
          (item) => JobApplicationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return {'applications': applications, 'meta': body['meta'] ?? {}};
  }

  // 11. Get Application by ID (GET /job/application/:id)
  Future<JobApplicationModel> getApplicationById(String id) async {
    final response = await _apiService.get(
      ApiEndpoints.applicationDetailsEndpoint(id),
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return JobApplicationModel.fromJson(data);
  }

  // 12. Withdraw Application (PATCH /job/application/:id/withdraw)
  Future<JobApplicationModel> withdrawApplication(String id) async {
    final response = await _apiService.patch(
      ApiEndpoints.withdrawApplicationEndpoint(id),
      {},
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return JobApplicationModel.fromJson(data);
  }

  // 13. Update Application Status (Employer) (PATCH /job/application/:id/status)
  Future<JobApplicationModel> updateApplicationStatus(
    String id,
    JobApplicationStatus status,
  ) async {
    final body = {'status': status.toApiKey()};

    final response = await _apiService.patch(
      ApiEndpoints.updateApplicationStatusEndpoint(id),
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    final data = resBody['data'] as Map<String, dynamic>;
    return JobApplicationModel.fromJson(data);
  }

  // 14. Bulk Update Application Status (Employer) (PATCH /job/applications/bulk-status)
  Future<Map<String, dynamic>> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    JobApplicationStatus status,
  ) async {
    final body = {
      'applicationIds': applicationIds,
      'status': status.toApiKey(),
    };

    final response = await _apiService.patch(
      ApiEndpoints.bulkUpdateApplicationStatusEndpoint,
      body,
    );
    final Map<String, dynamic> resBody = jsonDecode(response.body);
    return resBody['data'] as Map<String, dynamic>? ?? {};
  }

  // 15. Get Employer Application Stats (GET /job/applications/stats/employer)
  Future<ApplicationStatsModel> getEmployerStats() async {
    final response = await _apiService.get(
      ApiEndpoints.employerApplicationStatsEndpoint,
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return ApplicationStatsModel.fromJson(data);
  }

  // 16. Get Applicant Application Stats (GET /job/applications/stats/me)
  Future<ApplicationStatsModel> getApplicantStats() async {
    final response = await _apiService.get(
      ApiEndpoints.applicantApplicationStatsEndpoint,
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    return ApplicationStatsModel.fromJson(data);
  }

  // 17. Get Applications of a Job (Employer) (GET /job/:id/applications)
  Future<Map<String, dynamic>> getJobApplications(
    String jobId, {
    int page = 1,
    int limit = 10,
    JobApplicationStatus? status,
  }) async {
    final queryParams = <String>['page=$page', 'limit=$limit'];

    if (status != null) {
      queryParams.add('status=${status.toApiKey()}');
    }

    final queryString = '?${queryParams.join('&')}';
    final response = await _apiService.get(
      '${ApiEndpoints.jobApplicationsEndpoint(jobId)}$queryString',
    );
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> dataList = body['data'] as List? ?? [];

    final applications = dataList
        .map(
          (item) => JobApplicationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return {'applications': applications, 'meta': body['meta'] ?? {}};
  }
}
