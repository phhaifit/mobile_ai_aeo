/// Wraps the full response from GET /api/projects/{id}/metrics/analytics.
class BrandAnalytics {
  final int brandMentions;
  final double brandMentionsRate;
  final int linkReferences;
  final double linkReferencesRate;
  final int aiOverviewsCount;
  final double aiOverviewsRate;
  final int totalResponses;
  final SentimentStats sentimentStats;
  final List<DailyAnalytics> analyticsByDate;
  final List<ModelAnalytics> analyticsByModel;

  BrandAnalytics({
    required this.brandMentions,
    required this.brandMentionsRate,
    required this.linkReferences,
    required this.linkReferencesRate,
    required this.aiOverviewsCount,
    required this.aiOverviewsRate,
    required this.totalResponses,
    required this.sentimentStats,
    required this.analyticsByDate,
    required this.analyticsByModel,
  });

  factory BrandAnalytics.fromJson(Map<String, dynamic> json) {
    return BrandAnalytics(
      brandMentions: _parseInt(json['brandMentions']),
      brandMentionsRate: _parseDouble(json['brandMentionsRate']),
      linkReferences: _parseInt(json['linkReferences']),
      linkReferencesRate: _parseDouble(json['linkReferencesRate']),
      aiOverviewsCount: _parseInt(json['AIOverviewsCount']),
      aiOverviewsRate: _parseDouble(json['AIOverviewsRate']),
      totalResponses: _parseInt(json['totalResponses']),
      sentimentStats: SentimentStats.fromJson(
        (json['sentimentStats'] as Map<String, dynamic>?) ?? {},
      ),
      analyticsByDate: ((json['analyticsByDate'] as List<dynamic>?) ?? [])
          .map((e) => DailyAnalytics.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)),
      analyticsByModel: ((json['analyticsByModel'] as List<dynamic>?) ?? [])
          .map((e) => ModelAnalytics.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

class SentimentStats {
  final int positive;
  final int neutral;
  final int negative;

  SentimentStats({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  int get total => positive + neutral + negative;

  factory SentimentStats.fromJson(Map<String, dynamic> json) {
    return SentimentStats(
      positive: BrandAnalytics._parseInt(json['positive']),
      neutral: BrandAnalytics._parseInt(json['neutral']),
      negative: BrandAnalytics._parseInt(json['negative']),
    );
  }
}

class DailyAnalytics {
  final DateTime date;
  final int totalResponses;
  final int brandMentions;
  final int linkReferences;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  DailyAnalytics({
    required this.date,
    required this.totalResponses,
    required this.brandMentions,
    required this.linkReferences,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    return DailyAnalytics(
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      totalResponses: BrandAnalytics._parseInt(json['totalResponses']),
      brandMentions: BrandAnalytics._parseInt(json['brandMentions']),
      linkReferences: BrandAnalytics._parseInt(json['linkReferences']),
      positiveCount: BrandAnalytics._parseInt(json['positiveCount']),
      neutralCount: BrandAnalytics._parseInt(json['neutralCount']),
      negativeCount: BrandAnalytics._parseInt(json['negativeCount']),
    );
  }
}

class ModelAnalytics {
  final String modelName;
  final int totalMentions;
  final int brandMentions;
  final Map<String, int> competitorMentions;

  ModelAnalytics({
    required this.modelName,
    required this.totalMentions,
    required this.brandMentions,
    required this.competitorMentions,
  });

  factory ModelAnalytics.fromJson(Map<String, dynamic> json) {
    final compMap = <String, int>{};
    final rawComp = json['competitorMentions'];
    if (rawComp is Map) {
      for (final entry in rawComp.entries) {
        compMap[entry.key.toString()] = BrandAnalytics._parseInt(entry.value);
      }
    }

    return ModelAnalytics(
      modelName: (json['modelName'] ?? '').toString(),
      totalMentions: BrandAnalytics._parseInt(json['totalMentions']),
      brandMentions: BrandAnalytics._parseInt(json['brandMentions']),
      competitorMentions: compMap,
    );
  }
}
