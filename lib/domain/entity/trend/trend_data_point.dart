import 'package:intl/intl.dart';

class TrendDataPoint {
  final DateTime date;
  final String weekLabel;
  final double brandVisibility;
  final int brandMentions;
  final double linkVisibility;
  final int linkReferences;
  final double sentimentPositive;
  final double sentimentNegative;
  final double overallScore;

  TrendDataPoint({
    required this.date,
    required this.weekLabel,
    required this.brandVisibility,
    required this.brandMentions,
    required this.linkVisibility,
    required this.linkReferences,
    required this.sentimentPositive,
    required this.sentimentNegative,
    required this.overallScore,
  });

  /// Creates a [TrendDataPoint] from a single entry in the
  /// `MetricsAnalyticsDto.analyticsByDate` array returned by the backend.
  ///
  /// [overallBrandScore] is the project-level `brandVisibilityScore` from
  /// MetricsOverview, used as a baseline for the daily overall score.
  factory TrendDataPoint.fromAnalyticsByDate(
    Map<String, dynamic> json, {
    double overallBrandScore = 0.0,
  }) {
    final dateStr = (json['date'] ?? '').toString();
    final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();

    int parseSafeInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    final totalResponses = parseSafeInt(json['totalResponses']);
    final brandMentions = parseSafeInt(json['brandMentions']);
    final linkReferences = parseSafeInt(json['linkReferences']);
    final positiveCount = parseSafeInt(json['positiveCount']);
    final neutralCount = parseSafeInt(json['neutralCount']);
    final negativeCount = parseSafeInt(json['negativeCount']);

    final total = positiveCount + neutralCount + negativeCount;
    final brandVisibility =
        totalResponses > 0 ? (brandMentions / totalResponses * 100) : 0.0;
    final linkVisibility =
        totalResponses > 0 ? (linkReferences / totalResponses * 100) : 0.0;
    final sentimentPos = total > 0 ? (positiveCount / total * 100) : 0.0;
    final sentimentNeg = total > 0 ? (negativeCount / total * 100) : 0.0;

    return TrendDataPoint(
      date: parsedDate,
      weekLabel: DateFormat('MMM d').format(parsedDate),
      brandVisibility: brandVisibility,
      brandMentions: brandMentions,
      linkVisibility: linkVisibility,
      linkReferences: linkReferences,
      sentimentPositive: sentimentPos,
      sentimentNegative: sentimentNeg,
      overallScore: overallBrandScore,
    );
  }
}

