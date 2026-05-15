import 'package:json_annotation/json_annotation.dart';

part 'llm_polling_frequency.g.dart';

@JsonSerializable()
class LlmPollingFrequency {
  final String id;
  final String projectId;
  final String frequency; // e.g., "hourly", "daily", "weekly"
  final int intervalMinutes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LlmPollingFrequency({
    required this.id,
    required this.projectId,
    required this.frequency,
    required this.intervalMinutes,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory LlmPollingFrequency.fromJson(Map<String, dynamic> json) =>
      _$LlmPollingFrequencyFromJson(json);

  Map<String, dynamic> toJson() => _$LlmPollingFrequencyToJson(this);

  LlmPollingFrequency copyWith({
    String? id,
    String? projectId,
    String? frequency,
    int? intervalMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      LlmPollingFrequency(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        frequency: frequency ?? this.frequency,
        intervalMinutes: intervalMinutes ?? this.intervalMinutes,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  String toString() =>
      'LlmPollingFrequency(id: $id, projectId: $projectId, frequency: $frequency)';
}
