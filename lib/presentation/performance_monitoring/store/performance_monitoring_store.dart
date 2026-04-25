import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';
import '../../../domain/entity/trend/trend_data_point.dart';
import '../../../domain/entity/trend/trend_period.dart';
import '../../../domain/entity/trend/performance_comparison.dart';
import '../../../domain/entity/trend/improvement_suggestion.dart';
import '../../../domain/entity/trend/weekly_report.dart';
import '../../../domain/usecase/trend/get_weekly_report_usecase.dart';
import '../../../domain/usecase/trend/get_trend_data_usecase.dart';
import '../../../domain/usecase/trend/get_performance_comparisons_usecase.dart';
import '../../../domain/usecase/trend/get_improvement_suggestions_usecase.dart';
import '../../../domain/usecase/trend/trigger_analysis_usecase.dart';

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
  final TriggerAnalysisUseCase triggerAnalysisUseCase;
  final SharedPreferenceHelper preferenceHelper;
  final PerformanceApi performanceApi;

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

  @observable
  bool isRefreshing = false;

  @observable
  String? projectId;

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
    this.triggerAnalysisUseCase,
    this.preferenceHelper,
    this.performanceApi,
  );

  // ─── Project ID Resolution ──────────────────────────────────────────────
  Future<String> _resolveProjectId() async {
    // Return cached projectId if available
    if (projectId != null && projectId!.isNotEmpty) {
      return projectId!;
    }

    // Try SharedPreferences
    final savedId = (await preferenceHelper.currentProjectId)?.trim();
    if (savedId != null && savedId.isNotEmpty) {
      projectId = savedId;
      return savedId;
    }

    // Fetch from backend
    final fetchedId = await performanceApi.resolveProjectId();
    if (fetchedId == null || fetchedId.isEmpty) {
      throw Exception('No accessible project found for current user.');
    }

    await preferenceHelper.saveCurrentProjectId(fetchedId);
    projectId = fetchedId;
    return fetchedId;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────
  @action
  Future<void> loadAllData() async {
    isLoading = true;
    try {
      final pid = await _resolveProjectId();

      final report = await getWeeklyReportUseCase.call(pid);
      weeklyReport = report;
      trendData = report.trendData;
      comparisons = report.comparisons;
      suggestions = report.suggestions;

      // Apply period filter
      final filteredData = await getTrendDataUseCase.call(pid, selectedPeriod);
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
      final pid = await _resolveProjectId();
      final filteredData = await getTrendDataUseCase.call(pid, period);
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

  @action
  Future<void> refreshData() async {
    isRefreshing = true;
    try {
      final pid = await _resolveProjectId();

      // Trigger analysis on the backend
      await triggerAnalysisUseCase.call(pid);

      // Reload all data
      await loadAllData();
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to refresh data: ${error.toString()}');
    } finally {
      isRefreshing = false;
    }
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────
  @action
  void dispose() {}
}
