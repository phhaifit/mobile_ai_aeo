import 'package:json_annotation/json_annotation.dart';

part 'url_rewrite.g.dart';

@JsonSerializable()
class UrlRewrite {
  final String id;
  final String projectId;
  final String sourceUrl;
  final String targetUrl;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UrlRewrite({
    required this.id,
    required this.projectId,
    required this.sourceUrl,
    required this.targetUrl,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UrlRewrite.fromJson(Map<String, dynamic> json) =>
      _$UrlRewriteFromJson(json);

  Map<String, dynamic> toJson() => _$UrlRewriteToJson(this);

  UrlRewrite copyWith({
    String? id,
    String? projectId,
    String? sourceUrl,
    String? targetUrl,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UrlRewrite(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        sourceUrl: sourceUrl ?? this.sourceUrl,
        targetUrl: targetUrl ?? this.targetUrl,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'UrlRewrite(id: $id, projectId: $projectId, source: $sourceUrl)';
}
