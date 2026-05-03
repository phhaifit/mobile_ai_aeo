import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/domain/repository/prompt/prompt_repository.dart';

class CreateContentGenerationParams {
  final String promptId;
  final String projectId;
  final String contentType;
  final String contentProfileId;
  final List<String> keywords;
  final String referencePageUrl;
  final String platform;
  final String improvement;
  final String referenceType;
  final String? customerPersonaId;

  CreateContentGenerationParams({
    required this.promptId,
    required this.projectId,
    required this.contentType,
    required this.contentProfileId,
    required this.keywords,
    required this.referencePageUrl,
    required this.platform,
    required this.improvement,
    required this.referenceType,
    this.customerPersonaId,
  });
}

class CreateContentGenerationUseCase
    extends UseCase<ContentGenerationResult, CreateContentGenerationParams> {
  final PromptRepository _repository;

  CreateContentGenerationUseCase(this._repository);

  @override
  Future<ContentGenerationResult> call(
      {required CreateContentGenerationParams params}) {
    return _repository.createContentGeneration(
      promptId: params.promptId,
      projectId: params.projectId,
      contentType: params.contentType,
      contentProfileId: params.contentProfileId,
      keywords: params.keywords,
      referencePageUrl: params.referencePageUrl,
      platform: params.platform,
      improvement: params.improvement,
      referenceType: params.referenceType,
      customerPersonaId: params.customerPersonaId,
    );
  }
}
