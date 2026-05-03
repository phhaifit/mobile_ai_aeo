import 'dart:async';

import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/network/apis/content/content_api.dart';
import 'package:boilerplate/domain/entity/content/content_item.dart';
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
  final ContentApi _contentApi;
  final ErrorStore errorStore;

  static const Duration _pollInterval = Duration(seconds: 3);
  static const int _maxPollAttempts = 60; // ~3 min total

  _ContentEnhancementStore(
    this._enhanceUseCase,
    this._rewriteUseCase,
    this._humanizeUseCase,
    this._summarizeUseCase,
    this._contentApi,
    this.errorStore,
  );

  // ─── Picker state ────────────────────────────────────────────────────────

  @observable
  ObservableList<ContentItem> availableContents =
      ObservableList<ContentItem>();

  @observable
  ContentItem? selectedContent;

  @observable
  bool loadingContents = false;

  @observable
  String? activeProjectId;

  // ─── Operation state ─────────────────────────────────────────────────────

  @observable
  ContentOperation selectedOperation = ContentOperation.enhance;

  /// One of: professional, casual, friendly, formal, playful (or null = no tone hint).
  /// Sent as `tone` in the request body — applies to enhance / rewrite / humanize.
  @observable
  String? selectedTone;

  /// One of: short, medium, long. Only used when [selectedOperation] is summarize.
  @observable
  String selectedLength = 'medium';

  /// Optional free-text instruction the user can append to the operation
  /// preset. Maps to `customInstruction` on the BE DTO and is appended to
  /// the regenerate `improvement` prompt.
  @observable
  String customInstruction = '';

  @observable
  ContentResult? currentResult;

  @observable
  ObservableList<ContentResult> sessionHistory =
      ObservableList<ContentResult>();

  @observable
  bool loading = false;

  @observable
  bool success = false;

  @observable
  String? activeJobId;

  Timer? _pollTimer;
  int _pollAttempts = 0;

  // ─── Picker actions ──────────────────────────────────────────────────────

  /// Load the user's first project + its contents. Called from screen init.
  /// If projects list is empty (new account), [availableContents] stays empty
  /// and the UI shows an empty-state hint.
  @action
  Future<void> loadAvailableContents({bool force = false}) async {
    if (loadingContents) return;
    if (!force && availableContents.isNotEmpty) return;

    loadingContents = true;
    try {
      final projects = await _contentApi.listProjects();
      if (projects.isEmpty) {
        availableContents = ObservableList<ContentItem>();
        return;
      }
      final projectId = projects.first['id']?.toString() ?? '';
      if (projectId.isEmpty) return;
      activeProjectId = projectId;

      final items = await _contentApi.listProjectContents(projectId);
      availableContents = ObservableList<ContentItem>.of(items);
    } catch (e) {
      _surfaceError(e);
    } finally {
      loadingContents = false;
    }
  }

  @action
  void selectContent(ContentItem item) {
    selectedContent = item;
    // Reset previous result so the user sees a clean preview.
    currentResult = null;
    success = false;
  }

  @action
  void clearSelection() {
    selectedContent = null;
    currentResult = null;
    success = false;
    _cancelPolling();
  }

  // ─── Operation actions ───────────────────────────────────────────────────

  @action
  void setOperation(ContentOperation operation) {
    selectedOperation = operation;
  }

  @action
  void setTone(String? tone) {
    selectedTone = tone;
  }

  @action
  void setLength(String length) {
    selectedLength = length;
  }

  @action
  void setCustomInstruction(String value) {
    customInstruction = value;
  }

  /// Build the body options for the API call from the current state.
  Map<String, dynamic>? _buildOptions() {
    final options = <String, dynamic>{};
    final isSummarize = selectedOperation == ContentOperation.summarize;
    if (!isSummarize && selectedTone != null && selectedTone!.isNotEmpty) {
      options['tone'] = selectedTone;
    }
    if (isSummarize) {
      options['length'] = selectedLength;
    }
    final trimmed = customInstruction.trim();
    if (trimmed.isNotEmpty) {
      options['customInstruction'] = trimmed;
    }
    return options.isEmpty ? null : options;
  }

  @action
  Future<void> processContent() async {
    final picked = selectedContent;
    if (picked == null || picked.id.isEmpty) return;

    _cancelPolling();
    loading = true;
    success = false;
    currentResult = null;

    try {
      final request = ContentRequest(
        contentId: picked.id,
        operation: selectedOperation,
        options: _buildOptions(),
      );

      final ContentResult ack;
      switch (selectedOperation) {
        case ContentOperation.enhance:
          ack = await _enhanceUseCase.call(params: request);
          break;
        case ContentOperation.rewrite:
          ack = await _rewriteUseCase.call(params: request);
          break;
        case ContentOperation.humanize:
          ack = await _humanizeUseCase.call(params: request);
          break;
        case ContentOperation.summarize:
          ack = await _summarizeUseCase.call(params: request);
          break;
      }

      activeJobId = ack.jobId;
      currentResult = ack;
      _startPolling(ack.jobId);
    } catch (e) {
      loading = false;
      _surfaceError(e);
    }
  }

  void _startPolling(String jobId) {
    _pollAttempts = 0;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce(jobId));
  }

  Future<void> _pollOnce(String jobId) async {
    _pollAttempts++;
    if (_pollAttempts > _maxPollAttempts) {
      _cancelPolling();
      loading = false;
      errorStore.errorMessage =
          'Enhancement timed out after ${_maxPollAttempts * _pollInterval.inSeconds}s';
      return;
    }

    try {
      final result = await _contentApi.pollByJob(jobId);
      if (result == null) return; // still running
      _cancelPolling();
      currentResult = result.copyWith(operation: selectedOperation);
      sessionHistory.add(currentResult!);
      success = true;
      loading = false;
    } catch (e) {
      _cancelPolling();
      loading = false;
      _surfaceError(e);
    }
  }

  void _cancelPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _surfaceError(Object e) {
    if (e is DioException) {
      errorStore.errorMessage = DioExceptionUtil.handleError(e);
    } else {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  void clearResult() {
    currentResult = null;
    success = false;
    activeJobId = null;
    _cancelPolling();
  }

  @action
  void clearHistory() {
    sessionHistory.clear();
  }
}
