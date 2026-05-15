import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_polling_frequency_usecase.dart';

part 'llm_polling_frequency_store.g.dart';

class LlmPollingFrequencyStore = _LlmPollingFrequencyStore
    with _$LlmPollingFrequencyStore;

abstract class _LlmPollingFrequencyStore with Store {
  final GetLlmPollingFrequencyUseCase _getFrequencyUseCase;
  final UpdateLlmPollingFrequencyUseCase _updateFrequencyUseCase;

  _LlmPollingFrequencyStore(
    this._getFrequencyUseCase,
    this._updateFrequencyUseCase,
  );

  @observable
  LlmPollingFrequency? pollingFrequency;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isSaving = false;

  @action
  Future<void> getPollingFrequency(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      pollingFrequency = await _getFrequencyUseCase(projectId);
    } catch (e) {
      errorMessage = e.toString();
      print('LlmPollingFrequencyStore.getPollingFrequency error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updatePollingFrequency(
    String projectId,
    Map<String, dynamic> frequencyData,
  ) async {
    try {
      isSaving = true;
      errorMessage = null;
      pollingFrequency =
          await _updateFrequencyUseCase(projectId, frequencyData);
    } catch (e) {
      errorMessage = e.toString();
      print('LlmPollingFrequencyStore.updatePollingFrequency error: $e');
    } finally {
      isSaving = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    pollingFrequency = null;
    isLoading = false;
    errorMessage = null;
    isSaving = false;
  }
}
