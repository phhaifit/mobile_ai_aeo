import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';

abstract class LlmPollingFrequencyRepository {
  Future<LlmPollingFrequency> getPollingFrequency(String projectId);

  Future<LlmPollingFrequency> updatePollingFrequency(
    String projectId,
    Map<String, dynamic> frequencyData,
  );
}
