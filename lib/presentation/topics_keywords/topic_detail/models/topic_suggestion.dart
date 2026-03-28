enum SuggestionType {
  informational,
  commercial,
  transactional,
  navigational,
}

class TopicSuggestion {
  String id;
  String title;
  DateTime createdAt;
  List<String> tags;
  SuggestionType type;

  TopicSuggestion({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.tags,
    required this.type,
  });

  TopicSuggestion copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<String>? tags,
    SuggestionType? type,
  }) {
    return TopicSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }
}
