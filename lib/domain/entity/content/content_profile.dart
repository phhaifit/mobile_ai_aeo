import 'package:json_annotation/json_annotation.dart';

part 'content_profile.g.dart';

@JsonSerializable()
class ContentProfile {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final String voiceAndTone;
  final String audience;
  final ContentProfileProject? project;

  ContentProfile({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.voiceAndTone,
    required this.audience,
    this.project,
  });

  factory ContentProfile.fromJson(Map<String, dynamic> json) =>
      _$ContentProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ContentProfileToJson(this);

  @override
  String toString() =>
      'ContentProfile(id: $id, name: $name, projectId: $projectId)';
}

@JsonSerializable()
class ContentProfileProject {
  final String createdBy;

  ContentProfileProject({required this.createdBy});

  factory ContentProfileProject.fromJson(Map<String, dynamic> json) =>
      _$ContentProfileProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ContentProfileProjectToJson(this);
}
