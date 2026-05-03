import 'dart:convert';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/domain/entity/prompt/prompt_summary.dart';
import 'package:dio/dio.dart';

class PromptApi {
  final DioClient _dioClient;

  PromptApi(this._dioClient);

  /// Matches BE list shape:
  /// `{ "data": [ { "id", "content", "topicName", ... } ], "total", "page", "limit", "totalPages" }`.
  /// Only `data[]` is mapped to [PromptSummary]; metadata fields are ignored.

  /// GET /api/prompts/by-project?projectId=
  Future<List<PromptSummary>> getPromptsByProject(String projectId) async {
    try {
      final endpoint = Endpoints.promptsByProject;
      final query = {'projectId': projectId};
      final requestUri = _resolveGetUrl(
        baseUrl: _dioClient.dio.options.baseUrl,
        path: endpoint,
        queryParameters: query,
      );
      print('PromptApi.getPromptsByProject FE→BE: GET $requestUri');

      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: query,
      );

      print(
        'PromptApi.getPromptsByProject Dio actual URL: '
        '${response.requestOptions.uri}',
      );

      final data = _decodeResponseBody(response.data);
      try {
        final payload = data is Map || data is List
            ? const JsonEncoder.withIndent('  ').convert(data)
            : data.toString();
        print(
          'PromptApi.getPromptsByProject response '
          '[${response.statusCode}]: $payload',
        );
      } catch (_) {
        print(
          'PromptApi.getPromptsByProject response '
          '[${response.statusCode}]: $data',
        );
      }

      final rawList = _extractPromptRows(data);

      final out = <PromptSummary>[];
      for (final item in rawList) {
        if (item is! Map) continue;
        final row = Map<String, dynamic>.from(item);
        final p = PromptSummary.fromJson(row);
        if (p.id.isNotEmpty) {
          out.add(p);
        }
      }
      print(
        'PromptApi.getPromptsByProject parsed ${out.length} prompt(s) '
        'from ${rawList.length} raw row(s)',
      );
      return out;
    } catch (e) {
      print('PromptApi.getPromptsByProject error: ${e.toString()}');
      rethrow;
    }
  }

  /// POST /api/prompts/{id}/content-generations
  Future<ContentGenerationResult> createContentGeneration({
    required String promptId,
    required String projectId,
    required String contentType,
    required String contentProfileId,
    required List<String> keywords,
    required String referencePageUrl,
    required String platform,
    required String improvement,
    required String referenceType,
    String? customerPersonaId,
  }) async {
    try {
      final endpoint = Endpoints.promptContentGenerations(promptId);
      final body = <String, dynamic>{
        'projectId': projectId,
        'contentType': contentType,
        'contentProfileId': contentProfileId,
        'keywords': keywords,
        'referencePageUrl': referencePageUrl,
        'platform': platform,
        'improvement': improvement,
        'referenceType': referenceType,
      };
      if (customerPersonaId != null && customerPersonaId.isNotEmpty) {
        body['customerPersonaId'] = customerPersonaId;
      }

      print('PromptApi.createContentGeneration calling: $endpoint');

      final response = await _dioClient.dio.post(
        endpoint,
        data: body,
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      return ContentGenerationResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      print('PromptApi.createContentGeneration error: ${e.toString()}');
      rethrow;
    }
  }
}

/// Dio usually returns decoded JSON; some transformers may leave a JSON [String].
dynamic _decodeResponseBody(dynamic raw) {
  if (raw is String) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }
  return raw;
}

/// Extracts the prompt row list without unsafe `as List` casts.
List<dynamic> _extractPromptRows(dynamic data) {
  if (data is List) {
    return data;
  }
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['data', 'items', 'prompts']) {
      final v = map[key];
      if (v is List) {
        return v;
      }
    }
  }
  return [];
}

/// Builds the same absolute URL Dio uses for GET (baseUrl + path + query).
Uri _resolveGetUrl({
  required String baseUrl,
  required String path,
  required Map<String, String> queryParameters,
}) {
  final base = Uri.parse(baseUrl);
  final relative = path.startsWith('/') ? path : '/$path';
  final resolved = base.resolve(relative);
  return resolved.replace(
    queryParameters: {
      ...resolved.queryParameters,
      ...queryParameters,
    },
  );
}
