import 'package:boilerplate/domain/entity/overview/overview_metrics.dart';

abstract class OverviewRepository {
  /// Get overview metrics for a project
  /// [projectId] - The project ID
  /// [startDate] - Start date parameter
  /// [endDate] - End date parameter
  Future<OverviewMetrics> getOverviewMetrics({
    required String projectId,
    required String startDate,
    required String endDate,
  });
}
