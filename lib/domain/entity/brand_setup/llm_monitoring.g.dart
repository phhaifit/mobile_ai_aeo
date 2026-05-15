// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_monitoring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmMonitoring _$LlmMonitoringFromJson(Map<String, dynamic> json) =>
    LlmMonitoring(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      llmId: json['llmId'] as String,
      llmName: json['llmName'] as String,
      isEnabled: json['isEnabled'] as bool,
      pollingFrequency: json['pollingFrequency'] as String?,
      lastPolledAt: json['lastPolledAt'] == null
          ? null
          : DateTime.parse(json['lastPolledAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LlmMonitoringToJson(LlmMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'llmId': instance.llmId,
      'llmName': instance.llmName,
      'isEnabled': instance.isEnabled,
      'pollingFrequency': instance.pollingFrequency,
      'lastPolledAt': instance.lastPolledAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
