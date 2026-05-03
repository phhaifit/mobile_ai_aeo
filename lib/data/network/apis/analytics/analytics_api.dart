import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/analytics/analytics_metrics.dart';

class AnalyticsApi {
  final DioClient _dioClient;

  AnalyticsApi(this._dioClient);

  /// Fetch analytics metrics
  /// GET /api/projects/{projectId}/metrics/analytics
  Future<AnalyticsMetrics> getAnalyticsMetrics(
    String projectId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final endpoint = Endpoints.getAnalyticsMetrics(projectId);
      final queryParams = {
        'start': startDate,
        'end': endDate,
      };
      
      // Build full URL for logging
      final baseUrl = _dioClient.dio.options.baseUrl;
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      final fullUrl = '$baseUrl$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}';
      
      print('AnalyticsApi.getAnalyticsMetrics calling: $fullUrl');
      
      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );
      print('AnalyticsApi.getAnalyticsMetrics success: $fullUrl');
      return AnalyticsMetrics.fromJson(response.data);
    } catch (e) {
      print('AnalyticsApi.getAnalyticsMetrics error: ${e.toString()}');
      rethrow;
    }
  }
}
