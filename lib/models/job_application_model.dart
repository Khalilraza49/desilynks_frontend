import 'job_enums.dart';

class ApplicantInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? profilePhotoUrl;

  ApplicantInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ApplicantInfo.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    }

    return ApplicantInfo(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      profilePhotoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhoto': profilePhotoUrl != null ? {'url': profilePhotoUrl} : null,
    };
  }
}

class JobSummary {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final JobType type;
  final WorkMode workMode;
  final String minSalary;
  final String maxSalary;
  final SalaryPeriod salaryPeriod;
  final DateTime applicationDeadline;
  final String? employerId;

  JobSummary({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.type,
    required this.workMode,
    required this.minSalary,
    required this.maxSalary,
    required this.salaryPeriod,
    required this.applicationDeadline,
    this.employerId,
  });

  factory JobSummary.fromJson(Map<String, dynamic> json) {
    return JobSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: JobTypeX.fromString(json['type'] as String?),
      workMode: WorkModeX.fromString(json['workMode'] as String?),
      minSalary: json['minSalary']?.toString() ?? '0',
      maxSalary: json['maxSalary']?.toString() ?? '0',
      salaryPeriod: SalaryPeriodX.fromString(json['salaryPeriod'] as String?),
      applicationDeadline:
          DateTime.tryParse(json['applicationDeadline'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      employerId: json['employerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'location': location,
      'type': type.toApiKey(),
      'workMode': workMode.toApiKey(),
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'salaryPeriod': salaryPeriod.toApiKey(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      if (employerId != null) 'employerId': employerId,
    };
  }
}

class JobApplicationModel {
  final String id;
  final String jobId;
  final String applicantId;
  final JobApplicationStatus status;
  final String? coverLetter;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobSummary? job;
  final ApplicantInfo? applicant;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.status,
    this.coverLetter,
    required this.createdAt,
    required this.updatedAt,
    this.job,
    this.applicant,
  });

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? applicantId,
    JobApplicationStatus? status,
    String? coverLetter,
    DateTime? createdAt,
    DateTime? updatedAt,
    JobSummary? job,
    ApplicantInfo? applicant,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      job: job ?? this.job,
      applicant: applicant ?? this.applicant,
    );
  }

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      applicantId: json['applicantId'] as String? ?? '',
      status: JobApplicationStatusX.fromString(json['status'] as String?),
      coverLetter: json['coverLetter'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      job: json['job'] != null && json['job'] is Map<String, dynamic>
          ? JobSummary.fromJson(json['job'] as Map<String, dynamic>)
          : null,
      applicant:
          json['applicant'] != null && json['applicant'] is Map<String, dynamic>
          ? ApplicantInfo.fromJson(json['applicant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'applicantId': applicantId,
      'status': status.toApiKey(),
      'coverLetter': coverLetter,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (job != null) 'job': job!.toJson(),
      if (applicant != null) 'applicant': applicant!.toJson(),
    };
  }
}

class ApplicationStatsModel {
  final int pending;
  final int reviewing;
  final int shortlisted;
  final int interview;
  final int offered;
  final int rejected;
  final int withdrawn;
  final int total;

  ApplicationStatsModel({
    required this.pending,
    required this.reviewing,
    required this.shortlisted,
    required this.interview,
    required this.offered,
    required this.rejected,
    required this.withdrawn,
    required this.total,
  });

  factory ApplicationStatsModel.fromJson(Map<String, dynamic> json) {
    return ApplicationStatsModel(
      pending: (json['PENDING'] as num?)?.toInt() ?? 0,
      reviewing: (json['REVIEWING'] as num?)?.toInt() ?? 0,
      shortlisted: (json['SHORTLISTED'] as num?)?.toInt() ?? 0,
      interview: (json['INTERVIEW'] as num?)?.toInt() ?? 0,
      offered: (json['OFFERED'] as num?)?.toInt() ??
          (json['SELECTED'] as num?)?.toInt() ??
          0,
      rejected: (json['REJECTED'] as num?)?.toInt() ?? 0,
      withdrawn: (json['WITHDRAWN'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PENDING': pending,
      'REVIEWING': reviewing,
      'SHORTLISTED': shortlisted,
      'INTERVIEW': interview,
      'OFFERED': offered,
      'REJECTED': rejected,
      'WITHDRAWN': withdrawn,
      'total': total,
    };
  }
}
