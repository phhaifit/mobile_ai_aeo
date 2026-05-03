import 'package:boilerplate/domain/entity/content/content_profile.dart';

abstract class ContentProfileRepository {
  /// Get all content profiles for a project
  Future<List<ContentProfile>> getContentProfiles(String projectId);

  /// Create a new content profile
  Future<ContentProfile> createContentProfile({
    required String projectId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  });

  /// Update an existing content profile
  Future<ContentProfile> updateContentProfile({
    required String projectId,
    required String contentProfileId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  });

  /// Delete a content profile
  Future<void> deleteContentProfile({
    required String projectId,
    required String contentProfileId,
  });
}
