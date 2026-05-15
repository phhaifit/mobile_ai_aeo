// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_polling_frequency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmPollingFrequency _$LlmPollingFrequencyFromJson(Map<String, dynamic> json) =>
    LlmPollingFrequency(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      frequency: json['frequency'] as String,
      intervalMinutes: (json['intervalMinutes'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LlmPollingFrequencyToJson(
        LlmPollingFrequency instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'frequency': instance.frequency,
      'intervalMinutes': instance.intervalMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
