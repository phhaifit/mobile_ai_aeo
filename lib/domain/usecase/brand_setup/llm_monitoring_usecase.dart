import 'package:boilerplate/domain/entity/brand_setup/llm_monitoring.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_monitoring_repository.dart';

class GetLlmMonitoringConfigUseCase {
  final LlmMonitoringRepository _repository;

  GetLlmMonitoringConfigUseCase(this._repository);

  Future<List<LlmMonitoring>> call(String projectId) async {
    try {
      return await _repository.getMonitoringConfig(projectId);
    } catch (e) {
      print('GetLlmMonitoringConfigUseCase error: $e');
      rethrow;
    }
  }
}

class ToggleLlmMonitoringUseCase {
  final LlmMonitoringRepository _repository;

  ToggleLlmMonitoringUseCase(this._repository);

  Future<LlmMonitoring> call(
    String projectId,
    String llmId,
    bool enabled,
  ) async {
    try {
      return await _repository.toggleLlmMonitoring(projectId, llmId, enabled);
    } catch (e) {
      print('ToggleLlmMonitoringUseCase error: $e');
      rethrow;
    }
  }
}
