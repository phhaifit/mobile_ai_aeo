import 'package:intl/intl.dart';
import 'package:boilerplate/domain/entity/trend/brand_analytics.dart';
import 'package:boilerplate/domain/entity/trend/content_performance_data.dart';
import 'package:boilerplate/domain/repository/trend/trend_repository.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';

class TrendRepositoryImpl implements TrendRepository {
  final PerformanceApi _api;

  TrendRepositoryImpl(this._api);

  @override
  Future<BrandAnalytics> getBrandAnalytics(
    String projectId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final fmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    final data = await _api.getMetricsAnalytics(
      projectId,
      start: fmt.format(startDate.toUtc()),
      end: fmt.format(endDate.toUtc()),
      granularity: 'day',
    );
    return BrandAnalytics.fromJson(data);
  }

  @override
  Future<ContentPerformanceData> getContentPerformance(
    String projectId, {
    int page = 1,
    int limit = 100,
    String sortOrder = 'asc',
  }) async {
    final data = await _api.getProjectContents(
      projectId,
      page: page,
      limit: limit,
      sortOrder: sortOrder,
    );
    return ContentPerformanceData.fromJson(data);
  }

  @override
  Future<String> resolveProjectId() async {
    final id = await _api.resolveProjectId();
    if (id == null || id.isEmpty) {
      throw Exception('No accessible project found for current user.');
    }
    return id;
  }
}
