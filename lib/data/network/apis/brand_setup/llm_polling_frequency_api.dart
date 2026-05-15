import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';

class LlmPollingFrequencyApi {
  final DioClient _dioClient;

  LlmPollingFrequencyApi(this._dioClient);

  /// Get LLM polling frequency configuration
  Future<LlmPollingFrequency> getPollingFrequency(String projectId) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.llmPollingFrequency(projectId),
      );
      return LlmPollingFrequency.fromJson(res.data);
    } catch (e) {
      print(
          'LlmPollingFrequencyApi.getPollingFrequency error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update LLM polling frequency configuration
  Future<LlmPollingFrequency> updatePollingFrequency(
    String projectId,
    Map<String, dynamic> frequencyData,
  ) async {
    try {
      final res = await _dioClient.dio.put(
        Endpoints.llmPollingFrequency(projectId),
        data: frequencyData,
      );
      return LlmPollingFrequency.fromJson(res.data);
    } catch (e) {
      print(
          'LlmPollingFrequencyApi.updatePollingFrequency error: ${e.toString()}');
      rethrow;
    }
  }
}
