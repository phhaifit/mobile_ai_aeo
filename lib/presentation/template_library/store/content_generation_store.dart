import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/domain/entity/prompt/prompt_summary.dart';
import 'package:boilerplate/domain/usecase/content/get_content_profiles_usecase.dart';
import 'package:boilerplate/domain/usecase/prompt/create_content_generation_usecase.dart';
import 'package:boilerplate/domain/usecase/prompt/get_prompts_by_project_usecase.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'content_generation_store.g.dart';

/// Hardcoded project id (same as other Template Library flows).
const String contentGenerationDefaultProjectId =
    '9022c9d7-7443-4a33-96aa-56628ba81220';

class ContentGenerationStore = _ContentGenerationStore
    with _$ContentGenerationStore;

abstract class _ContentGenerationStore with Store {
  final String TAG = '_ContentGenerationStore';

  final ErrorStore errorStore;
  final GetContentProfilesUseCase _getContentProfilesUseCase;
  final GetPromptsByProjectUseCase _getPromptsByProjectUseCase;
  final CreateContentGenerationUseCase _createContentGenerationUseCase;

  _ContentGenerationStore(
    this.errorStore,
    this._getContentProfilesUseCase,
    this._getPromptsByProjectUseCase,
    this._createContentGenerationUseCase,
  );

  @observable
  bool isLoadingLists = false;

  @observable
  bool isGenerating = false;

  @observable
  List<ContentProfile> contentProfiles = [];

  @observable
  List<PromptSummary> prompts = [];

  @observable
  ContentGenerationResult? lastResult;

  @action
  Future<void> loadLists() async {
    isLoadingLists = true;
    errorStore.reset('');
    try {
      final projectId = contentGenerationDefaultProjectId;
      final profilesFuture = _getContentProfilesUseCase(params: projectId);
      final promptsFuture = _getPromptsByProjectUseCase(params: projectId);
      final results = await Future.wait([profilesFuture, promptsFuture]);
      contentProfiles = results[0] as List<ContentProfile>;
      prompts = results[1] as List<PromptSummary>;
      print(
          '$TAG.loadLists: profiles=${contentProfiles.length} prompts=${prompts.length}');
    } catch (e) {
      print('$TAG.loadLists error: $e');
      errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingLists = false;
    }
  }

  @action
  Future<ContentGenerationResult?> generateContent({
    required String promptId,
    required String contentProfileId,
    required String contentType,
    required List<String> keywords,
    required String referencePageUrl,
    required String platform,
    required String improvement,
    required String referenceType,
    String? customerPersonaId,
  }) async {
    isGenerating = true;
    lastResult = null;
    errorStore.reset('');
    try {
      final params = CreateContentGenerationParams(
        promptId: promptId,
        projectId: contentGenerationDefaultProjectId,
        contentType: contentType,
        contentProfileId: contentProfileId,
        keywords: keywords,
        referencePageUrl: referencePageUrl,
        platform: platform,
        improvement: improvement,
        referenceType: referenceType,
        customerPersonaId: customerPersonaId,
      );
      final result = await _createContentGenerationUseCase(params: params);
      lastResult = result;
      print('$TAG.generateContent success id=${result.id}');
      return result;
    } catch (e) {
      print('$TAG.generateContent error: $e');
      errorStore.setErrorMessage(_messageForGenerateError(e));
      return null;
    } finally {
      isGenerating = false;
    }
  }

  @action
  void clearLastResult() {
    lastResult = null;
  }
}

String _messageForGenerateError(Object e) {
  if (e is! DioException) {
    return e.toString();
  }
  final code = e.response?.statusCode;
  if (code == 500) {
    return 'The server could not complete this request (500). Please try again in a moment.';
  }
  return DioExceptionUtil.handleError(e);
}
