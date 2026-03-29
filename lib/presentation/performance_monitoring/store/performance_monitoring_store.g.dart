// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_monitoring_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PerformanceMonitoringStore on _PerformanceMonitoringStore, Store {
  Computed<double>? _$averageScoreComputed;

  @override
  double get averageScore =>
      (_$averageScoreComputed ??= Computed<double>(() => super.averageScore,
              name: '_PerformanceMonitoringStore.averageScore'))
          .value;
  Computed<bool>? _$isImprovingComputed;

  @override
  bool get isImproving =>
      (_$isImprovingComputed ??= Computed<bool>(() => super.isImproving,
              name: '_PerformanceMonitoringStore.isImproving'))
          .value;
  Computed<String>? _$trendDirectionComputed;

  @override
  String get trendDirection =>
      (_$trendDirectionComputed ??= Computed<String>(() => super.trendDirection,
              name: '_PerformanceMonitoringStore.trendDirection'))
          .value;
  Computed<List<double>>? _$chartValuesComputed;

  @override
  List<double> get chartValues =>
      (_$chartValuesComputed ??= Computed<List<double>>(() => super.chartValues,
              name: '_PerformanceMonitoringStore.chartValues'))
          .value;
  Computed<List<String>>? _$chartLabelsComputed;

  @override
  List<String> get chartLabels =>
      (_$chartLabelsComputed ??= Computed<List<String>>(() => super.chartLabels,
              name: '_PerformanceMonitoringStore.chartLabels'))
          .value;

  late final _$weeklyReportAtom =
      Atom(name: '_PerformanceMonitoringStore.weeklyReport', context: context);

  @override
  WeeklyReport? get weeklyReport {
    _$weeklyReportAtom.reportRead();
    return super.weeklyReport;
  }

  @override
  set weeklyReport(WeeklyReport? value) {
    _$weeklyReportAtom.reportWrite(value, super.weeklyReport, () {
      super.weeklyReport = value;
    });
  }

  late final _$trendDataAtom =
      Atom(name: '_PerformanceMonitoringStore.trendData', context: context);

  @override
  List<TrendDataPoint> get trendData {
    _$trendDataAtom.reportRead();
    return super.trendData;
  }

  @override
  set trendData(List<TrendDataPoint> value) {
    _$trendDataAtom.reportWrite(value, super.trendData, () {
      super.trendData = value;
    });
  }

  late final _$comparisonsAtom =
      Atom(name: '_PerformanceMonitoringStore.comparisons', context: context);

  @override
  List<PerformanceComparison> get comparisons {
    _$comparisonsAtom.reportRead();
    return super.comparisons;
  }

  @override
  set comparisons(List<PerformanceComparison> value) {
    _$comparisonsAtom.reportWrite(value, super.comparisons, () {
      super.comparisons = value;
    });
  }

  late final _$suggestionsAtom =
      Atom(name: '_PerformanceMonitoringStore.suggestions', context: context);

  @override
  List<ImprovementSuggestion> get suggestions {
    _$suggestionsAtom.reportRead();
    return super.suggestions;
  }

  @override
  set suggestions(List<ImprovementSuggestion> value) {
    _$suggestionsAtom.reportWrite(value, super.suggestions, () {
      super.suggestions = value;
    });
  }

  late final _$selectedPeriodAtom = Atom(
      name: '_PerformanceMonitoringStore.selectedPeriod', context: context);

  @override
  TrendPeriod get selectedPeriod {
    _$selectedPeriodAtom.reportRead();
    return super.selectedPeriod;
  }

  @override
  set selectedPeriod(TrendPeriod value) {
    _$selectedPeriodAtom.reportWrite(value, super.selectedPeriod, () {
      super.selectedPeriod = value;
    });
  }

  late final _$selectedMetricAtom = Atom(
      name: '_PerformanceMonitoringStore.selectedMetric', context: context);

  @override
  String get selectedMetric {
    _$selectedMetricAtom.reportRead();
    return super.selectedMetric;
  }

  @override
  set selectedMetric(String value) {
    _$selectedMetricAtom.reportWrite(value, super.selectedMetric, () {
      super.selectedMetric = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PerformanceMonitoringStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$loadAllDataAsyncAction =
      AsyncAction('_PerformanceMonitoringStore.loadAllData', context: context);

  @override
  Future<void> loadAllData() {
    return _$loadAllDataAsyncAction.run(() => super.loadAllData());
  }

  late final _$selectPeriodAsyncAction =
      AsyncAction('_PerformanceMonitoringStore.selectPeriod', context: context);

  @override
  Future<void> selectPeriod(TrendPeriod period) {
    return _$selectPeriodAsyncAction.run(() => super.selectPeriod(period));
  }

  late final _$_PerformanceMonitoringStoreActionController =
      ActionController(name: '_PerformanceMonitoringStore', context: context);

  @override
  void selectMetric(String metric) {
    final _$actionInfo = _$_PerformanceMonitoringStoreActionController
        .startAction(name: '_PerformanceMonitoringStore.selectMetric');
    try {
      return super.selectMetric(metric);
    } finally {
      _$_PerformanceMonitoringStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_PerformanceMonitoringStoreActionController
        .startAction(name: '_PerformanceMonitoringStore.dispose');
    try {
      return super.dispose();
    } finally {
      _$_PerformanceMonitoringStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
weeklyReport: ${weeklyReport},
trendData: ${trendData},
comparisons: ${comparisons},
suggestions: ${suggestions},
selectedPeriod: ${selectedPeriod},
selectedMetric: ${selectedMetric},
isLoading: ${isLoading},
averageScore: ${averageScore},
isImproving: ${isImproving},
trendDirection: ${trendDirection},
chartValues: ${chartValues},
chartLabels: ${chartLabels}
    ''';
  }
}
