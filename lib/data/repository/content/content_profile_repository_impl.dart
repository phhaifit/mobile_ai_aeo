import 'package:boilerplate/data/network/apis/content/content_profile_api.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/repository/content/content_profile_repository.dart';

class ContentProfileRepositoryImpl implements ContentProfileRepository {
  final ContentProfileApi _contentProfileApi;

  ContentProfileRepositoryImpl(this._contentProfileApi);

  @override
  Future<List<ContentProfile>> getContentProfiles(String projectId) async {
    try {
      return await _contentProfileApi.getContentProfiles(projectId);
    } catch (e) {
      print('Error in ContentProfileRepositoryImpl: $e');
      rethrow;
    }
  }

  @override
  Future<ContentProfile> createContentProfile({
    required String projectId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    try {
      return await _contentProfileApi.createContentProfile(
        projectId: projectId,
        name: name,
        description: description,
        voiceAndTone: voiceAndTone,
        audience: audience,
      );
    } catch (e) {
      print('Error in ContentProfileRepositoryImpl.createContentProfile: $e');
      rethrow;
    }
  }

  @override
  Future<ContentProfile> updateContentProfile({
    required String projectId,
    required String contentProfileId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    try {
      return await _contentProfileApi.updateContentProfile(
        projectId: projectId,
        contentProfileId: contentProfileId,
        name: name,
        description: description,
        voiceAndTone: voiceAndTone,
        audience: audience,
      );
    } catch (e) {
      print('Error in ContentProfileRepositoryImpl.updateContentProfile: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContentProfile({
    required String projectId,
    required String contentProfileId,
  }) async {
    try {
      return await _contentProfileApi.deleteContentProfile(
        projectId: projectId,
        contentProfileId: contentProfileId,
      );
    } catch (e) {
      print('Error in ContentProfileRepositoryImpl.deleteContentProfile: $e');
      rethrow;
    }
  }
}
