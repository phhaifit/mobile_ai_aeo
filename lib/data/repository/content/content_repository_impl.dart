import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentApi _contentApi;

  ContentRepositoryImpl(this._contentApi);

  @override
  Future<ContentResult> processContent(ContentRequest request) {
    return _contentApi.processContent(request);
  }
}
