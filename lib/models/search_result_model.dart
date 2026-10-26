/// Generic paginated search response wrapper.
class SearchMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  SearchMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SearchMeta.fromJson(Map<String, dynamic> json) {
    return SearchMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
}

/// A generic paginated response for search and list endpoints.
class PaginatedResponse<T> {
  final List<T> data;
  final SearchMeta meta;

  PaginatedResponse({required this.data, required this.meta});
}

/// Index health status details.
class IndexHealthInfo {
  final String index;
  final int docsCount;

  IndexHealthInfo({required this.index, required this.docsCount});

  factory IndexHealthInfo.fromJson(Map<String, dynamic> json) {
    return IndexHealthInfo(
      index: json['index'] as String? ?? '',
      docsCount: json['docsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'index': index, 'docsCount': docsCount};
}

/// Overall Elasticsearch search health check response.
class SearchHealthModel {
  final String status;
  final List<IndexHealthInfo> indices;

  SearchHealthModel({required this.status, required this.indices});

  factory SearchHealthModel.fromJson(Map<String, dynamic> json) {
    final rawIndices = json['indices'] as List? ?? [];
    final indicesList = rawIndices
        .map((e) => IndexHealthInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    return SearchHealthModel(
      status: json['status'] as String? ?? 'unknown',
      indices: indicesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'indices': indices.map((e) => e.toJson()).toList(),
  };
}
