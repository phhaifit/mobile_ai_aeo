import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_monitoring.dart';

class LlmMonitoringApi {
  final DioClient _dioClient;

  LlmMonitoringApi(this._dioClient);

  /// Get LLM monitoring configuration for a project
  Future<List<LlmMonitoring>> getMonitoringConfig(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.llmMonitoring(projectId),
      );
      final list = res.data as List<dynamic>;
      return list
          .map((json) => LlmMonitoring.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('LlmMonitoringApi.getMonitoringConfig error: ${e.toString()}');
      rethrow;
    }
  }

  /// Enable/disable LLM monitoring
  Future<LlmMonitoring> toggleLlmMonitoring(
    String projectId,
    String llmId,
    bool enabled,
  ) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.llmMonitoringToggle(projectId, llmId),
        data: {'enabled': enabled},
      );
      return LlmMonitoring.fromJson(res.data);
    } catch (e) {
      print('LlmMonitoringApi.toggleLlmMonitoring error: ${e.toString()}');
      rethrow;
    }
  }

  /// Get specific LLM monitoring status
  Future<LlmMonitoring> getMonitoring(String projectId, String llmId) async {
    try {
      final res = await _dioClient.dio.get(
        '${Endpoints.llmMonitoring(projectId)}/$llmId',
      );
      return LlmMonitoring.fromJson(res.data);
    } catch (e) {
      print('LlmMonitoringApi.getMonitoring error: ${e.toString()}');
      rethrow;
    }
  }
}
