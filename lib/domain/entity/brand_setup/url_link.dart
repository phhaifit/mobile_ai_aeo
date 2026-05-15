import 'package:json_annotation/json_annotation.dart';

part 'url_link.g.dart';

@JsonSerializable()
class UrlLink {
  final String id;
  final String projectId;
  final String url;
  final String? title;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UrlLink({
    required this.id,
    required this.projectId,
    required this.url,
    this.title,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UrlLink.fromJson(Map<String, dynamic> json) =>
      _$UrlLinkFromJson(json);

  Map<String, dynamic> toJson() => _$UrlLinkToJson(this);

  UrlLink copyWith({
    String? id,
    String? projectId,
    String? url,
    String? title,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UrlLink(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        url: url ?? this.url,
        title: title ?? this.title,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() => 'UrlLink(id: $id, projectId: $projectId, url: $url)';
}
