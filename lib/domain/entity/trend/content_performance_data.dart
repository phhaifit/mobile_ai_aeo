import 'content_item.dart';

/// Paginated wrapper for the project contents API response.
class ContentPerformanceData {
  final List<ContentItem> items;
  final int total;
  final int page;
  final int totalPages;

  ContentPerformanceData({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ContentPerformanceData.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>?) ?? [];
    final items = rawData
        .map((e) => ContentItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ContentPerformanceData(
      items: items,
      total: (json['total'] as int?) ?? 0,
      page: (json['page'] as int?) ?? 1,
      totalPages: (json['totalPages'] as int?) ?? 1,
    );
  }
}
