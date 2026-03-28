import 'execution_status.dart';
import 'execution_result.dart';

class CronjobExecution {
  String id;
  String cronjobId;
  DateTime executedAt;
  ExecutionStatus status;
  int articlesGenerated;
  List<ExecutionResult> executionResults;
  String? errorMessage;
  DateTime? completedAt;

  CronjobExecution({
    required this.id,
    required this.cronjobId,
    required this.executedAt,
    required this.status,
    required this.articlesGenerated,
    required this.executionResults,
    this.errorMessage,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'cronjobId': cronjobId,
        'executedAt': executedAt.toIso8601String(),
        'status': status.toJson(),
        'articlesGenerated': articlesGenerated,
        'executionResults':
            executionResults.map((e) => e.toMap()).toList(),
        'errorMessage': errorMessage,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory CronjobExecution.fromMap(Map<String, dynamic> json) {
    return CronjobExecution(
      id: json['id'] as String,
      cronjobId: json['cronjobId'] as String,
      executedAt: DateTime.parse(json['executedAt'] as String),
      status: ExecutionStatusExtension.fromJson(json['status'] as String),
      articlesGenerated: json['articlesGenerated'] as int,
      executionResults: (json['executionResults'] as List)
          .map((e) => ExecutionResult.fromMap(e as Map<String, dynamic>))
          .toList(),
      errorMessage: json['errorMessage'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
