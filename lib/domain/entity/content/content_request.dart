import 'package:boilerplate/domain/entity/content/content_operation.dart';

class ContentRequest {
  final String text;
  final ContentOperation operation;
  final Map<String, dynamic>? options;

  ContentRequest({
    required this.text,
    required this.operation,
    this.options,
  });

  /// BE expects only `text` (and optional tone/length flattened, not nested).
  /// Operation is in the URL path, not the body.
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      if (options != null) ...options!,
    };
  }
}
