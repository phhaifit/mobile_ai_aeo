import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/domain/entity/prompt/prompt_summary.dart';

abstract class PromptRepository {
  Future<List<PromptSummary>> getPromptsByProject(String projectId);

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
  });
}
