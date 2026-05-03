import 'package:json_annotation/json_annotation.dart';

part 'analytics_metrics.g.dart';

@JsonSerializable()
class AnalyticsMetrics {
  final String brandMentions;
  final double brandMentionsRate;
  final String linkReferences;
  final double linkReferencesRate;
  final String totalResponses;
  @JsonKey(name: 'AIOverviewsCount')
  final String aiOverviewsCount;
  @JsonKey(name: 'AIOverviewsRate')
  final double aiOverviewsRate;
  final SentimentStats sentimentStats;
  final List<AnalyticsByDate> analyticsByDate;
  final List<AnalyticsByModel> analyticsByModel;

  AnalyticsMetrics({
    required this.brandMentions,
    required this.brandMentionsRate,
    required this.linkReferences,
    required this.linkReferencesRate,
    required this.totalResponses,
    required this.aiOverviewsCount,
    required this.aiOverviewsRate,
    required this.sentimentStats,
    required this.analyticsByDate,
    required this.analyticsByModel,
  });

  factory AnalyticsMetrics.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsMetricsToJson(this);

  // Helper getters to convert to int when needed
  int get brandMentionsInt => int.tryParse(brandMentions) ?? 0;
  int get linkReferencesInt => int.tryParse(linkReferences) ?? 0;
  int get totalResponsesInt => int.tryParse(totalResponses) ?? 0;
  int get aiOverviewsCountInt => int.tryParse(aiOverviewsCount) ?? 0;
}

@JsonSerializable()
class SentimentStats {
  final int positive;
  final int neutral;
  final int negative;

  SentimentStats({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  factory SentimentStats.fromJson(Map<String, dynamic> json) =>
      _$SentimentStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SentimentStatsToJson(this);

  int get total => positive + neutral + negative;

  double get positivePercent => total > 0 ? (positive / total) * 100 : 0.0;

  double get neutralPercent => total > 0 ? (neutral / total) * 100 : 0.0;

  double get negativePercent => total > 0 ? (negative / total) * 100 : 0.0;
}

@JsonSerializable()
class AnalyticsByDate {
  final String date;
  final int totalResponses;
  final int brandMentions;
  final int linkReferences;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  AnalyticsByDate({
    required this.date,
    required this.totalResponses,
    required this.brandMentions,
    required this.linkReferences,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  factory AnalyticsByDate.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsByDateFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsByDateToJson(this);
}

@JsonSerializable()
class AnalyticsByModel {
  @JsonKey(name: 'modelName')
  final String model;
  final int totalMentions;
  final int brandMentions;
  final Map<String, int> competitorMentions;

  AnalyticsByModel({
    required this.model,
    required this.totalMentions,
    required this.brandMentions,
    required this.competitorMentions,
  });

  factory AnalyticsByModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsByModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsByModelToJson(this);

  int get totalCompetitors =>
      competitorMentions.values.fold(0, (a, b) => a + b);

  double get brandMentionPercent => (brandMentions + totalCompetitors) > 0
      ? (brandMentions / (brandMentions + totalCompetitors)) * 100
      : 0.0;

  double get competitorAvgMentions => competitorMentions.isNotEmpty
      ? totalCompetitors / competitorMentions.length
      : 0.0;
}

// --- Fallback mock (when API sends all zeros / empty lists) ---

/// Placeholder analytics for empty API responses; keeps charts populated.
AnalyticsMetrics mockAnalyticsMetricsForDisplay() {
  return AnalyticsMetrics(
    brandMentions: '423',
    brandMentionsRate: 64.5,
    linkReferences: '147',
    linkReferencesRate: 22.3,
    totalResponses: '657',
    aiOverviewsCount: '87',
    aiOverviewsRate: 13.2,
    sentimentStats: SentimentStats(
      positive: 423,
      neutral: 147,
      negative: 87,
    ),
    analyticsByDate: const [],
    analyticsByModel: [
      AnalyticsByModel(
        model: 'ChatGPT',
        totalMentions: 285,
        brandMentions: 198,
        competitorMentions: {'Competitor A': 52, 'Competitor B': 35},
      ),
      AnalyticsByModel(
        model: 'Gemini',
        totalMentions: 156,
        brandMentions: 112,
        competitorMentions: {'Competitor A': 28, 'Competitor B': 16},
      ),
      AnalyticsByModel(
        model: 'Perplexity',
        totalMentions: 216,
        brandMentions: 135,
        competitorMentions: {'Competitor A': 56, 'Competitor B': 25},
      ),
    ],
  );
}

/// True when the API returns a “no data yet” payload (all metrics zero, lists empty).
bool isEffectivelyEmptyAnalytics(AnalyticsMetrics m) {
  final s = m.sentimentStats;
  final noSentiment = s.positive == 0 && s.neutral == 0 && s.negative == 0;
  if (!noSentiment) return false;

  final noLists = m.analyticsByDate.isEmpty && m.analyticsByModel.isEmpty;
  if (!noLists) return false;

  final noCounts = m.brandMentionsInt == 0 &&
      m.linkReferencesInt == 0 &&
      m.totalResponsesInt == 0 &&
      m.aiOverviewsCountInt == 0;
  final noRates = m.brandMentionsRate == 0 &&
      m.linkReferencesRate == 0 &&
      m.aiOverviewsRate == 0;

  return noCounts && noRates;
}

/// Replaces unusable analytics with [mockAnalyticsMetricsForDisplay].
AnalyticsMetrics applyAnalyticsMetricsFallbacks(AnalyticsMetrics m) {
  if (isEffectivelyEmptyAnalytics(m)) {
    return mockAnalyticsMetricsForDisplay();
  }
  return m;
}
