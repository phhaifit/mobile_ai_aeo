import '../../entity/trend/trend_data_point.dart';
import '../../entity/trend/trend_period.dart';
import '../../repository/trend/trend_repository.dart';

class GetTrendDataUseCase {
  final TrendRepository repository;

  GetTrendDataUseCase({required this.repository});

  Future<List<TrendDataPoint>> call(TrendPeriod period) async {
    return await repository.getTrendData(period);
  }
}
