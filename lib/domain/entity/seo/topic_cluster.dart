class TopicCluster {
  final String? id;
  final String pillarTopic;
  final List<String> subtopics;
  final String? pillarOutline;
  final List<String> keywords;

  TopicCluster({
    this.id,
    required this.pillarTopic,
    required this.subtopics,
    this.pillarOutline,
    this.keywords = const [],
  });

  factory TopicCluster.fromMap(Map<String, dynamic> map) {
    return TopicCluster(
      id: map['id']?.toString(),
      pillarTopic:
          (map['pillarTopic'] ?? map['pillar_topic'] ?? '').toString(),
      subtopics: (map['satelliteTopics'] ?? map['satellite_topics'] ?? map['subtopics'] ?? [])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toList(),
      pillarOutline: (map['pillarOutline'] ?? map['pillar_outline'])?.toString(),
      keywords: (map['keywords'] ?? [])
          .whereType<dynamic>()
          .map((e) => e.toString())
          .toList(),
    );
  }
}

