import 'package:boilerplate/domain/entity/content/content_operation.dart';

/// Result of an enhancement operation.
///
/// Because the BE delegates to the N8N regenerate flow (async), the initial
/// API call returns only `jobId` + `operation`. The full result text is
/// fetched later by polling `/api/contents/by-job/{jobId}` once the worker
/// finishes — at that point `resultText` is populated.
class ContentResult {
  final String jobId;
  final ContentOperation operation;
  final String resultText;
  final int? tokensUsed;
  final DateTime processedAt;

  ContentResult({
    required this.jobId,
    required this.operation,
    this.resultText = '',
    this.tokensUsed,
    required this.processedAt,
  });

  /// Parses the synchronous job-creation response: `{ jobId }`.
  factory ContentResult.jobCreated({
    required String jobId,
    required ContentOperation operation,
  }) {
    return ContentResult(
      jobId: jobId,
      operation: operation,
      processedAt: DateTime.now(),
    );
  }

  /// Parses the by-job poll response (BE returns the full content row).
  factory ContentResult.fromMap(Map<String, dynamic> map) {
    final operationStr = map['operation'] as String? ?? 'enhance';
    final operation = ContentOperation.values.firstWhere(
      (o) => o.apiPath == operationStr,
      orElse: () => ContentOperation.enhance,
    );
    return ContentResult(
      jobId: map['jobId'] as String? ?? map['job_id'] as String? ?? '',
      operation: operation,
      resultText: map['body'] as String? ??
          map['result_text'] as String? ??
          map['resultText'] as String? ??
          map['result'] as String? ??
          '',
      tokensUsed: map['tokens_used'] as int?,
      processedAt: map['processed_at'] != null
          ? DateTime.parse(map['processed_at'] as String)
          : (map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'] as String)
              : DateTime.now()),
    );
  }

  ContentResult copyWith({
    String? jobId,
    ContentOperation? operation,
    String? resultText,
    int? tokensUsed,
    DateTime? processedAt,
  }) {
    return ContentResult(
      jobId: jobId ?? this.jobId,
      operation: operation ?? this.operation,
      resultText: resultText ?? this.resultText,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
