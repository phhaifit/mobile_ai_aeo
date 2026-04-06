import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/overview/overview_metrics.dart';

class OverviewApi {
  final DioClient _dioClient;

  OverviewApi(this._dioClient);

  /// Get overview metrics for a project
  /// [projectId] - The project ID
  /// [startDate] - Start date in ISO 8601 format (e.g., 2026-04-06T11:45:09)
  /// [endDate] - End date in ISO 8601 format (e.g., 2026-04-06T11:45:09)
  Future<OverviewMetrics> getOverviewMetrics({
    required String projectId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final endpoint = Endpoints.getOverviewMetrics(projectId);
      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: {
          'start': startDate,
          'end': endDate,
        },
      );

      print('OverviewApi.getOverviewMetrics success: $endpoint');
      return OverviewMetrics.fromJson(response.data);
    } catch (e) {
      print('OverviewApi.getOverviewMetrics error: ${e.toString()}');
      rethrow;
    }
  }
}
