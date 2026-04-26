import '../../entity/trend/weekly_report.dart';
import '../../entity/trend/trend_data_point.dart';
import '../../entity/trend/trend_period.dart';
import '../../entity/trend/performance_comparison.dart';
import '../../entity/trend/improvement_suggestion.dart';

abstract class TrendRepository {
  Future<WeeklyReport> getWeeklyReport(String projectId);
  Future<List<TrendDataPoint>> getTrendData(String projectId, TrendPeriod period, {DateTime? customStartDate, DateTime? customEndDate});
  Future<List<PerformanceComparison>> getPerformanceComparisons(String projectId);
  Future<List<ImprovementSuggestion>> getImprovementSuggestions(String projectId);
  Future<void> triggerAnalysisRun(String projectId);
}
