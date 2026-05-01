/// One row from `GET /api/projects/:projectId/contents`.
///
/// Lightweight projection used by the Content Enhancement picker — only the
/// fields the picker needs to render + identify the row for the regenerate
/// flow. Full BE payload has many more fields; we map them lazily.
class ContentItem {
  final String id;
  final String projectId;
  final String title;
  final String body;
  final String contentType;
  final String status;
  final String topicName;
  final DateTime? createdAt;

  ContentItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.body,
    required this.contentType,
    required this.status,
    required this.topicName,
    this.createdAt,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map, String projectId) {
    final topic = map['topic'];
    final topicName = topic is Map<String, dynamic>
        ? (topic['name']?.toString() ?? '')
        : '';
    return ContentItem(
      id: map['id']?.toString() ?? '',
      projectId: projectId,
      title: (map['title'] as String?)?.trim().isNotEmpty == true
          ? map['title'] as String
          : 'Untitled draft',
      body: map['body'] as String? ?? '',
      contentType: (map['contentType'] as String? ?? 'BLOG_POST')
          .replaceAll('_', ' '),
      status: map['completionStatus'] as String? ??
          map['status'] as String? ??
          'DRAFT',
      topicName: topicName,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  /// True only when the row can be regenerated/enhanced via the BE flow.
  /// Backend rejects regenerate if the content has no associated prompt
  /// (e.g. manually created drafts) and we do not enhance content that is
  /// still in flight from the original generation.
  bool get isEnhanceable => status != 'DRAFTING' && status != 'FAILED';

  /// Short preview snippet (first ~140 chars without markdown noise).
  String get bodyPreview {
    final stripped = body
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]\([^\)]*\)'), '')
        .replaceAll(RegExp(r'[#*_`>~-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (stripped.length <= 140) return stripped;
    return '${stripped.substring(0, 140)}…';
  }
}
