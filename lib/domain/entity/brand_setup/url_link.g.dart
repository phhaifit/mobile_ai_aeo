// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UrlLink _$UrlLinkFromJson(Map<String, dynamic> json) => UrlLink(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UrlLinkToJson(UrlLink instance) => <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
