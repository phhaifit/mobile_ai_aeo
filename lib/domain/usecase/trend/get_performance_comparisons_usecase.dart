import '../../entity/trend/performance_comparison.dart';
import '../../repository/trend/trend_repository.dart';

class GetPerformanceComparisonsUseCase {
  final TrendRepository repository;

  GetPerformanceComparisonsUseCase({required this.repository});

  Future<List<PerformanceComparison>> call(String projectId) async {
    return await repository.getPerformanceComparisons(projectId);
  }
}
