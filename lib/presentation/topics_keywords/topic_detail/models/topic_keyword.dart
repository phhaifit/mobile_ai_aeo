class TopicKeyword {
  final String id;
  final String text;

  TopicKeyword({
    required this.id,
    required this.text,
  });

  factory TopicKeyword.fromJson(Map<String, dynamic> json) {
    return TopicKeyword(
      id: json['id'] as String? ?? '',
      text: json['keyword'] as String? ?? '',
    );
  }
}
