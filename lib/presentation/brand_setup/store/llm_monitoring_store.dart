import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_monitoring.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_monitoring_usecase.dart';

part 'llm_monitoring_store.g.dart';

class LlmMonitoringStore = _LlmMonitoringStore with _$LlmMonitoringStore;

abstract class _LlmMonitoringStore with Store {
  final GetLlmMonitoringConfigUseCase _getConfigUseCase;
  final ToggleLlmMonitoringUseCase _toggleMonitoringUseCase;

  _LlmMonitoringStore(
    this._getConfigUseCase,
    this._toggleMonitoringUseCase,
  );

  @observable
  ObservableList<LlmMonitoring> monitoringConfig =
      ObservableList<LlmMonitoring>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isProcessing = false;

  @action
  Future<void> getMonitoringConfig(String projectId) async {
    try {
      isLoading = true;
      errorMessage = null;
      final result = await _getConfigUseCase(projectId);
      monitoringConfig = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
      print('LlmMonitoringStore.getMonitoringConfig error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> toggleMonitoring(
    String projectId,
    String llmId,
    bool enabled,
  ) async {
    try {
      isProcessing = true;
      errorMessage = null;
      final updated = await _toggleMonitoringUseCase(projectId, llmId, enabled);
      final index = monitoringConfig.indexWhere((m) => m.llmId == llmId);
      if (index != -1) {
        monitoringConfig[index] = updated;
      }
    } catch (e) {
      errorMessage = e.toString();
      print('LlmMonitoringStore.toggleMonitoring error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void reset() {
    monitoringConfig.clear();
    isLoading = false;
    errorMessage = null;
    isProcessing = false;
  }
}
