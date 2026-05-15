import 'package:boilerplate/data/network/apis/brand_setup/llm_monitoring_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_monitoring.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_monitoring_repository.dart';

class LlmMonitoringRepositoryImpl extends LlmMonitoringRepository {
  final LlmMonitoringApi _api;

  LlmMonitoringRepositoryImpl(this._api);

  @override
  Future<List<LlmMonitoring>> getMonitoringConfig(String projectId) async {
    try {
      return await _api.getMonitoringConfig(projectId);
    } catch (e) {
      print('LlmMonitoringRepositoryImpl.getMonitoringConfig error: $e');
      rethrow;
    }
  }

  @override
  Future<LlmMonitoring> getMonitoring(String projectId, String llmId) async {
    try {
      return await _api.getMonitoring(projectId, llmId);
    } catch (e) {
      print('LlmMonitoringRepositoryImpl.getMonitoring error: $e');
      rethrow;
    }
  }

  @override
  Future<LlmMonitoring> toggleLlmMonitoring(
    String projectId,
    String llmId,
    bool enabled,
  ) async {
    try {
      return await _api.toggleLlmMonitoring(projectId, llmId, enabled);
    } catch (e) {
      print('LlmMonitoringRepositoryImpl.toggleLlmMonitoring error: $e');
      rethrow;
    }
  }
}
