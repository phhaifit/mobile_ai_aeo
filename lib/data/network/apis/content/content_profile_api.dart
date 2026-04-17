import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';

class ContentProfileApi {
  final DioClient _dioClient;

  ContentProfileApi(this._dioClient);

  /// Fetch all content profiles for a project
  /// GET /api/projects/{projectId}/content-profiles
  Future<List<ContentProfile>> getContentProfiles(String projectId) async {
    try {
      final endpoint = Endpoints.getContentProfiles(projectId);
      
      final baseUrl = _dioClient.dio.options.baseUrl;
      final fullUrl = '$baseUrl$endpoint';
      
      print('ContentProfileApi.getContentProfiles calling: $fullUrl');
      
      final response = await _dioClient.dio.get(endpoint);
      
      print('ContentProfileApi.getContentProfiles success: $fullUrl');
      
      final List<dynamic> jsonList = response.data is List ? response.data : [];
      return jsonList
          .map((json) => ContentProfile.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('ContentProfileApi.getContentProfiles error: ${e.toString()}');
      rethrow;
    }
  }

  /// Create a new content profile
  /// POST /api/projects/{projectId}/content-profiles
  Future<ContentProfile> createContentProfile({
    required String projectId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    try {
      final endpoint = Endpoints.getContentProfiles(projectId);
      
      final body = {
        'name': name,
        'description': description,
        'voiceAndTone': voiceAndTone,
        'audience': audience,
      };
      
      print('ContentProfileApi.createContentProfile calling: $endpoint with body: $body');
      
      final response = await _dioClient.dio.post(
        endpoint,
        data: body,
      );
      
      print('ContentProfileApi.createContentProfile success');
      
      return ContentProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('ContentProfileApi.createContentProfile error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update an existing content profile
  /// PATCH /api/projects/{projectId}/content-profiles/{contentProfileId}
  Future<ContentProfile> updateContentProfile({
    required String projectId,
    required String contentProfileId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    try {
      final endpoint = 
          '${Endpoints.getContentProfiles(projectId)}/$contentProfileId';
      
      final body = {
        'name': name,
        'description': description,
        'voiceAndTone': voiceAndTone,
        'audience': audience,
      };
      
      print('ContentProfileApi.updateContentProfile calling: $endpoint with body: $body');
      
      final response = await _dioClient.dio.patch(
        endpoint,
        data: body,
      );
      
      print('ContentProfileApi.updateContentProfile success');
      
      return ContentProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('ContentProfileApi.updateContentProfile error: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete a content profile
  /// DELETE /api/projects/{projectId}/content-profiles/{contentProfileId}
  Future<void> deleteContentProfile({
    required String projectId,
    required String contentProfileId,
  }) async {
    try {
      final endpoint = 
          '${Endpoints.getContentProfiles(projectId)}/$contentProfileId';
      
      print('ContentProfileApi.deleteContentProfile calling: $endpoint');
      
      await _dioClient.dio.delete(endpoint);
      
      print('ContentProfileApi.deleteContentProfile success');
    } catch (e) {
      print('ContentProfileApi.deleteContentProfile error: ${e.toString()}');
      rethrow;
    }
  }
}
