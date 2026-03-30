import 'package:flutter/material.dart';
import '../../domain/entity/trend/trend_data_point.dart';
import '../../domain/entity/trend/trend_period.dart';
import '../../domain/entity/trend/performance_comparison.dart';
import '../../domain/entity/trend/improvement_suggestion.dart';
import '../../domain/entity/trend/weekly_report.dart';

class TrendSeedData {
  static List<TrendDataPoint> getAllTrendData() {
    return [
      TrendDataPoint(
        date: DateTime(2026, 2, 3),
        weekLabel: 'W1',
        brandVisibility: 58.1,
        brandMentions: 890,
        linkVisibility: 42.3,
        linkReferences: 534,
        sentimentPositive: 58.2,
        sentimentNegative: 18.4,
        overallScore: 35.2,
      ),
      TrendDataPoint(
        date: DateTime(2026, 2, 10),
        weekLabel: 'W2',
        brandVisibility: 60.3,
        brandMentions: 945,
        linkVisibility: 44.1,
        linkReferences: 567,
        sentimentPositive: 59.8,
        sentimentNegative: 17.1,
        overallScore: 37.8,
      ),
      TrendDataPoint(
        date: DateTime(2026, 2, 17),
        weekLabel: 'W3',
        brandVisibility: 59.8,
        brandMentions: 912,
        linkVisibility: 43.5,
        linkReferences: 548,
        sentimentPositive: 58.9,
        sentimentNegative: 17.8,
        overallScore: 36.5,
      ),
      TrendDataPoint(
        date: DateTime(2026, 2, 24),
        weekLabel: 'W4',
        brandVisibility: 62.4,
        brandMentions: 1023,
        linkVisibility: 46.2,
        linkReferences: 612,
        sentimentPositive: 61.3,
        sentimentNegative: 15.9,
        overallScore: 39.1,
      ),
      TrendDataPoint(
        date: DateTime(2026, 3, 3),
        weekLabel: 'W5',
        brandVisibility: 63.1,
        brandMentions: 1087,
        linkVisibility: 47.8,
        linkReferences: 645,
        sentimentPositive: 62.1,
        sentimentNegative: 15.2,
        overallScore: 38.7,
      ),
      TrendDataPoint(
        date: DateTime(2026, 3, 10),
        weekLabel: 'W6',
        brandVisibility: 65.0,
        brandMentions: 1156,
        linkVisibility: 49.5,
        linkReferences: 689,
        sentimentPositive: 63.5,
        sentimentNegative: 14.1,
        overallScore: 40.2,
      ),
      TrendDataPoint(
        date: DateTime(2026, 3, 17),
        weekLabel: 'W7',
        brandVisibility: 66.5,
        brandMentions: 1198,
        linkVisibility: 51.2,
        linkReferences: 723,
        sentimentPositive: 64.0,
        sentimentNegative: 13.5,
        overallScore: 41.8,
      ),
      TrendDataPoint(
        date: DateTime(2026, 3, 24),
        weekLabel: 'W8',
        brandVisibility: 67.3,
        brandMentions: 1248,
        linkVisibility: 52.8,
        linkReferences: 756,
        sentimentPositive: 64.5,
        sentimentNegative: 13.2,
        overallScore: 42.5,
      ),
    ];
  }

  static List<TrendDataPoint> getTrendDataForPeriod(TrendPeriod period) {
    final allData = getAllTrendData();
    switch (period) {
      case TrendPeriod.last4Weeks:
        return allData.length > 4 ? allData.sublist(allData.length - 4) : allData;
      case TrendPeriod.last8Weeks:
        return allData;
      case TrendPeriod.last12Weeks:
        return allData; // Only 8 weeks of mock data available
      case TrendPeriod.last24Weeks:
        return allData; // Only 8 weeks of mock data available
    }
  }

  static List<PerformanceComparison> getPerformanceComparisons() {
    return [
      PerformanceComparison(
        metricName: 'Brand Visibility',
        currentValue: 67.3,
        previousValue: 66.5,
        changePercent: 1.2,
        isImproved: true,
      ),
      PerformanceComparison(
        metricName: 'Brand Mentions',
        currentValue: 1248,
        previousValue: 1198,
        changePercent: 4.2,
        isImproved: true,
      ),
      PerformanceComparison(
        metricName: 'Link Visibility',
        currentValue: 52.8,
        previousValue: 51.2,
        changePercent: 3.1,
        isImproved: true,
      ),
      PerformanceComparison(
        metricName: 'Link References',
        currentValue: 756,
        previousValue: 723,
        changePercent: 4.6,
        isImproved: true,
      ),
      PerformanceComparison(
        metricName: 'Positive Sentiment',
        currentValue: 64.5,
        previousValue: 64.0,
        changePercent: 0.8,
        isImproved: true,
      ),
      PerformanceComparison(
        metricName: 'Negative Sentiment',
        currentValue: 13.2,
        previousValue: 13.5,
        changePercent: -2.2,
        isImproved: true, // Lower negative sentiment is an improvement
      ),
    ];
  }

  static List<ImprovementSuggestion> getImprovementSuggestions() {
    return [
      ImprovementSuggestion(
        title: 'Increase content publishing frequency',
        description:
            'Publishing 3x/week instead of 2x/week can increase AI visibility by up to 40%. Focus on long-form, authoritative content that AI models prefer to cite.',
        priority: 'High',
        relatedMetric: 'Brand Visibility',
        icon: Icons.edit_calendar,
      ),
      ImprovementSuggestion(
        title: 'Optimize for ChatGPT citation patterns',
        description:
            'Structure your articles with clear Q&A sections, concise summaries, and factual data points. ChatGPT tends to cite well-structured, authoritative content.',
        priority: 'High',
        relatedMetric: 'Brand Mentions',
        icon: Icons.psychology,
      ),
      ImprovementSuggestion(
        title: 'Focus on Gemini-specific content structure',
        description:
            'Google Gemini favors content with strong E-E-A-T signals. Add author bios, expert quotes, and primary research data to boost Gemini mentions.',
        priority: 'Medium',
        relatedMetric: 'Brand Visibility',
        icon: Icons.auto_awesome,
      ),
      ImprovementSuggestion(
        title: 'Improve sentiment through engagement',
        description:
            'Address negative mention patterns by responding to criticism constructively and publishing counter-narrative content with positive case studies.',
        priority: 'Medium',
        relatedMetric: 'Sentiment',
        icon: Icons.sentiment_satisfied_alt,
      ),
      ImprovementSuggestion(
        title: 'Expand to Perplexity and Copilot engines',
        description:
            'Your brand presence on Perplexity and Copilot is below average. Create developer-focused and research-oriented content to improve coverage on these platforms.',
        priority: 'Low',
        relatedMetric: 'Share of Voice',
        icon: Icons.expand,
      ),
    ];
  }

  static WeeklyReport getWeeklyReport() {
    final trendData = getAllTrendData();
    return WeeklyReport(
      weekLabel: 'Week 13, 2026',
      startDate: DateTime(2026, 3, 24),
      endDate: DateTime(2026, 3, 30),
      trendData: trendData,
      comparisons: getPerformanceComparisons(),
      suggestions: getImprovementSuggestions(),
      overallHealthScore: 42.5,
    );
  }
}
