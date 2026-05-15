import 'package:json_annotation/json_annotation.dart';

part 'llm_monitoring.g.dart';

@JsonSerializable()
class LlmMonitoring {
  final String id;
  final String projectId;
  final String llmId;
  final String llmName;
  final bool isEnabled;
  final String? pollingFrequency;
  final DateTime? lastPolledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LlmMonitoring({
    required this.id,
    required this.projectId,
    required this.llmId,
    required this.llmName,
    required this.isEnabled,
    this.pollingFrequency,
    this.lastPolledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory LlmMonitoring.fromJson(Map<String, dynamic> json) =>
      _$LlmMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$LlmMonitoringToJson(this);

  LlmMonitoring copyWith({
    String? id,
    String? projectId,
    String? llmId,
    String? llmName,
    bool? isEnabled,
    String? pollingFrequency,
    DateTime? lastPolledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      LlmMonitoring(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        llmId: llmId ?? this.llmId,
        llmName: llmName ?? this.llmName,
        isEnabled: isEnabled ?? this.isEnabled,
        pollingFrequency: pollingFrequency ?? this.pollingFrequency,
        lastPolledAt: lastPolledAt ?? this.lastPolledAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'LlmMonitoring(id: $id, projectId: $projectId, llmName: $llmName)';
}
