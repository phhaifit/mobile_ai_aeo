/// Domain entity mapping `ContentInsightResponseDto` from the backend.
/// Used by On-page SEO Checker and Content Structure tabs.
class ContentInsight {
  final String id;
  final String type; // e.g. "intent", "topic_coverage", "objective", etc.
  final String title;
  final String description;
  final String status; // "pass" | "warning" | "fail"
  final double? score; // 0.0 – 100.0
  final String? recommendation;

  ContentInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.score,
    this.recommendation,
  });

  factory ContentInsight.fromMap(Map<String, dynamic> map) {
    return ContentInsight(
      id: (map['id'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: (map['status'] ?? 'warning').toString(),
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
      recommendation: map['recommendation']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'status': status,
        'score': score,
        'recommendation': recommendation,
      };
}
