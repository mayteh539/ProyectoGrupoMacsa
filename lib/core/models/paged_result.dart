class PagedResult<T> {
  const PagedResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : <String, dynamic>{};
    final list = json['data'] is List ? json['data'] as List : const [];

    return PagedResult<T>(
      data: list
          .whereType<Map>()
          .map((item) => mapper(Map<String, dynamic>.from(item)))
          .toList(),
      page: _toInt(meta['page'], 1),
      limit: _toInt(meta['limit'], 20),
      total: _toInt(meta['total'], list.length),
      totalPages: _toInt(meta['totalPages'], 1),
    );
  }

  static int _toInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
