import '../../entity/trend/weekly_report.dart';
import '../../entity/trend/trend_data_point.dart';
import '../../entity/trend/trend_period.dart';
import '../../entity/trend/performance_comparison.dart';
import '../../entity/trend/improvement_suggestion.dart';

abstract class TrendRepository {
  Future<WeeklyReport> getWeeklyReport();
  Future<List<TrendDataPoint>> getTrendData(TrendPeriod period);
  Future<List<PerformanceComparison>> getPerformanceComparisons();
  Future<List<ImprovementSuggestion>> getImprovementSuggestions();
}
