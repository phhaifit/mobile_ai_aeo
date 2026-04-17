// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_generation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RetrievedPage _$RetrievedPageFromJson(Map<String, dynamic> json) =>
    RetrievedPage(
      url: json['url'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$RetrievedPageToJson(RetrievedPage instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
    };

ContentGenerationResult _$ContentGenerationResultFromJson(
        Map<String, dynamic> json) =>
    ContentGenerationResult(
      id: json['id'] as String,
      topicId: json['topicId'] as String?,
      profileId: json['profileId'] as String?,
      promptId: json['promptId'] as String?,
      targetKeywords: (json['targetKeywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      retrievedPages: (json['retrievedPages'] as List<dynamic>)
          .map((e) => RetrievedPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      contentInsight: json['contentInsight'] as List<dynamic>? ?? [],
      completionStatus: json['completionStatus'] as String,
      contentType: json['contentType'] as String,
      contentFormat: json['contentFormat'] as String?,
      body: json['body'] as String,
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$ContentGenerationResultToJson(
        ContentGenerationResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'profileId': instance.profileId,
      'promptId': instance.promptId,
      'targetKeywords': instance.targetKeywords,
      'retrievedPages': instance.retrievedPages.map((e) => e.toJson()).toList(),
      'contentInsight': instance.contentInsight,
      'completionStatus': instance.completionStatus,
      'contentType': instance.contentType,
      'contentFormat': instance.contentFormat,
      'body': instance.body,
      'title': instance.title,
      'slug': instance.slug,
      'createdAt': instance.createdAt,
    };
