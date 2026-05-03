// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentProfile _$ContentProfileFromJson(Map<String, dynamic> json) =>
    ContentProfile(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      voiceAndTone: json['voiceAndTone'] as String,
      audience: json['audience'] as String,
      project: json['project'] == null
          ? null
          : ContentProfileProject.fromJson(
              json['project'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentProfileToJson(ContentProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'name': instance.name,
      'description': instance.description,
      'voiceAndTone': instance.voiceAndTone,
      'audience': instance.audience,
      'project': instance.project,
    };

ContentProfileProject _$ContentProfileProjectFromJson(
        Map<String, dynamic> json) =>
    ContentProfileProject(
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$ContentProfileProjectToJson(
        ContentProfileProject instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
    };
