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

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'operation': operation.apiPath,
      if (options != null) 'options': options,
    };
  }
}
