import '../../entity/trend/content_performance_data.dart';
import '../../repository/trend/trend_repository.dart';

class GetContentPerformanceUseCase {
  final TrendRepository repository;

  GetContentPerformanceUseCase({required this.repository});

  Future<ContentPerformanceData> call(
    String projectId, {
    int page = 1,
    int limit = 100,
    String sortOrder = 'asc',
  }) async {
    return await repository.getContentPerformance(
      projectId,
      page: page,
      limit: limit,
      sortOrder: sortOrder,
    );
  }
}
