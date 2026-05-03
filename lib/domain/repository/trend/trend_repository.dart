import '../../entity/trend/brand_analytics.dart';
import '../../entity/trend/content_performance_data.dart';

abstract class TrendRepository {
  /// Fetch brand analytics (metrics/analytics endpoint, granularity=day).
  Future<BrandAnalytics> getBrandAnalytics(
    String projectId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetch paginated content list.
  Future<ContentPerformanceData> getContentPerformance(
    String projectId, {
    int page = 1,
    int limit = 100,
    String sortOrder = 'asc',
  });

  /// Resolve the current user's project ID.
  Future<String> resolveProjectId();
}
