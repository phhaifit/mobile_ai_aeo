import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';
import 'package:boilerplate/utils/dio/dio_error_util.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'content_enhancement_store.g.dart';

class ContentEnhancementStore = _ContentEnhancementStore
    with _$ContentEnhancementStore;

abstract class _ContentEnhancementStore with Store {
  final EnhanceContentUseCase _enhanceUseCase;
  final RewriteContentUseCase _rewriteUseCase;
  final HumanizeContentUseCase _humanizeUseCase;
  final SummarizeContentUseCase _summarizeUseCase;
  final ErrorStore errorStore;

  _ContentEnhancementStore(
    this._enhanceUseCase,
    this._rewriteUseCase,
    this._humanizeUseCase,
    this._summarizeUseCase,
    this.errorStore,
  );

  @observable
  ContentOperation selectedOperation = ContentOperation.enhance;

  @observable
  String inputText = '';

  @observable
  ContentResult? currentResult;

  @observable
  ObservableList<ContentResult> sessionHistory = ObservableList<ContentResult>();

  @observable
  bool loading = false;

  @observable
  bool success = false;

  @action
  void setOperation(ContentOperation operation) {
    selectedOperation = operation;
  }

  @action
  void setInputText(String text) {
    inputText = text;
  }

  @action
  Future<void> processContent() async {
    if (inputText.trim().isEmpty) return;

    loading = true;
    success = false;

    try {
      final request = ContentRequest(
        text: inputText,
        operation: selectedOperation,
      );

      ContentResult result;
      switch (selectedOperation) {
        case ContentOperation.enhance:
          result = await _enhanceUseCase.call(params: request);
          break;
        case ContentOperation.rewrite:
          result = await _rewriteUseCase.call(params: request);
          break;
        case ContentOperation.humanize:
          result = await _humanizeUseCase.call(params: request);
          break;
        case ContentOperation.summarize:
          result = await _summarizeUseCase.call(params: request);
          break;
      }

      currentResult = result;
      sessionHistory.add(result);
      success = true;
    } catch (e) {
      if (e is DioException) {
        errorStore.errorMessage = DioExceptionUtil.handleError(e);
      } else {
        errorStore.errorMessage = e.toString();
      }
    } finally {
      loading = false;
    }
  }

  @action
  void clearResult() {
    currentResult = null;
    success = false;
  }

  @action
  void clearHistory() {
    sessionHistory.clear();
  }
}
