import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/domain/entity/content/content_item.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentApi _contentApi;

  ContentRepositoryImpl(this._contentApi);

  @override
  Future<List<Map<String, dynamic>>> listProjects() {
    return _contentApi.listProjects();
  }

  @override
  Future<List<ContentItem>> listProjectContents(String projectId) {
    return _contentApi.listProjectContents(projectId);
  }

  @override
  Future<ContentResult> startProcess(ContentRequest request) {
    return _contentApi.startProcess(request);
  }

  @override
  Future<ContentResult?> pollByJob(String jobId) {
    return _contentApi.pollByJob(jobId);
  }
}
