import 'package:boilerplate/data/network/apis/brand_setup/llm_polling_frequency_api.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_polling_frequency_repository.dart';

class LlmPollingFrequencyRepositoryImpl extends LlmPollingFrequencyRepository {
  final LlmPollingFrequencyApi _api;

  LlmPollingFrequencyRepositoryImpl(this._api);

  @override
  Future<LlmPollingFrequency> getPollingFrequency(String projectId) async {
    try {
      return await _api.getPollingFrequency(projectId);
    } catch (e) {
      print('LlmPollingFrequencyRepositoryImpl.getPollingFrequency error: $e');
      rethrow;
    }
  }

  @override
  Future<LlmPollingFrequency> updatePollingFrequency(
    String projectId,
    Map<String, dynamic> frequencyData,
  ) async {
    try {
      return await _api.updatePollingFrequency(projectId, frequencyData);
    } catch (e) {
      print(
          'LlmPollingFrequencyRepositoryImpl.updatePollingFrequency error: $e');
      rethrow;
    }
  }
}
