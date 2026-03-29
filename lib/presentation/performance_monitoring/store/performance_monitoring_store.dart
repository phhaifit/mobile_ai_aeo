import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import '../../../domain/entity/trend/trend_data_point.dart';
import '../../../domain/entity/trend/trend_period.dart';
import '../../../domain/entity/trend/performance_comparison.dart';
import '../../../domain/entity/trend/improvement_suggestion.dart';
import '../../../domain/entity/trend/weekly_report.dart';
import '../../../domain/usecase/trend/get_weekly_report_usecase.dart';
import '../../../domain/usecase/trend/get_trend_data_usecase.dart';
import '../../../domain/usecase/trend/get_performance_comparisons_usecase.dart';
import '../../../domain/usecase/trend/get_improvement_suggestions_usecase.dart';

part 'performance_monitoring_store.g.dart';

class PerformanceMonitoringStore = _PerformanceMonitoringStore
    with _$PerformanceMonitoringStore;

abstract class _PerformanceMonitoringStore with Store {
  final String TAG = "_PerformanceMonitoringStore";

  final ErrorStore errorStore;
  final GetWeeklyReportUseCase getWeeklyReportUseCase;
  final GetTrendDataUseCase getTrendDataUseCase;
  final GetPerformanceComparisonsUseCase getPerformanceComparisonsUseCase;
  final GetImprovementSuggestionsUseCase getImprovementSuggestionsUseCase;

  // ─── Observables ─────────────────────────────────────────────────────────
  @observable
  WeeklyReport? weeklyReport;

  @observable
  List<TrendDataPoint> trendData = [];

  @observable
  List<PerformanceComparison> comparisons = [];

  @observable
  List<ImprovementSuggestion> suggestions = [];

  @observable
  TrendPeriod selectedPeriod = TrendPeriod.last4Weeks;

  @observable
  String selectedMetric = 'overallScore';

  @observable
  bool isLoading = false;

  // ─── Computed ────────────────────────────────────────────────────────────
  @computed
  double get averageScore {
    if (trendData.isEmpty) return 0.0;
    final sum = trendData.fold<double>(0.0, (prev, e) => prev + e.overallScore);
    return sum / trendData.length;
  }

  @computed
  bool get isImproving {
    if (trendData.length < 2) return false;
    return trendData.last.overallScore > trendData.first.overallScore;
  }

  @computed
  String get trendDirection {
    if (trendData.length < 2) return 'Stable';
    final diff = trendData.last.overallScore - trendData.first.overallScore;
    if (diff > 1.0) return 'Improving';
    if (diff < -1.0) return 'Declining';
    return 'Stable';
  }

  @computed
  List<double> get chartValues {
    switch (selectedMetric) {
      case 'overallScore':
        return trendData.map((e) => e.overallScore).toList();
      case 'brandVisibility':
        return trendData.map((e) => e.brandVisibility).toList();
      case 'brandMentions':
        return trendData.map((e) => e.brandMentions.toDouble()).toList();
      case 'sentimentPositive':
        return trendData.map((e) => e.sentimentPositive).toList();
      case 'linkVisibility':
        return trendData.map((e) => e.linkVisibility).toList();
      default:
        return trendData.map((e) => e.overallScore).toList();
    }
  }

  @computed
  List<String> get chartLabels {
    return trendData.map((e) => e.weekLabel).toList();
  }

  // ─── Constructor ─────────────────────────────────────────────────────────
  _PerformanceMonitoringStore(
    this.errorStore,
    this.getWeeklyReportUseCase,
    this.getTrendDataUseCase,
    this.getPerformanceComparisonsUseCase,
    this.getImprovementSuggestionsUseCase,
  );

  // ─── Actions ─────────────────────────────────────────────────────────────
  @action
  Future<void> loadAllData() async {
    isLoading = true;
    try {
      final report = await getWeeklyReportUseCase.call();
      weeklyReport = report;
      trendData = report.trendData;
      comparisons = report.comparisons;
      suggestions = report.suggestions;

      // Apply period filter
      final filteredData = await getTrendDataUseCase.call(selectedPeriod);
      trendData = filteredData;

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to load performance data: ${error.toString()}');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> selectPeriod(TrendPeriod period) async {
    selectedPeriod = period;
    try {
      final filteredData = await getTrendDataUseCase.call(period);
      trendData = filteredData;
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to load trend data: ${error.toString()}');
    }
  }

  @action
  void selectMetric(String metric) {
    selectedMetric = metric;
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────
  @action
  void dispose() {}
}
