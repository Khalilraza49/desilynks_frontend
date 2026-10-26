import 'package:flutter/material.dart';
import '../core/constants/app_icons.dart';

enum ResourceHubCategory {
  immigration('IMMIGRATION', 'Immigration'),
  housing('HOUSING', 'Housing'),
  jobAndWork('JOB_AND_WORK', 'Jobs & Work'),
  healthcare('HEALTHCARE', 'Healthcare'),
  legalAdvice('LEGAL_ADVICE', 'Legal Advice'),
  education('EDUCATION', 'Education'),
  business('BUSINESS', 'Business'),
  taxes('TAXES', 'Taxes'),
  transport('TRANSPORT', 'Transport'),
  unknown('UNKNOWN', 'Other');

  const ResourceHubCategory(this.value, this.label);
  final String value;
  final String label;

  static ResourceHubCategory fromValue(String? value) {
    if (value == null || value.trim().isEmpty) return ResourceHubCategory.unknown;
    final upper = value.trim().toUpperCase();
    return ResourceHubCategory.values.firstWhere(
      (c) => c.value == upper,
      orElse: () => ResourceHubCategory.unknown,
    );
  }

  String get iconSvg {
    switch (this) {
      case ResourceHubCategory.immigration:
        return AppIcons.planeSvg;
      case ResourceHubCategory.housing:
        return AppIcons.homeSvg;
      case ResourceHubCategory.jobAndWork:
        return AppIcons.briefcaseSvg;
      case ResourceHubCategory.healthcare:
        return AppIcons.favSvg;
      case ResourceHubCategory.legalAdvice:
        return AppIcons.shield;
      case ResourceHubCategory.education:
        return AppIcons.closedBookSvg;
      case ResourceHubCategory.business:
        return AppIcons.store;
      case ResourceHubCategory.taxes:
        return AppIcons.newspaperSvg;
      case ResourceHubCategory.transport:
        return AppIcons.carSvg;
      case ResourceHubCategory.unknown:
        return AppIcons.resourceSvg;
    }
  }

  Color get iconColor {
    switch (this) {
      case ResourceHubCategory.immigration:
        return const Color(0xFF10B981);
      case ResourceHubCategory.housing:
        return const Color(0xFFF97316);
      case ResourceHubCategory.jobAndWork:
        return const Color(0xFF2563EB);
      case ResourceHubCategory.healthcare:
        return const Color(0xFFEF4444);
      case ResourceHubCategory.legalAdvice:
        return const Color(0xFF8B5CF6);
      case ResourceHubCategory.education:
        return const Color(0xFFF59E0B);
      case ResourceHubCategory.business:
        return const Color(0xFF059669);
      case ResourceHubCategory.taxes:
        return const Color(0xFFEA580C);
      case ResourceHubCategory.transport:
        return const Color(0xFF0284C7);
      case ResourceHubCategory.unknown:
        return const Color(0xFF64748B);
    }
  }

  Color get bgColor {
    switch (this) {
      case ResourceHubCategory.immigration:
        return const Color(0xFFECFDF5);
      case ResourceHubCategory.housing:
        return const Color(0xFFFFF7ED);
      case ResourceHubCategory.jobAndWork:
        return const Color(0xFFEFF6FF);
      case ResourceHubCategory.healthcare:
        return const Color(0xFFFFF1F2);
      case ResourceHubCategory.legalAdvice:
        return const Color(0xFFF5F3FF);
      case ResourceHubCategory.education:
        return const Color(0xFFFFFBEB);
      case ResourceHubCategory.business:
        return const Color(0xFFECFDF5);
      case ResourceHubCategory.taxes:
        return const Color(0xFFFFF7ED);
      case ResourceHubCategory.transport:
        return const Color(0xFFF0F7FF);
      case ResourceHubCategory.unknown:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get tagColor {
    switch (this) {
      case ResourceHubCategory.immigration:
        return const Color(0xFF059669);
      case ResourceHubCategory.housing:
        return const Color(0xFFEA580C);
      case ResourceHubCategory.jobAndWork:
        return const Color(0xFF2563EB);
      case ResourceHubCategory.healthcare:
        return const Color(0xFFE11D48);
      case ResourceHubCategory.legalAdvice:
        return const Color(0xFF7C3AED);
      case ResourceHubCategory.education:
        return const Color(0xFFD97706);
      case ResourceHubCategory.business:
        return const Color(0xFF059669);
      case ResourceHubCategory.taxes:
        return const Color(0xFFEA580C);
      case ResourceHubCategory.transport:
        return const Color(0xFF0284C7);
      case ResourceHubCategory.unknown:
        return const Color(0xFF475569);
    }
  }
}

class ResourceHubWriter {
  final String firstName;
  final String lastName;

  ResourceHubWriter({
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ResourceHubWriter.fromJson(Map<String, dynamic> json) =>
      ResourceHubWriter(
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
      };
}

class ResourceHubArticle {
  final String id;
  final ResourceHubCategory category;
  final String title;
  final String? content; // Markdown; only present in detail response
  final ResourceHubWriter? writer; // can be null
  final bool isSaved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? savedAt; // only present in saved list

  ResourceHubArticle({
    required this.id,
    required this.category,
    required this.title,
    this.content,
    this.writer,
    required this.isSaved,
    required this.createdAt,
    required this.updatedAt,
    this.savedAt,
  });

  String get authorName {
    final name = writer?.fullName;
    if (name != null && name.isNotEmpty) return name;
    return 'Desi Connect Team';
  }

  bool get isUpdated => updatedAt.isAfter(createdAt.add(const Duration(minutes: 1)));

  factory ResourceHubArticle.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val)?.toLocal() ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ResourceHubArticle(
      id: json['id'] as String? ?? '',
      category: ResourceHubCategory.fromValue(json['category'] as String?),
      title: (json['title'] as String? ?? '').trim(),
      content: json['content'] as String?,
      writer: json['writer'] == null
          ? null
          : ResourceHubWriter.fromJson(json['writer'] as Map<String, dynamic>),
      isSaved: json['isSaved'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      savedAt: json['savedAt'] == null
          ? null
          : DateTime.tryParse(json['savedAt'] as String)?.toLocal(),
    );
  }

  ResourceHubArticle copyWith({
    String? id,
    ResourceHubCategory? category,
    String? title,
    String? content,
    ResourceHubWriter? writer,
    bool? isSaved,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? savedAt,
  }) =>
      ResourceHubArticle(
        id: id ?? this.id,
        category: category ?? this.category,
        title: title ?? this.title,
        content: content ?? this.content,
        writer: writer ?? this.writer,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        savedAt: savedAt ?? this.savedAt,
      );
}

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 10,
        totalPages: json['totalPages'] as int? ?? 0,
      );

  factory PaginationMeta.empty() => PaginationMeta(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      );
}

class ResourceHubListResponse {
  final List<ResourceHubArticle> data;
  final PaginationMeta meta;

  ResourceHubListResponse({
    required this.data,
    required this.meta,
  });

  factory ResourceHubListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ResourceHubArticle.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] != null
        ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
        : PaginationMeta.empty();
    return ResourceHubListResponse(data: list, meta: meta);
  }
}
