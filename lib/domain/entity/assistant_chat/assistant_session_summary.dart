import 'package:meta/meta.dart';

/// Local index row for recent Mongo-backed assistant sessions (no list API).
@immutable
class AssistantSessionSummary {
  final String id;
  final String title;
  final int updatedAtMs;

  const AssistantSessionSummary({
    required this.id,
    required this.title,
    required this.updatedAtMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAtMs': updatedAtMs,
      };

  factory AssistantSessionSummary.fromJson(Map<String, dynamic> json) {
    return AssistantSessionSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }
}
