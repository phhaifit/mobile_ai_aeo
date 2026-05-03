import 'package:boilerplate/data/network/apis/prompt/prompt_api.dart';
import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/domain/entity/prompt/prompt_summary.dart';
import 'package:boilerplate/domain/repository/prompt/prompt_repository.dart';

class PromptRepositoryImpl extends PromptRepository {
  final PromptApi _promptApi;

  PromptRepositoryImpl(this._promptApi);

  @override
  Future<List<PromptSummary>> getPromptsByProject(String projectId) async {
    try {
      return await _promptApi.getPromptsByProject(projectId);
    } catch (e) {
      print('PromptRepositoryImpl.getPromptsByProject error: ${e.toString()}');
      rethrow;
    }
  }

  @override
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
      return await _promptApi.createContentGeneration(
        promptId: promptId,
        projectId: projectId,
        contentType: contentType,
        contentProfileId: contentProfileId,
        keywords: keywords,
        referencePageUrl: referencePageUrl,
        platform: platform,
        improvement: improvement,
        referenceType: referenceType,
        customerPersonaId: customerPersonaId,
      );
    } catch (e) {
      print(
          'PromptRepositoryImpl.createContentGeneration error: ${e.toString()}');
      rethrow;
    }
  }
}
