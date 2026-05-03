/// Represents a single content item from the project contents API.
class ContentItem {
  final String id;
  final String title;
  final String slug;
  final String? thumbnailUrl;
  final String completionStatus;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final List<String> targetKeywords;
  final String? topicName;
  final String? promptType;
  final String contentType;

  ContentItem({
    required this.id,
    required this.title,
    required this.slug,
    this.thumbnailUrl,
    required this.completionStatus,
    required this.createdAt,
    this.publishedAt,
    required this.targetKeywords,
    this.topicName,
    this.promptType,
    required this.contentType,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    // Parse thumbnail URL
    String? thumbUrl;
    final thumb = json['thumbnail'];
    if (thumb is Map) {
      thumbUrl = (thumb['url'] ?? '').toString();
      if (thumbUrl.isEmpty) thumbUrl = null;
    }

    // Parse target keywords
    final keywords = <String>[];
    final rawKw = json['targetKeywords'];
    if (rawKw is List) {
      for (final k in rawKw) {
        keywords.add(k.toString());
      }
    }

    // Parse topic name
    String? topicName;
    final topic = json['topic'];
    if (topic is Map) {
      topicName = (topic['name'] ?? '').toString();
      if (topicName.isEmpty) topicName = null;
    }

    // Parse prompt type
    String? promptType;
    final prompt = json['prompt'];
    if (prompt is Map) {
      promptType = (prompt['type'] ?? '').toString();
      if (promptType.isEmpty) promptType = null;
    }

    return ContentItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      thumbnailUrl: thumbUrl,
      completionStatus: (json['completionStatus'] ?? 'UNKNOWN').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      publishedAt: DateTime.tryParse((json['publishedAt'] ?? '').toString()),
      targetKeywords: keywords,
      topicName: topicName,
      promptType: promptType,
      contentType: (json['contentType'] ?? 'unknown').toString(),
    );
  }
}
