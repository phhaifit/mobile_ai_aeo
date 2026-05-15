// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_rewrite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UrlRewrite _$UrlRewriteFromJson(Map<String, dynamic> json) => UrlRewrite(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      sourceUrl: json['sourceUrl'] as String,
      targetUrl: json['targetUrl'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UrlRewriteToJson(UrlRewrite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'sourceUrl': instance.sourceUrl,
      'targetUrl': instance.targetUrl,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
