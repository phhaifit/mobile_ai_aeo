import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';
import 'package:boilerplate/domain/repository/brand_setup/llm_polling_frequency_repository.dart';

class GetLlmPollingFrequencyUseCase {
  final LlmPollingFrequencyRepository _repository;

  GetLlmPollingFrequencyUseCase(this._repository);

  Future<LlmPollingFrequency> call(String projectId) async {
    try {
      return await _repository.getPollingFrequency(projectId);
    } catch (e) {
      print('GetLlmPollingFrequencyUseCase error: $e');
      rethrow;
    }
  }
}

class UpdateLlmPollingFrequencyUseCase {
  final LlmPollingFrequencyRepository _repository;

  UpdateLlmPollingFrequencyUseCase(this._repository);

  Future<LlmPollingFrequency> call(
    String projectId,
    Map<String, dynamic> frequencyData,
  ) async {
    try {
      return await _repository.updatePollingFrequency(projectId, frequencyData);
    } catch (e) {
      print('UpdateLlmPollingFrequencyUseCase error: $e');
      rethrow;
    }
  }
}
