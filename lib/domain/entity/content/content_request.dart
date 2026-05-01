import 'package:boilerplate/domain/entity/content/content_operation.dart';

/// Request to enhance an existing draft content.
///
/// The 4 enhancement endpoints reuse the existing N8N regenerate flow on
/// the BE side, so they require an existing content row (`contentId`).
/// The operation lives in the URL path; the body only carries optional
/// hints (tone for enhance/rewrite/humanize, length for summarize).
class ContentRequest {
  final String contentId;
  final ContentOperation operation;
  final Map<String, dynamic>? options;

  ContentRequest({
    required this.contentId,
    required this.operation,
    this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      if (options != null) ...options!,
    };
  }
}
