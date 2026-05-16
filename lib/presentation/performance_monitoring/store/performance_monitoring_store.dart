import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';
import '../../../domain/entity/trend/brand_analytics.dart';
import '../../../domain/entity/trend/content_performance_data.dart';
import '../../../domain/entity/trend/content_item.dart';
import '../../../domain/entity/trend/chart_data_point.dart';
import '../../../domain/usecase/trend/get_brand_analytics_usecase.dart';
import '../../../domain/usecase/trend/get_content_performance_usecase.dart';

part 'performance_monitoring_store.g.dart';

class PerformanceMonitoringStore = _PerformanceMonitoringStore
    with _$PerformanceMonitoringStore;

abstract class _PerformanceMonitoringStore with Store {
  final ErrorStore errorStore;
  final GetBrandAnalyticsUseCase getBrandAnalyticsUseCase;
  final GetContentPerformanceUseCase getContentPerformanceUseCase;
  final SharedPreferenceHelper preferenceHelper;
  final PerformanceApi performanceApi;

  // ─── Observables ─────────────────────────────────────────────────────────

  @observable
  String selectedRange = '30D'; // '7D','30D','3M','6M','1Y','custom'

  @observable
  DateTime? customStart;

  @observable
  DateTime? customEnd;

  @observable
  BrandAnalytics? brandAnalytics;

  @observable
  ContentPerformanceData? contentData;

  @observable
  String selectedBrandMetric = 'brandMentions';

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingContent = false;

  @observable
  bool isRefreshing = false;

  @observable
  String? projectId;

  // ─── Computed: Date Range ────────────────────────────────────────────────

  @computed
  DateTime get rangeStart {
    if (selectedRange == 'custom' && customStart != null) {
      return DateTime(customStart!.year, customStart!.month, customStart!.day, 23, 59, 59);
    }
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    switch (selectedRange) {
      case '7D':
        return end.subtract(const Duration(days: 7));
      case '30D':
        return end.subtract(const Duration(days: 30));
      case '3M':
        return end.subtract(const Duration(days: 90));
      case '6M':
        return end.subtract(const Duration(days: 180));
      case '1Y':
        return end.subtract(const Duration(days: 365));
      default:
        return end.subtract(const Duration(days: 30));
    }
  }

  @computed
  DateTime get rangeEnd {
    if (selectedRange == 'custom' && customEnd != null) {
      return DateTime(customEnd!.year, customEnd!.month, customEnd!.day, 23, 59, 59);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @computed
  String get dateRangeLabel {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final s = rangeStart;
    final e = rangeEnd;
    return '${months[s.month - 1]} ${s.day} – ${months[e.month - 1]} ${e.day}, ${e.year}';
  }

  // ─── Computed: Brand Chart Data ──────────────────────────────────────────

  @computed
  List<ChartDataPoint> get brandChartData {
    final daily = brandAnalytics?.analyticsByDate ?? [];
    if (daily.isEmpty) return [];

    // Filter to date range
    final filtered = daily.where((d) {
      return !d.date.isBefore(rangeStart) && !d.date.isAfter(rangeEnd);
    }).toList();

    return _groupDailyData(filtered, selectedBrandMetric);
  }

  @computed
  List<ChartDataPoint> get brandMentionsChartData {
    final daily = brandAnalytics?.analyticsByDate ?? [];
    if (daily.isEmpty) return [];
    final filtered = daily.where((d) =>
        !d.date.isBefore(rangeStart) && !d.date.isAfter(rangeEnd)).toList();
    return _groupDailyData(filtered, 'brandMentions');
  }

  @computed
  List<ChartDataPoint> get linkRefsChartData {
    final daily = brandAnalytics?.analyticsByDate ?? [];
    if (daily.isEmpty) return [];
    final filtered = daily.where((d) =>
        !d.date.isBefore(rangeStart) && !d.date.isAfter(rangeEnd)).toList();
    return _groupDailyData(filtered, 'linkReferences');
  }

  @computed
  List<ChartDataPoint> get responsesChartData {
    final daily = brandAnalytics?.analyticsByDate ?? [];
    if (daily.isEmpty) return [];
    final filtered = daily.where((d) =>
        !d.date.isBefore(rangeStart) && !d.date.isAfter(rangeEnd)).toList();
    return _groupDailyData(filtered, 'totalResponses');
  }

  // ─── Computed: Content Chart Data ────────────────────────────────────────

  @computed
  List<ContentItem> get allContentItems => contentData?.items ?? [];

  @computed
  int get totalContent {
    final filteredItems = allContentItems.where((c) {
      final date = c.publishedAt ?? c.createdAt;
      return !date.isBefore(rangeStart) && !date.isAfter(rangeEnd);
    });
    return filteredItems.length;
  }

  @computed
  int get publishedCount {
    final filteredItems = allContentItems.where((c) {
      final date = c.publishedAt ?? c.createdAt;
      return !date.isBefore(rangeStart) && !date.isAfter(rangeEnd);
    });
    return filteredItems.where((c) => c.completionStatus == 'PUBLISHED').length;
  }

  @computed
  int get draftCount {
    final filteredItems = allContentItems.where((c) {
      final date = c.publishedAt ?? c.createdAt;
      return !date.isBefore(rangeStart) && !date.isAfter(rangeEnd);
    });
    return filteredItems.where((c) => c.completionStatus != 'PUBLISHED').length;
  }

  @computed
  List<ChartDataPoint> get contentPublishTrend {
    final items = allContentItems.where((c) {
      final date = c.publishedAt ?? c.createdAt;
      return !date.isBefore(rangeStart) && !date.isAfter(rangeEnd);
    }).toList();

    // Group by date bucket
    final bucketSize = _bucketSizeForRange();
    final buckets = _initializeEmptyBuckets(bucketSize);

    for (final item in items) {
      final date = item.publishedAt ?? item.createdAt;
      final key = _bucketKey(date, bucketSize);
      buckets.putIfAbsent(key, () => _BucketAccum(key, date));
      buckets[key]!.count++;
    }

    final sorted = buckets.values.toList()
      ..sort((a, b) => a.bucketStart.compareTo(b.bucketStart));

    return sorted
        .map((b) => ChartDataPoint(
              label: b.label,
              value: b.count.toDouble(),
              bucketStart: b.bucketStart,
            ))
        .toList();
  }

  @computed
  Map<String, int> get contentByTopic {
    final map = <String, int>{};
    final filteredItems = allContentItems.where((c) {
      final date = c.publishedAt ?? c.createdAt;
      return !date.isBefore(rangeStart) && !date.isAfter(rangeEnd);
    });
    for (final item in filteredItems) {
      final topic = item.topicName ?? 'Uncategorized';
      map[topic] = (map[topic] ?? 0) + 1;
    }
    return map;
  }

  @computed
  Map<String, int> get contentByType {
    final map = <String, int>{};
    for (final item in allContentItems) {
      final type = item.contentType;
      map[type] = (map[type] ?? 0) + 1;
    }
    return map;
  }

  // ─── Date Grouping Logic ────────────────────────────────────────────────

  String _bucketSizeForRange() {
    final days = rangeEnd.difference(rangeStart).inDays;
    if (days <= 31) return 'day';
    return 'month';
  }

  Map<String, _BucketAccum> _initializeEmptyBuckets(String bucketSize) {
    final buckets = <String, _BucketAccum>{};
    DateTime current = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 23, 59, 59);

    while (!current.isAfter(end)) {
      final key = _bucketKey(current, bucketSize);
      if (!buckets.containsKey(key)) {
        buckets[key] = _BucketAccum(key, current);
      }
      if (bucketSize == 'day') {
        current = current.add(const Duration(days: 1));
      } else { // month
        current = DateTime(current.year, current.month + 1, 1);
      }
    }
    return buckets;
  }

  String _bucketKey(DateTime date, String bucketSize) {
    switch (bucketSize) {
      case 'day':
        return DateFormat('yyyy-MM-dd').format(date);
      case 'week':
        // ISO week: find Monday of this week
        final weekday = date.weekday; // 1=Mon
        final monday = date.subtract(Duration(days: weekday - 1));
        return DateFormat('yyyy-MM-dd').format(monday);
      case 'month':
        return DateFormat('yyyy-MM').format(date);
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  String _bucketLabel(String key, String bucketSize) {
    switch (bucketSize) {
      case 'day':
        final d = DateTime.tryParse(key);
        return d != null ? DateFormat('MMM d').format(d) : key;
      case 'week':
        final d = DateTime.tryParse(key);
        return d != null ? 'W${_isoWeekNumber(d)}' : key;
      case 'month':
        final parts = key.split('-');
        if (parts.length == 2) {
          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
          final m = int.tryParse(parts[1]) ?? 1;
          return '${months[m - 1]} ${parts[0]}';
        }
        return key;
      default:
        return key;
    }
  }

  int _isoWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + jan4.weekday + 6) ~/ 7);
  }

  List<ChartDataPoint> _groupDailyData(
      List<DailyAnalytics> daily, String metric) {
    final bucketSize = _bucketSizeForRange();
    final buckets = _initializeEmptyBuckets(bucketSize);

    for (final d in daily) {
      final key = _bucketKey(d.date, bucketSize);
      buckets.putIfAbsent(key, () => _BucketAccum(key, d.date));
      final b = buckets[key]!;

      switch (metric) {
        case 'brandMentions':
          b.sum += d.brandMentions;
          break;
        case 'linkReferences':
          b.sum += d.linkReferences;
          break;
        case 'totalResponses':
          b.sum += d.totalResponses;
          break;
        default:
          b.sum += d.brandMentions;
      }
      b.count++;
    }

    final sorted = buckets.values.toList()
      ..sort((a, b) => a.bucketStart.compareTo(b.bucketStart));

    return sorted
        .map((b) => ChartDataPoint(
              label: _bucketLabel(b.key, bucketSize),
              value: b.sum.toDouble(),
              bucketStart: b.bucketStart,
            ))
        .toList();
  }

  // ─── Constructor ─────────────────────────────────────────────────────────

  _PerformanceMonitoringStore(
    this.errorStore,
    this.getBrandAnalyticsUseCase,
    this.getContentPerformanceUseCase,
    this.preferenceHelper,
    this.performanceApi,
  );

  // ─── Project ID Resolution ──────────────────────────────────────────────

  Future<String> _resolveProjectId() async {
    if (projectId != null && projectId!.isNotEmpty) return projectId!;

    final savedId = (await preferenceHelper.currentProjectId)?.trim();
    if (savedId != null && savedId.isNotEmpty) {
      projectId = savedId;
      return savedId;
    }

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

      // Load brand and content in parallel
      final results = await Future.wait([
        getBrandAnalyticsUseCase.call(
          pid,
          startDate: rangeStart,
          endDate: rangeEnd,
        ),
        getContentPerformanceUseCase.call(pid, limit: 100),
      ]);

      brandAnalytics = results[0] as BrandAnalytics;
      contentData = results[1] as ContentPerformanceData;

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to load performance data: ${error.toString()}');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refreshData() async {
    isRefreshing = true;
    try {
      await loadAllData();
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to refresh data: ${error.toString()}');
    } finally {
      isRefreshing = false;
    }
  }

  @action
  Future<void> selectRange(String range, {DateTime? start, DateTime? end}) async {
    selectedRange = range;
    if (range == 'custom') {
      if (start != null) customStart = start;
      if (end != null) customEnd = end;
    }
    // Reload brand data with new range (content is not date-filtered at API level)
    isLoading = true;
    try {
      final pid = await _resolveProjectId();
      brandAnalytics = await getBrandAnalyticsUseCase.call(
        pid,
        startDate: rangeStart,
        endDate: rangeEnd,
      );
      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(
          'Failed to load brand data: ${error.toString()}');
    } finally {
      isLoading = false;
    }
  }

  @action
  void selectBrandMetric(String metric) {
    selectedBrandMetric = metric;
  }

  @action
  void dispose() {}
}

// ─── Helper class for bucket accumulation ──────────────────────────────────

class _BucketAccum {
  final String key;
  final DateTime bucketStart;
  int count = 0;
  int sum = 0;
  String get label => key;

  _BucketAccum(this.key, this.bucketStart);
}
