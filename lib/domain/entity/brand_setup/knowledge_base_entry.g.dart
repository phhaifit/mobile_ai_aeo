// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_base_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KnowledgeBaseEntry _$KnowledgeBaseEntryFromJson(Map<String, dynamic> json) =>
    KnowledgeBaseEntry(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPublished: json['isPublished'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$KnowledgeBaseEntryToJson(KnowledgeBaseEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'tags': instance.tags,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
