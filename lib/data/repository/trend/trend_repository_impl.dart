import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:boilerplate/domain/entity/trend/weekly_report.dart';
import 'package:boilerplate/domain/entity/trend/trend_data_point.dart';
import 'package:boilerplate/domain/entity/trend/trend_period.dart';
import 'package:boilerplate/domain/entity/trend/performance_comparison.dart';
import 'package:boilerplate/domain/entity/trend/improvement_suggestion.dart';
import 'package:boilerplate/domain/repository/trend/trend_repository.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';

class TrendRepositoryImpl implements TrendRepository {
  final PerformanceApi _api;

  TrendRepositoryImpl(this._api);

  // ── Date helpers ───────────────────────────────────────────────────────────

  /// Returns (startDate, endDate) as ISO strings for the given [TrendPeriod].
  ({String start, String end}) _dateRangeForPeriod(TrendPeriod period) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    late final DateTime start;

    switch (period) {
      case TrendPeriod.last4Weeks:
        start = end.subtract(const Duration(days: 28));
        break;
      case TrendPeriod.last8Weeks:
        start = end.subtract(const Duration(days: 56));
        break;
      case TrendPeriod.last12Weeks:
        start = end.subtract(const Duration(days: 84));
        break;
      case TrendPeriod.last24Weeks:
        start = end.subtract(const Duration(days: 168));
        break;
    }

    final fmt = DateFormat('yyyy-MM-dd');
    return (start: fmt.format(start), end: fmt.format(end));
  }

  // ── Repository methods ────────────────────────────────────────────────────

  @override
  Future<WeeklyReport> getWeeklyReport(String projectId) async {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 30));
    final previousStart = startDate.subtract(const Duration(days: 30));

    final fmt = DateFormat('yyyy-MM-dd');
    final startStr = fmt.format(startDate);
    final endStr = fmt.format(endDate);
    final prevStartStr = fmt.format(previousStart);
    final prevEndStr = fmt.format(startDate.subtract(const Duration(days: 1)));

    // Fetch current period overview + analytics, previous period overview
    final results = await Future.wait([
      _api.getMetricsOverview(projectId, start: startStr, end: endStr),
      _api.getMetricsOverview(projectId, start: prevStartStr, end: prevEndStr),
      _api.getMetricsAnalytics(projectId, start: startStr, end: endStr),
    ]);

    final currentOverview = results[0];
    final previousOverview = results[1];
    final analytics = results[2];

    // Generate suggestions based on real data
    final suggestions = _generateSuggestions(currentOverview, analytics);

    return WeeklyReport.fromApiData(
      currentOverview: currentOverview,
      previousOverview: previousOverview,
      analytics: analytics,
      startDate: startDate,
      endDate: endDate,
      suggestions: suggestions,
    );
  }

  @override
  Future<List<TrendDataPoint>> getTrendData(
    String projectId,
    TrendPeriod period,
  ) async {
    final range = _dateRangeForPeriod(period);

    final analytics = await _api.getMetricsAnalytics(
      projectId,
      start: range.start,
      end: range.end,
    );

    // Also grab overall score for the period
    final overview = await _api.getMetricsOverview(
      projectId,
      start: range.start,
      end: range.end,
    );
    double parseSafeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final overallScore = parseSafeDouble(overview['brandVisibilityScore']);

    final analyticsByDate =
        (analytics['analyticsByDate'] as List<dynamic>?) ?? [];

    return analyticsByDate
        .map((e) => TrendDataPoint.fromAnalyticsByDate(
              Map<String, dynamic>.from(e as Map),
              overallBrandScore: overallScore,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<PerformanceComparison>> getPerformanceComparisons(
    String projectId,
  ) async {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 30));
    final previousStart = startDate.subtract(const Duration(days: 30));

    final fmt = DateFormat('yyyy-MM-dd');

    final results = await Future.wait([
      _api.getMetricsOverview(
        projectId,
        start: fmt.format(startDate),
        end: fmt.format(endDate),
      ),
      _api.getMetricsOverview(
        projectId,
        start: fmt.format(previousStart),
        end: fmt.format(startDate.subtract(const Duration(days: 1))),
      ),
    ]);

    return PerformanceComparison.fromOverviewDiff(results[0], results[1]);
  }

  @override
  Future<List<ImprovementSuggestion>> getImprovementSuggestions(
    String projectId,
  ) async {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 30));
    final fmt = DateFormat('yyyy-MM-dd');

    final results = await Future.wait([
      _api.getMetricsOverview(
        projectId,
        start: fmt.format(startDate),
        end: fmt.format(endDate),
      ),
      _api.getMetricsAnalytics(
        projectId,
        start: fmt.format(startDate),
        end: fmt.format(endDate),
      ),
    ]);

    return _generateSuggestions(results[0], results[1]);
  }

  @override
  Future<void> triggerAnalysisRun(String projectId) async {
    await _api.triggerAnalysis(projectId);
  }

  // ── Suggestion generation (client-side) ──────────────────────────────────

  List<ImprovementSuggestion> _generateSuggestions(
    Map<String, dynamic> overview,
    Map<String, dynamic> analytics,
  ) {
    double parseSafeDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final suggestions = <ImprovementSuggestion>[];
    final brandRate = parseSafeDouble(overview['brandMentionsRate']);
    final linkRate = parseSafeDouble(overview['linkReferencesRate']);
    
    final sentimentStats =
        (analytics['sentimentStats'] as Map<String, dynamic>?) ?? {};
    final positive = parseSafeDouble(sentimentStats['positive']);
    final negative = parseSafeDouble(sentimentStats['negative']);
    final neutral = parseSafeDouble(sentimentStats['neutral']);
    final totalSentiment = positive + negative + neutral;
    final positiveRate =
        totalSentiment > 0 ? (positive / totalSentiment * 100) : 0.0;
    final negativeRate =
        totalSentiment > 0 ? (negative / totalSentiment * 100) : 0.0;

    if (brandRate < 50) {
      suggestions.add(ImprovementSuggestion(
        title: 'Increase content publishing frequency',
        description:
            'Your brand visibility rate is ${brandRate.toStringAsFixed(1)}%. '
            'Publishing more AI-optimized content can help increase AI model citations.',
        priority: 'High',
        relatedMetric: 'Brand Visibility',
        icon: Icons.edit_calendar,
      ));
    }

    if (linkRate < 40) {
      suggestions.add(ImprovementSuggestion(
        title: 'Improve link reference presence',
        description:
            'Your link reference rate is ${linkRate.toStringAsFixed(1)}%. '
            'Add structured data and authoritative backlinks to increase URL citations in AI responses.',
        priority: 'High',
        relatedMetric: 'Link Visibility',
        icon: Icons.link,
      ));
    }

    if (negativeRate > 20) {
      suggestions.add(ImprovementSuggestion(
        title: 'Address negative sentiment',
        description:
            'Negative sentiment is at ${negativeRate.toStringAsFixed(1)}%. '
            'Consider publishing positive case studies and addressing criticism constructively.',
        priority: 'Medium',
        relatedMetric: 'Sentiment',
        icon: Icons.sentiment_dissatisfied,
      ));
    }

    if (positiveRate < 60) {
      suggestions.add(ImprovementSuggestion(
        title: 'Boost positive sentiment',
        description:
            'Positive sentiment is only ${positiveRate.toStringAsFixed(1)}%. '
            'Focus on customer success stories and expert endorsements to improve brand perception.',
        priority: 'Medium',
        relatedMetric: 'Sentiment',
        icon: Icons.sentiment_satisfied_alt,
      ));
    }

    // Always provide at least one suggestion
    if (suggestions.isEmpty) {
      suggestions.add(ImprovementSuggestion(
        title: 'Continue monitoring your brand',
        description:
            'Your metrics are looking good! Keep monitoring and adjusting your content strategy '
            'to maintain and improve your AI visibility.',
        priority: 'Low',
        relatedMetric: 'Brand Visibility',
        icon: Icons.check_circle_outline,
      ));
    }

    return suggestions;
  }
}
