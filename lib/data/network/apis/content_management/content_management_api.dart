import 'dart:async';
import 'dart:convert';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ContentManagementApi {
  final DioClient _dioClient;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  ContentManagementApi(this._dioClient, this._sharedPreferenceHelper);

  Future<List<dynamic>> getProjects() async {
    final response = await _dioClient.dio.get('/api/projects');
    final dynamic data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    if (data is List) return List<dynamic>.from(data);
    return const [];
  }

  Future<List<dynamic>> getPrompts(String projectId) async {
    final response =
        await _dioClient.dio.get('/api/projects/$projectId/prompts');
    final dynamic data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    if (data is List) return List<dynamic>.from(data);
    return const [];
  }

  Future<List<dynamic>> getProfiles(String projectId) async {
    final response =
        await _dioClient.dio.get('/api/projects/$projectId/content-profiles');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createProfile(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio
        .post('/api/projects/$projectId/content-profiles', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updateProfile(
    String projectId,
    String profileId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.patch(
      '/api/projects/$projectId/content-profiles/$profileId',
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<void> getProfileDetail(String projectId, String profileId) async {
    await _dioClient.dio
        .get('/api/projects/$projectId/content-profiles/$profileId');
  }

  Future<void> deleteProfile(String projectId, String profileId) async {
    await _dioClient.dio
        .delete('/api/projects/$projectId/content-profiles/$profileId');
  }

  Future<List<dynamic>> getPersonas(String brandId) async {
    final response =
        await _dioClient.dio.get('/api/brands/$brandId/customer-personas');
    return _asList(response.data);
  }

  Future<Map<String, dynamic>> createPersona(
    String brandId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio
        .post('/api/brands/$brandId/customer-personas', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> updatePersona(
    String brandId,
    String personaId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.patch(
      '/api/brands/$brandId/customer-personas/$personaId',
      data: payload,
    );
    return _asMap(response.data);
  }

  Future<List<dynamic>> generatePersonas(String brandId) async {
    final response = await _dioClient.dio
        .post('/api/brands/$brandId/customer-personas/generate');
    return _asList(response.data);
  }

  Future<void> getPersonaDetail(String brandId, String personaId) async {
    await _dioClient.dio
        .get('/api/brands/$brandId/customer-personas/$personaId');
  }

  Future<void> deletePersona(String brandId, String personaId) async {
    await _dioClient.dio
        .delete('/api/brands/$brandId/customer-personas/$personaId');
  }

  Future<List<dynamic>> getTopPages(String promptId) async {
    final response =
        await _dioClient.dio.get('/api/prompts/$promptId/top-pages');
    return _asList(response.data);
  }

  Future<void> validateReference(
    String promptId,
    Map<String, dynamic> payload,
  ) async {
    await _dioClient.dio
        .post('/api/prompts/$promptId/validate-reference', data: payload);
  }

  Future<Map<String, dynamic>> generateContent(
    String promptId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio
        .post('/api/prompts/$promptId/generations', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> getContentDetail(String id) async {
    final response = await _dioClient.dio.get('/api/contents/$id');
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> listProjectContents(
    String projectId, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _dioClient.dio.get(
      '/api/projects/$projectId/contents',
      queryParameters: queryParameters,
    );
    return _asMap(response.data);
  }

  Future<void> deleteManyContents(List<String> ids) async {
    await _dioClient.dio
        .delete('/api/contents/delete-many', data: {'ids': ids});
  }

  Future<void> changeContentStatus(String id, String endpoint) async {
    await _dioClient.dio.post('/api/contents/$id/$endpoint');
  }

  Future<Map<String, dynamic>> regenerateContent(String id) async {
    final response = await _dioClient.dio.post('/api/contents/$id/regenerate');
    return _asMap(response.data);
  }

  Future<void> updateContent(String id, Map<String, dynamic> payload) async {
    await _dioClient.dio.patch('/api/contents/$id', data: payload);
  }

  Future<StreamSubscription<String>> listenToJobStream({
    required String jobId,
    required void Function(String line) onLine,
    void Function(Object error)? onError,
    void Function()? onDone,
  }) async {
    final token = (await _sharedPreferenceHelper.authToken ?? '').trim();
    final normalizedToken =
        token.startsWith('Bearer ') ? token.substring(7).trim() : token;

    final base = _dioClient.dio.options.baseUrl;
    final uri = Uri.parse('$base/api/contents/jobs/$jobId/stream');
    final request = http.Request('GET', uri);
    if (normalizedToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $normalizedToken';
    }

    final client = http.Client();
    final response = await client.send(request);
    return response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      onLine,
      onError: (Object err) {
        onError?.call(err);
      },
      onDone: () {
        client.close();
        onDone?.call();
      },
      cancelOnError: false,
    );
  }

  Map<String, dynamic> decodeEvent(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Unexpected SSE event format');
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List) return List<dynamic>.from(data);
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<dynamic>.from(data['data'] as List);
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    throw DioException(
      requestOptions: RequestOptions(path: ''),
      error: 'Unexpected response format',
    );
  }
}
