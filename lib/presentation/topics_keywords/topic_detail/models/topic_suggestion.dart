enum SuggestionType {
  informational,
  commercial,
  transactional,
  navigational,
}

class TopicSuggestion {
  final String id;
  final String title;
  final DateTime createdAt;
  final String topicName;
  final List<String> keywords;
  final SuggestionType type;
  final bool isMonitored;
  final bool isExhausted;

  TopicSuggestion({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.topicName,
    required this.keywords,
    required this.type,
    this.isMonitored = true,
    this.isExhausted = false,
  });

  factory TopicSuggestion.fromJson(Map<String, dynamic> json) {
    return TopicSuggestion(
      id: (json['id'] ?? '').toString(),
      title: (json['content'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      topicName: (json['topicName'] ?? '').toString(),
      keywords:
          (json['keywords'] as List?)?.whereType<String>().toList() ?? [],
      type: _typeFromApi((json['type'] ?? '').toString()),
      isMonitored: json['isMonitored'] == true,
      isExhausted: json['isExhausted'] == true,
    );
  }

  static SuggestionType _typeFromApi(String value) {
    switch (value.trim().toLowerCase()) {
      case 'commercial':
        return SuggestionType.commercial;
      case 'transactional':
        return SuggestionType.transactional;
      case 'navigational':
        return SuggestionType.navigational;
      default:
        return SuggestionType.informational;
    }
  }

  TopicSuggestion copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? topicName,
    List<String>? keywords,
    SuggestionType? type,
    bool? isMonitored,
    bool? isExhausted,
  }) {
    return TopicSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      topicName: topicName ?? this.topicName,
      keywords: keywords ?? this.keywords,
      type: type ?? this.type,
      isMonitored: isMonitored ?? this.isMonitored,
      isExhausted: isExhausted ?? this.isExhausted,
    );
  }
}
