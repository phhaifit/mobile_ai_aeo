/// Cluster plan entity returned from `POST /api/projects/:projectId/cluster/generate-plan`.
class ClusterPlan {
  final String pillarTopic;
  final String pillarOutline;
  final List<String> satelliteTopics;
  final List<String> keywords;

  ClusterPlan({
    required this.pillarTopic,
    required this.pillarOutline,
    required this.satelliteTopics,
    required this.keywords,
  });

  factory ClusterPlan.fromMap(Map<String, dynamic> map) {
    return ClusterPlan(
      pillarTopic: (map['pillarTopic'] ?? map['pillar_topic'] ?? '').toString(),
      pillarOutline:
          (map['pillarOutline'] ?? map['pillar_outline'] ?? '').toString(),
      satelliteTopics: (map['satelliteTopics'] ?? map['satellite_topics'] ?? [])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toList(),
      keywords: (map['keywords'] ?? [])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'pillarTopic': pillarTopic,
        'pillarOutline': pillarOutline,
        'satelliteTopics': satelliteTopics,
        'keywords': keywords,
      };
}
