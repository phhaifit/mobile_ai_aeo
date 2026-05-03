import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/analytics/analytics_metrics.dart';
import 'package:boilerplate/domain/usecase/analytics/get_analytics_metrics_usecase.dart';

part 'analytic_store.g.dart';

class AnalyticStore = _AnalyticStore with _$AnalyticStore;

abstract class _AnalyticStore with Store {
  final String TAG = "_AnalyticStore";

  // store for handling errors
  final ErrorStore errorStore;

  // use cases
  final GetAnalyticsMetricsUseCase _getAnalyticsMetricsUseCase;

  // store variables: sentiment data-----------------------------------------
  @observable
  int sentimentPositiveCount = 0;

  @observable
  double sentimentPositivePercent = 0.0;

  @observable
  int sentimentNeutralCount = 0;

  @observable
  double sentimentNeutralPercent = 0.0;

  @observable
  int sentimentNegativeCount = 0;

  @observable
  double sentimentNegativePercent = 0.0;

  // store variables: share of voice data------------------------------------
  @observable
  List<LLMShareData> llmShareData = [];

  // store variables: general-----------------------------------------------
  @observable
  bool isLoading = false;

  // constructor:---------------------------------------------------------------
  _AnalyticStore(this.errorStore, this._getAnalyticsMetricsUseCase);

  // actions:-------------------------------------------------------------------
  @action
  Future<void> fetchAnalyticsMetrics(String projectId) async {
    isLoading = true;
    errorStore.reset('');
    try {
      // Get current date-time in ISO 8601 format
      final now = DateTime.now();
      final dateTime = now.toIso8601String();

      final params = GetAnalyticsMetricsParams(
        projectId: projectId,
        startDate: dateTime,
        endDate: dateTime,
      );

      print(
          '$TAG.fetchAnalyticsMetrics: projectId=$projectId, startDate=$dateTime, endDate=$dateTime');

      final metrics = await _getAnalyticsMetricsUseCase(params: params);

      final filled = applyAnalyticsMetricsFallbacks(metrics);
      if (isEffectivelyEmptyAnalytics(metrics)) {
        print('$TAG: Empty analytics payload; using display fallback');
      }

      _applyAnalyticsMetrics(filled);

      errorStore.setErrorMessage('');
      isLoading = false;
    } catch (e) {
      print('$TAG.fetchAnalyticsMetrics error: $e');
      print('$TAG: API failed, loading fallback mock data...');
      // Load mock data on error
      _loadMockData();
      errorStore.setErrorMessage('');
      isLoading = false;
    }
  }

  // helper methods
  @action
  void _loadMockData() {
    print('$TAG: Loading mock analytics data...');
    _applyAnalyticsMetrics(mockAnalyticsMetricsForDisplay());
    print(
        '$TAG: Mock data loaded - Sentiment: ${sentimentPositiveCount} positive, '
        '${sentimentNeutralCount} neutral, ${sentimentNegativeCount} negative');
  }

  @action
  void _applyAnalyticsMetrics(AnalyticsMetrics metrics) {
    _mapSentimentData(metrics.sentimentStats);
    _mapShareOfVoiceData(metrics.analyticsByModel);
  }

  void _mapSentimentData(SentimentStats sentimentStats) {
    sentimentPositiveCount = sentimentStats.positive;
    sentimentNeutralCount = sentimentStats.neutral;
    sentimentNegativeCount = sentimentStats.negative;

    // Calculate percentages
    sentimentPositivePercent = sentimentStats.positivePercent;
    sentimentNeutralPercent = sentimentStats.neutralPercent;
    sentimentNegativePercent = sentimentStats.negativePercent;
  }

  void _mapShareOfVoiceData(List<AnalyticsByModel> analyticsByModel) {
    // Convert to LLMShareData
    llmShareData = analyticsByModel.map((model) {
      return LLMShareData(
        llmName: model.model,
        totalMentions: model.totalMentions,
        brandMentions: model.brandMentions,
        competitorMentions: model.competitorMentions,
      );
    }).toList();
  }
}

/// Helper class for LLM share data
class LLMShareData {
  final String llmName;
  final int totalMentions;
  final int brandMentions;
  final Map<String, int> competitorMentions;

  LLMShareData({
    required this.llmName,
    required this.totalMentions,
    required this.brandMentions,
    required this.competitorMentions,
  });

  int get totalCompetitors =>
      competitorMentions.values.fold(0, (a, b) => a + b);

  double get brandMentionPercent => (brandMentions + totalCompetitors) > 0
      ? (brandMentions / (brandMentions + totalCompetitors)) * 100
      : 0.0;

  double get competitorAvgMentions => competitorMentions.isNotEmpty
      ? totalCompetitors / competitorMentions.length
      : 0.0;
}
