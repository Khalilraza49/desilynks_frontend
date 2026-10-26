import '../services/api/api_endpoints.dart';
import 'job_enums.dart';

class EmployerInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  EmployerInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory EmployerInfo.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['profilePhoto'] != null && json['profilePhoto'] is Map) {
      photoUrl = json['profilePhoto']['url'] as String?;
    } else if (json['profilePhoto'] is String) {
      photoUrl = json['profilePhoto'] as String;
    } else if (json['profilePhotoUrl'] != null) {
      photoUrl = json['profilePhotoUrl'] as String?;
    }

    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http')) {
      final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
      photoUrl = '${ApiEndpoints.baseUrl}$path';
    }

    return EmployerInfo(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      profilePhotoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePhoto': profilePhotoUrl != null ? {'url': profilePhotoUrl} : null,
    };
  }
}

class JobCategoryHelper {
  JobCategoryHelper._();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isUuid(String value) => _uuidRegex.hasMatch(value.trim());

  static const Map<JobCategory, String> _categoryToUuid = {
    JobCategory.restaurantAndFood: 'c1e67e30-745a-4e78-9e5b-1c5c0c920001',
    JobCategory.drivingAndDelivery: 'c1e67e30-745a-4e78-9e5b-1c5c0c920002',
    JobCategory.cleaningAndHousekeeping: 'c1e67e30-745a-4e78-9e5b-1c5c0c920003',
    JobCategory.constructionAndLabour: 'c1e67e30-745a-4e78-9e5b-1c5c0c920004',
    JobCategory.itAndTechnology: 'c1e67e30-745a-4e78-9e5b-1c5c0c920005',
    JobCategory.salesAndMarketing: 'c1e67e30-745a-4e78-9e5b-1c5c0c920006',
    JobCategory.healthcare: 'c1e67e30-745a-4e78-9e5b-1c5c0c920007',
    JobCategory.educationAndTeaching: 'c1e67e30-745a-4e78-9e5b-1c5c0c920008',
    JobCategory.securityAndGuard: 'c1e67e30-745a-4e78-9e5b-1c5c0c920009',
    JobCategory.retailAndShop: 'c1e67e30-745a-4e78-9e5b-1c5c0c920010',
    JobCategory.other: 'c1e67e30-745a-4e78-9e5b-1c5c0c920011',
  };

  static const Map<String, JobCategory> _uuidToCategory = {
    'c1e67e30-745a-4e78-9e5b-1c5c0c920001': JobCategory.restaurantAndFood,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920002': JobCategory.drivingAndDelivery,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920003': JobCategory.cleaningAndHousekeeping,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920004': JobCategory.constructionAndLabour,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920005': JobCategory.itAndTechnology,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920006': JobCategory.salesAndMarketing,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920007': JobCategory.healthcare,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920008': JobCategory.educationAndTeaching,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920009': JobCategory.securityAndGuard,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920010': JobCategory.retailAndShop,
    'c1e67e30-745a-4e78-9e5b-1c5c0c920011': JobCategory.other,
  };

  static String toUuid(dynamic categoryOrId) {
    if (categoryOrId is String && isUuid(categoryOrId)) {
      return categoryOrId.trim().toLowerCase();
    }
    JobCategory category = JobCategory.other;
    if (categoryOrId is JobCategory) {
      category = categoryOrId;
    } else if (categoryOrId is String) {
      category = JobCategoryX.fromString(categoryOrId);
    }
    return _categoryToUuid[category] ?? _categoryToUuid[JobCategory.other]!;
  }

  static JobCategory fromUuid(String? uuid) {
    if (uuid == null) return JobCategory.other;
    return _uuidToCategory[uuid.trim().toLowerCase()] ?? JobCategory.other;
  }
}

class JobModel {
  final String id;
  final String employerId;
  final String title;
  final String companyName;
  final String? categoryId;
  final JobCategory category;
  final String salary;
  final SalaryPeriod salaryPeriod;
  final JobType type;
  final Experience experience;
  final List<Language> languages;
  final String location;
  final WorkMode workMode;
  final String description;
  final String requiredSkills;
  final List<Benefit> benefits;
  final JobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EmployerInfo? employer;
  final bool? isApplied;
  final String? posterUrl;
  final double? searchScore;
  final int viewsCount;
  final int applicantsCount;
  final int chatsCount;
  final int likesCount;

  JobModel({
    required this.id,
    required this.employerId,
    required this.title,
    required this.companyName,
    this.categoryId,
    this.category = JobCategory.other,
    String? salary,
    required this.salaryPeriod,
    required this.type,
    required this.experience,
    required this.languages,
    required this.location,
    required this.workMode,
    required this.description,
    required this.requiredSkills,
    this.benefits = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.employer,
    this.isApplied,
    this.posterUrl,
    this.searchScore,
    this.viewsCount = 0,
    this.applicantsCount = 0,
    this.chatsCount = 0,
    this.likesCount = 0,
  }) : salary = salary ?? '0.00';

  // Compatibility getters for external callers
  String get minSalary => salary;
  String get maxSalary => salary;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['poster'] != null && json['poster'] is Map) {
      photoUrl =
          json['poster']['url'] as String? ?? json['poster']['path'] as String?;
    } else if (json['poster'] is String) {
      photoUrl = json['poster'] as String;
    } else if (json['posterUrl'] != null) {
      photoUrl = json['posterUrl'] as String?;
    }

    if (photoUrl != null &&
        photoUrl.isNotEmpty &&
        !photoUrl.startsWith('http')) {
      final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
      photoUrl = '${ApiEndpoints.baseUrl}$path';
    }

    final rawSalary =
        json['salary']?.toString() ??
        json['minSalary']?.toString() ??
        json['maxSalary']?.toString() ??
        '0.00';

    String? categoryId = json['categoryId'] as String?;
    JobCategory category = JobCategory.other;

    if (json['category'] != null) {
      if (json['category'] is Map) {
        final catMap = json['category'] as Map<String, dynamic>;
        categoryId = catMap['id']?.toString() ?? categoryId;
        final catName =
            catMap['name']?.toString() ?? catMap['title']?.toString();
        category = JobCategoryX.fromString(catName);
      } else if (json['category'] is String) {
        final catStr = json['category'] as String;
        if (JobCategoryHelper.isUuid(catStr)) {
          categoryId = catStr;
          category = JobCategoryHelper.fromUuid(catStr);
        } else {
          category = JobCategoryX.fromString(catStr);
        }
      }
    } else if (categoryId != null) {
      category = JobCategoryHelper.fromUuid(categoryId);
    }

    return JobModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      employerId: json['employerId'] as String? ??
          (json['employer'] is Map
              ? (json['employer']['id']?.toString() ?? '')
              : (json['employer'] is String ? json['employer'] as String : '')),
      title: json['title'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      categoryId: categoryId,
      category: category,
      salary: rawSalary,
      salaryPeriod: SalaryPeriodX.fromString(json['salaryPeriod'] as String?),
      type: JobTypeX.fromString(json['type'] as String?),
      experience: ExperienceX.fromString(json['experience'] as String?),
      languages:
          (json['languages'] as List?)
              ?.map((l) => LanguageX.fromString(l as String?))
              .toList() ??
          [],
      location: json['location'] as String? ?? '',
      workMode: WorkModeX.fromString(json['workMode'] as String?),
      description: json['description'] as String? ?? '',
      requiredSkills: json['requiredSkills'] as String? ?? '',
      benefits:
          (json['benefits'] as List?)
              ?.map((b) => BenefitX.fromString(b as String?))
              .toList() ??
          [],
      status: JobStatusX.fromString(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      employer:
          json['employer'] != null && json['employer'] is Map<String, dynamic>
          ? EmployerInfo.fromJson(json['employer'] as Map<String, dynamic>)
          : null,
      isApplied: json.containsKey('isApplied')
          ? json['isApplied'] as bool?
          : null,
      posterUrl: photoUrl,
      searchScore: (json['_score'] as num?)?.toDouble(),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ??
          (json['views'] as num?)?.toInt() ??
          0,
      applicantsCount: (json['applicantsCount'] as num?)?.toInt() ??
          (json['applicationsCount'] as num?)?.toInt() ??
          (json['totalApplications'] as num?)?.toInt() ??
          (json['applications'] is List
              ? (json['applications'] as List).length
              : 0),
      chatsCount: (json['chatsCount'] as num?)?.toInt() ??
          (json['chats'] as num?)?.toInt() ??
          0,
      likesCount: (json['likesCount'] as num?)?.toInt() ??
          (json['likes'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'employerId': employerId,
      'title': title,
      'companyName': companyName,
      if (categoryId != null && categoryId!.isNotEmpty)
        'categoryId': categoryId,
      'salary': salary,
      'salaryPeriod': salaryPeriod.toApiKey(),
      'type': type.toApiKey(),
      'experience': experience.toApiKey(),
      'languages': languages.map((l) => l.toApiKey()).toList(),
      'location': location,
      'workMode': workMode.toApiKey(),
      'description': description,
      'requiredSkills': requiredSkills,
      'status': status.toApiKey(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewsCount': viewsCount,
      'applicantsCount': applicantsCount,
      'chatsCount': chatsCount,
      'likesCount': likesCount,
      if (posterUrl != null) 'poster': posterUrl,
    };

    if (employer != null) {
      data['employer'] = employer!.toJson();
    }
    if (isApplied != null) {
      data['isApplied'] = isApplied;
    }
    return data;
  }

  JobModel copyWith({
    String? id,
    String? employerId,
    String? title,
    String? companyName,
    String? categoryId,
    JobCategory? category,
    String? salary,
    SalaryPeriod? salaryPeriod,
    JobType? type,
    Experience? experience,
    List<Language>? languages,
    String? location,
    WorkMode? workMode,
    String? description,
    String? requiredSkills,
    List<Benefit>? benefits,
    JobStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    EmployerInfo? employer,
    bool? isApplied,
    String? posterUrl,
    double? searchScore,
    int? viewsCount,
    int? applicantsCount,
    int? chatsCount,
    int? likesCount,
  }) {
    return JobModel(
      id: id ?? this.id,
      employerId: employerId ?? this.employerId,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      salary: salary ?? this.salary,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      type: type ?? this.type,
      experience: experience ?? this.experience,
      languages: languages ?? this.languages,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      benefits: benefits ?? this.benefits,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      employer: employer ?? this.employer,
      isApplied: isApplied ?? this.isApplied,
      posterUrl: posterUrl ?? this.posterUrl,
      searchScore: searchScore ?? this.searchScore,
      viewsCount: viewsCount ?? this.viewsCount,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      chatsCount: chatsCount ?? this.chatsCount,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
