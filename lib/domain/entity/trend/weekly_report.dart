import 'package:intl/intl.dart';
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

  /// Assembles a [WeeklyReport] from the MetricsOverview + MetricsAnalytics
  /// API responses for the current and previous periods.
  factory WeeklyReport.fromApiData({
    required Map<String, dynamic> currentOverview,
    required Map<String, dynamic> previousOverview,
    required Map<String, dynamic> analytics,
    required DateTime startDate,
    required DateTime endDate,
    required List<ImprovementSuggestion> suggestions,
  }) {
    double parseSafeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final overallScore = parseSafeDouble(currentOverview['brandVisibilityScore']);

    // Parse daily analytics into trend data points
    final analyticsByDate =
        (analytics['analyticsByDate'] as List<dynamic>?) ?? [];
    final trendData = analyticsByDate
        .map((e) => TrendDataPoint.fromAnalyticsByDate(
              Map<String, dynamic>.from(e as Map),
              overallBrandScore: overallScore,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Compute comparisons between current and previous period
    final comparisons = PerformanceComparison.fromOverviewDiff(
      currentOverview,
      previousOverview,
    );

    // Build week label
    final weekLabel =
        '${DateFormat('MMM d').format(startDate)} – ${DateFormat('MMM d, yyyy').format(endDate)}';

    return WeeklyReport(
      weekLabel: weekLabel,
      startDate: startDate,
      endDate: endDate,
      trendData: trendData,
      comparisons: comparisons,
      suggestions: suggestions,
      overallHealthScore: overallScore,
    );
  }
}

