import 'package:boilerplate/domain/entity/brand_setup/llm_monitoring.dart';

abstract class LlmMonitoringRepository {
  Future<List<LlmMonitoring>> getMonitoringConfig(String projectId);

  Future<LlmMonitoring> getMonitoring(String projectId, String llmId);

  Future<LlmMonitoring> toggleLlmMonitoring(
    String projectId,
    String llmId,
    bool enabled,
  );
}
