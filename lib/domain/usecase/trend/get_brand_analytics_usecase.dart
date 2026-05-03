import '../../entity/trend/brand_analytics.dart';
import '../../repository/trend/trend_repository.dart';

class GetBrandAnalyticsUseCase {
  final TrendRepository repository;

  GetBrandAnalyticsUseCase({required this.repository});

  Future<BrandAnalytics> call(
    String projectId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getBrandAnalytics(
      projectId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
