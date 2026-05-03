// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_monitoring_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PerformanceMonitoringStore on _PerformanceMonitoringStore, Store {
  Computed<DateTime>? _$rangeStartComputed;

  @override
  DateTime get rangeStart =>
      (_$rangeStartComputed ??= Computed<DateTime>(() => super.rangeStart,
              name: '_PerformanceMonitoringStore.rangeStart'))
          .value;
  Computed<DateTime>? _$rangeEndComputed;

  @override
  DateTime get rangeEnd =>
      (_$rangeEndComputed ??= Computed<DateTime>(() => super.rangeEnd,
              name: '_PerformanceMonitoringStore.rangeEnd'))
          .value;
  Computed<String>? _$dateRangeLabelComputed;

  @override
  String get dateRangeLabel =>
      (_$dateRangeLabelComputed ??= Computed<String>(() => super.dateRangeLabel,
              name: '_PerformanceMonitoringStore.dateRangeLabel'))
          .value;
  Computed<List<ChartDataPoint>>? _$brandChartDataComputed;

  @override
  List<ChartDataPoint> get brandChartData => (_$brandChartDataComputed ??=
          Computed<List<ChartDataPoint>>(() => super.brandChartData,
              name: '_PerformanceMonitoringStore.brandChartData'))
      .value;
  Computed<List<ChartDataPoint>>? _$brandMentionsChartDataComputed;

  @override
  List<ChartDataPoint> get brandMentionsChartData =>
      (_$brandMentionsChartDataComputed ??= Computed<List<ChartDataPoint>>(
              () => super.brandMentionsChartData,
              name: '_PerformanceMonitoringStore.brandMentionsChartData'))
          .value;
  Computed<List<ChartDataPoint>>? _$linkRefsChartDataComputed;

  @override
  List<ChartDataPoint> get linkRefsChartData => (_$linkRefsChartDataComputed ??=
          Computed<List<ChartDataPoint>>(() => super.linkRefsChartData,
              name: '_PerformanceMonitoringStore.linkRefsChartData'))
      .value;
  Computed<List<ChartDataPoint>>? _$responsesChartDataComputed;

  @override
  List<ChartDataPoint> get responsesChartData =>
      (_$responsesChartDataComputed ??= Computed<List<ChartDataPoint>>(
              () => super.responsesChartData,
              name: '_PerformanceMonitoringStore.responsesChartData'))
          .value;
  Computed<List<ContentItem>>? _$allContentItemsComputed;

  @override
  List<ContentItem> get allContentItems => (_$allContentItemsComputed ??=
          Computed<List<ContentItem>>(() => super.allContentItems,
              name: '_PerformanceMonitoringStore.allContentItems'))
      .value;
  Computed<int>? _$totalContentComputed;

  @override
  int get totalContent =>
      (_$totalContentComputed ??= Computed<int>(() => super.totalContent,
              name: '_PerformanceMonitoringStore.totalContent'))
          .value;
  Computed<int>? _$publishedCountComputed;

  @override
  int get publishedCount =>
      (_$publishedCountComputed ??= Computed<int>(() => super.publishedCount,
              name: '_PerformanceMonitoringStore.publishedCount'))
          .value;
  Computed<int>? _$draftCountComputed;

  @override
  int get draftCount =>
      (_$draftCountComputed ??= Computed<int>(() => super.draftCount,
              name: '_PerformanceMonitoringStore.draftCount'))
          .value;
  Computed<List<ChartDataPoint>>? _$contentPublishTrendComputed;

  @override
  List<ChartDataPoint> get contentPublishTrend =>
      (_$contentPublishTrendComputed ??= Computed<List<ChartDataPoint>>(
              () => super.contentPublishTrend,
              name: '_PerformanceMonitoringStore.contentPublishTrend'))
          .value;
  Computed<Map<String, int>>? _$contentByTopicComputed;

  @override
  Map<String, int> get contentByTopic => (_$contentByTopicComputed ??=
          Computed<Map<String, int>>(() => super.contentByTopic,
              name: '_PerformanceMonitoringStore.contentByTopic'))
      .value;
  Computed<Map<String, int>>? _$contentByTypeComputed;

  @override
  Map<String, int> get contentByType => (_$contentByTypeComputed ??=
          Computed<Map<String, int>>(() => super.contentByType,
              name: '_PerformanceMonitoringStore.contentByType'))
      .value;

  late final _$selectedRangeAtom =
      Atom(name: '_PerformanceMonitoringStore.selectedRange', context: context);

  @override
  String get selectedRange {
    _$selectedRangeAtom.reportRead();
    return super.selectedRange;
  }

  @override
  set selectedRange(String value) {
    _$selectedRangeAtom.reportWrite(value, super.selectedRange, () {
      super.selectedRange = value;
    });
  }

  late final _$customStartAtom =
      Atom(name: '_PerformanceMonitoringStore.customStart', context: context);

  @override
  DateTime? get customStart {
    _$customStartAtom.reportRead();
    return super.customStart;
  }

  @override
  set customStart(DateTime? value) {
    _$customStartAtom.reportWrite(value, super.customStart, () {
      super.customStart = value;
    });
  }

  late final _$customEndAtom =
      Atom(name: '_PerformanceMonitoringStore.customEnd', context: context);

  @override
  DateTime? get customEnd {
    _$customEndAtom.reportRead();
    return super.customEnd;
  }

  @override
  set customEnd(DateTime? value) {
    _$customEndAtom.reportWrite(value, super.customEnd, () {
      super.customEnd = value;
    });
  }

  late final _$brandAnalyticsAtom = Atom(
      name: '_PerformanceMonitoringStore.brandAnalytics', context: context);

  @override
  BrandAnalytics? get brandAnalytics {
    _$brandAnalyticsAtom.reportRead();
    return super.brandAnalytics;
  }

  @override
  set brandAnalytics(BrandAnalytics? value) {
    _$brandAnalyticsAtom.reportWrite(value, super.brandAnalytics, () {
      super.brandAnalytics = value;
    });
  }

  late final _$contentDataAtom =
      Atom(name: '_PerformanceMonitoringStore.contentData', context: context);

  @override
  ContentPerformanceData? get contentData {
    _$contentDataAtom.reportRead();
    return super.contentData;
  }

  @override
  set contentData(ContentPerformanceData? value) {
    _$contentDataAtom.reportWrite(value, super.contentData, () {
      super.contentData = value;
    });
  }

  late final _$selectedBrandMetricAtom = Atom(
      name: '_PerformanceMonitoringStore.selectedBrandMetric',
      context: context);

  @override
  String get selectedBrandMetric {
    _$selectedBrandMetricAtom.reportRead();
    return super.selectedBrandMetric;
  }

  @override
  set selectedBrandMetric(String value) {
    _$selectedBrandMetricAtom.reportWrite(value, super.selectedBrandMetric, () {
      super.selectedBrandMetric = value;
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

  late final _$isLoadingContentAtom = Atom(
      name: '_PerformanceMonitoringStore.isLoadingContent', context: context);

  @override
  bool get isLoadingContent {
    _$isLoadingContentAtom.reportRead();
    return super.isLoadingContent;
  }

  @override
  set isLoadingContent(bool value) {
    _$isLoadingContentAtom.reportWrite(value, super.isLoadingContent, () {
      super.isLoadingContent = value;
    });
  }

  late final _$isRefreshingAtom =
      Atom(name: '_PerformanceMonitoringStore.isRefreshing', context: context);

  @override
  bool get isRefreshing {
    _$isRefreshingAtom.reportRead();
    return super.isRefreshing;
  }

  @override
  set isRefreshing(bool value) {
    _$isRefreshingAtom.reportWrite(value, super.isRefreshing, () {
      super.isRefreshing = value;
    });
  }

  late final _$projectIdAtom =
      Atom(name: '_PerformanceMonitoringStore.projectId', context: context);

  @override
  String? get projectId {
    _$projectIdAtom.reportRead();
    return super.projectId;
  }

  @override
  set projectId(String? value) {
    _$projectIdAtom.reportWrite(value, super.projectId, () {
      super.projectId = value;
    });
  }

  late final _$loadAllDataAsyncAction =
      AsyncAction('_PerformanceMonitoringStore.loadAllData', context: context);

  @override
  Future<void> loadAllData() {
    return _$loadAllDataAsyncAction.run(() => super.loadAllData());
  }

  late final _$refreshDataAsyncAction =
      AsyncAction('_PerformanceMonitoringStore.refreshData', context: context);

  @override
  Future<void> refreshData() {
    return _$refreshDataAsyncAction.run(() => super.refreshData());
  }

  late final _$selectRangeAsyncAction =
      AsyncAction('_PerformanceMonitoringStore.selectRange', context: context);

  @override
  Future<void> selectRange(String range, {DateTime? start, DateTime? end}) {
    return _$selectRangeAsyncAction
        .run(() => super.selectRange(range, start: start, end: end));
  }

  late final _$_PerformanceMonitoringStoreActionController =
      ActionController(name: '_PerformanceMonitoringStore', context: context);

  @override
  void selectBrandMetric(String metric) {
    final _$actionInfo = _$_PerformanceMonitoringStoreActionController
        .startAction(name: '_PerformanceMonitoringStore.selectBrandMetric');
    try {
      return super.selectBrandMetric(metric);
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
selectedRange: ${selectedRange},
customStart: ${customStart},
customEnd: ${customEnd},
brandAnalytics: ${brandAnalytics},
contentData: ${contentData},
selectedBrandMetric: ${selectedBrandMetric},
isLoading: ${isLoading},
isLoadingContent: ${isLoadingContent},
isRefreshing: ${isRefreshing},
projectId: ${projectId},
rangeStart: ${rangeStart},
rangeEnd: ${rangeEnd},
dateRangeLabel: ${dateRangeLabel},
brandChartData: ${brandChartData},
brandMentionsChartData: ${brandMentionsChartData},
linkRefsChartData: ${linkRefsChartData},
responsesChartData: ${responsesChartData},
allContentItems: ${allContentItems},
totalContent: ${totalContent},
publishedCount: ${publishedCount},
draftCount: ${draftCount},
contentPublishTrend: ${contentPublishTrend},
contentByTopic: ${contentByTopic},
contentByType: ${contentByType}
    ''';
  }
}
