// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsMetrics _$AnalyticsMetricsFromJson(Map<String, dynamic> json) =>
    AnalyticsMetrics(
      brandMentions: json['brandMentions'] as String,
      brandMentionsRate: (json['brandMentionsRate'] as num).toDouble(),
      linkReferences: json['linkReferences'] as String,
      linkReferencesRate: (json['linkReferencesRate'] as num).toDouble(),
      totalResponses: json['totalResponses'] as String,
      aiOverviewsCount: json['AIOverviewsCount'] as String,
      aiOverviewsRate: (json['AIOverviewsRate'] as num).toDouble(),
      sentimentStats: SentimentStats.fromJson(
          json['sentimentStats'] as Map<String, dynamic>),
      analyticsByDate: (json['analyticsByDate'] as List<dynamic>)
          .map((e) => AnalyticsByDate.fromJson(e as Map<String, dynamic>))
          .toList(),
      analyticsByModel: (json['analyticsByModel'] as List<dynamic>)
          .map((e) => AnalyticsByModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsMetricsToJson(AnalyticsMetrics instance) =>
    <String, dynamic>{
      'brandMentions': instance.brandMentions,
      'brandMentionsRate': instance.brandMentionsRate,
      'linkReferences': instance.linkReferences,
      'linkReferencesRate': instance.linkReferencesRate,
      'totalResponses': instance.totalResponses,
      'AIOverviewsCount': instance.aiOverviewsCount,
      'AIOverviewsRate': instance.aiOverviewsRate,
      'sentimentStats': instance.sentimentStats,
      'analyticsByDate': instance.analyticsByDate,
      'analyticsByModel': instance.analyticsByModel,
    };

SentimentStats _$SentimentStatsFromJson(Map<String, dynamic> json) =>
    SentimentStats(
      positive: (json['positive'] as num).toInt(),
      neutral: (json['neutral'] as num).toInt(),
      negative: (json['negative'] as num).toInt(),
    );

Map<String, dynamic> _$SentimentStatsToJson(SentimentStats instance) =>
    <String, dynamic>{
      'positive': instance.positive,
      'neutral': instance.neutral,
      'negative': instance.negative,
    };

AnalyticsByDate _$AnalyticsByDateFromJson(Map<String, dynamic> json) =>
    AnalyticsByDate(
      date: json['date'] as String,
      totalResponses: (json['totalResponses'] as num).toInt(),
      brandMentions: (json['brandMentions'] as num).toInt(),
      linkReferences: (json['linkReferences'] as num).toInt(),
      positiveCount: (json['positiveCount'] as num).toInt(),
      neutralCount: (json['neutralCount'] as num).toInt(),
      negativeCount: (json['negativeCount'] as num).toInt(),
    );

Map<String, dynamic> _$AnalyticsByDateToJson(AnalyticsByDate instance) =>
    <String, dynamic>{
      'date': instance.date,
      'totalResponses': instance.totalResponses,
      'brandMentions': instance.brandMentions,
      'linkReferences': instance.linkReferences,
      'positiveCount': instance.positiveCount,
      'neutralCount': instance.neutralCount,
      'negativeCount': instance.negativeCount,
    };

AnalyticsByModel _$AnalyticsByModelFromJson(Map<String, dynamic> json) =>
    AnalyticsByModel(
      model: json['modelName'] as String,
      totalMentions: (json['totalMentions'] as num).toInt(),
      brandMentions: (json['brandMentions'] as num).toInt(),
      competitorMentions:
          Map<String, int>.from(json['competitorMentions'] as Map),
    );

Map<String, dynamic> _$AnalyticsByModelToJson(AnalyticsByModel instance) =>
    <String, dynamic>{
      'modelName': instance.model,
      'totalMentions': instance.totalMentions,
      'brandMentions': instance.brandMentions,
      'competitorMentions': instance.competitorMentions,
    };
