import 'package:json_annotation/json_annotation.dart';

part 'knowledge_base_entry.g.dart';

@JsonSerializable()
class KnowledgeBaseEntry {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final String? category;
  final List<String>? tags;
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KnowledgeBaseEntry({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    this.category,
    this.tags,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  factory KnowledgeBaseEntry.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseEntryFromJson(json);

  Map<String, dynamic> toJson() => _$KnowledgeBaseEntryToJson(this);

  KnowledgeBaseEntry copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      KnowledgeBaseEntry(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        content: content ?? this.content,
        category: category ?? this.category,
        tags: tags ?? this.tags,
        isPublished: isPublished ?? this.isPublished,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'KnowledgeBaseEntry(id: $id, projectId: $projectId, title: $title)';
}
