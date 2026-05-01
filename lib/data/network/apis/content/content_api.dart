import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/content/content_item.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';

class ContentApi {
  final DioClient _dioClient;

  ContentApi(this._dioClient);

  /// Fetch the user's projects (used to discover the default projectId for
  /// the Content Enhancement picker — the BE response is a list of project
  /// objects, optionally wrapped in `{data: [...]}`.
  Future<List<Map<String, dynamic>>> listProjects() async {
    final response = await _dioClient.dio.get('/api/projects');
    return _extractList(response.data);
  }

  /// Fetch all contents for a project (the picker source). Returns
  /// items already mapped to the lightweight [ContentItem] projection.
  Future<List<ContentItem>> listProjectContents(String projectId) async {
    final response =
        await _dioClient.dio.get(Endpoints.projectContents(projectId));
    final raw = _extractList(response.data);
    return raw.map((e) => ContentItem.fromMap(e, projectId)).toList();
  }

  List<Map<String, dynamic>> _extractList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body['items'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      // Some endpoints wrap pagination as { data: { items: [...] } }
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items.whereType<Map<String, dynamic>>().toList();
        }
      }
    }
    return const [];
  }

  /// Kick off an enhancement operation on an existing content row.
  ///
  /// Returns immediately with the job acknowledgement
  /// (`ContentResult.jobCreated`). Caller must poll [pollByJob] (or, in a
  /// future iteration, subscribe to the SSE stream) to fetch the regenerated
  /// body once the underlying N8N flow completes.
  Future<ContentResult> startProcess(ContentRequest request) async {
    final endpoint = Endpoints.contentOperation(
      request.contentId,
      request.operation.apiPath,
    );
    final response = await _dioClient.dio.post(
      endpoint,
      data: request.toMap(),
    );
    final body = response.data as Map<String, dynamic>;
    final jobId =
        (body['jobId'] ?? body['job_id'] ?? '').toString();
    return ContentResult.jobCreated(
      jobId: jobId,
      operation: request.operation,
    );
  }

  /// Polls the by-job endpoint. Returns null when the job is still running
  /// (BE responds with 200 + empty / null payload), a populated result once
  /// the regenerate flow finishes.
  Future<ContentResult?> pollByJob(String jobId) async {
    final response = await _dioClient.dio.get(Endpoints.contentByJob(jobId));
    final data = response.data;
    if (data == null) return null;
    if (data is String && data.trim().isEmpty) return null;
    if (data is Map<String, dynamic>) {
      if (data.isEmpty) return null;
      return ContentResult.fromMap(data);
    }
    return null;
  }
}
