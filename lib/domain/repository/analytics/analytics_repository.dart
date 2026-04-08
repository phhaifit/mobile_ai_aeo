import 'package:boilerplate/domain/entity/analytics/analytics_metrics.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsMetrics> getAnalyticsMetrics(
    String projectId, {
    String? startDate,
    String? endDate,
  });
}
