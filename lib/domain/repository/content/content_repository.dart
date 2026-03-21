import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';

abstract class ContentRepository {
  Future<ContentResult> processContent(ContentRequest request);
}
