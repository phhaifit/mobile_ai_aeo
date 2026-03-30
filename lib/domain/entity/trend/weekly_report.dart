import 'trend_data_point.dart';
import 'performance_comparison.dart';
import 'improvement_suggestion.dart';

class WeeklyReport {
  final String weekLabel;
  final DateTime startDate;
  final DateTime endDate;
  final List<TrendDataPoint> trendData;
  final List<PerformanceComparison> comparisons;
  final List<ImprovementSuggestion> suggestions;
  final double overallHealthScore;

  WeeklyReport({
    required this.weekLabel,
    required this.startDate,
    required this.endDate,
    required this.trendData,
    required this.comparisons,
    required this.suggestions,
    required this.overallHealthScore,
  });
}
