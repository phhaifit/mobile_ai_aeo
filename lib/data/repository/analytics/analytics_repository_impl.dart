import 'package:boilerplate/data/network/apis/analytics/analytics_api.dart';
import 'package:boilerplate/domain/entity/analytics/analytics_metrics.dart';
import 'package:boilerplate/domain/repository/analytics/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsApi _analyticsApi;

  AnalyticsRepositoryImpl(this._analyticsApi);

  @override
  Future<AnalyticsMetrics> getAnalyticsMetrics(
    String projectId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _analyticsApi.getAnalyticsMetrics(
        projectId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Error in AnalyticsRepositoryImpl: $e');
      rethrow;
    }
  }
}
