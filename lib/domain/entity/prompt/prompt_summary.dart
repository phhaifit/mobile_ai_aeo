/// Prompt item returned from GET /api/prompts/by-project
class PromptSummary {
  final String id;
  final String label;

  PromptSummary({
    required this.id,
    required this.label,
  });

  /// GET /api/prompts/by-project returns paginated `{ data: [...] }` items with
  /// `id`, `content`, `topicName`, `type`, etc.
  factory PromptSummary.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final contentRaw = json['content'];
    final content =
        contentRaw is String ? contentRaw : contentRaw?.toString();
    final name = json['name']?.toString();
    final title = json['title']?.toString();
    final text = json['text']?.toString();
    final topicName = json['topicName']?.toString();
    final raw =
        (content ?? name ?? title ?? text ?? topicName ?? 'Prompt').trim();
    return PromptSummary(
      id: id,
      label: raw.isEmpty ? 'Prompt' : raw,
    );
  }
}
