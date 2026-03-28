import 'package:boilerplate/domain/entity/content/content_operation.dart';

class ContentResult {
  final String resultText;
  final ContentOperation operation;
  final int? tokensUsed;
  final DateTime processedAt;

  ContentResult({
    required this.resultText,
    required this.operation,
    this.tokensUsed,
    required this.processedAt,
  });

  factory ContentResult.fromMap(Map<String, dynamic> map) {
    final operationStr = map['operation'] as String? ?? 'enhance';
    final operation = ContentOperation.values.firstWhere(
      (o) => o.apiPath == operationStr,
      orElse: () => ContentOperation.enhance,
    );
    return ContentResult(
      resultText: map['result_text'] as String? ?? map['resultText'] as String? ?? map['result'] as String? ?? '',
      operation: operation,
      tokensUsed: map['tokens_used'] as int?,
      processedAt: map['processed_at'] != null
          ? DateTime.parse(map['processed_at'] as String)
          : DateTime.now(),
    );
  }
}
