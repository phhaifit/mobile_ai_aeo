import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:dio/dio.dart';

/// API client for the performance monitoring endpoints on the backend.
class PerformanceApi {
  final DioClient _dioClient;

  PerformanceApi(this._dioClient);

  /// Fetches aggregated metrics overview for a project within [start]..[end].
  /// Returns the raw JSON map matching `MetricsOverviewDto`.
  Future<Map<String, dynamic>> getMetricsOverview(
    String projectId, {
    required String start,
    required String end,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.metricsOverview(projectId),
      queryParameters: {'start': start, 'end': end},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Fetches daily analytics breakdown for a project.
  /// Returns the raw JSON map matching `MetricsAnalyticsDto`.
  Future<Map<String, dynamic>> getMetricsAnalytics(
    String projectId, {
    required String start,
    required String end,
    String? granularity,
  }) async {
    final params = <String, dynamic>{'start': start, 'end': end};
    if (granularity != null) params['granularity'] = granularity;

    final res = await _dioClient.dio.get(
      Endpoints.metricsAnalytics(projectId),
      queryParameters: params,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Fetches Google Analytics daily trend data.
  /// Returns a list of `{ date, sessions, totalUsers, engagementRate }`.
  Future<List<Map<String, dynamic>>> getGaTrend(
    String projectId, {
    required String startDate,
    required String endDate,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.gaTrend(projectId),
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    final list = res.data as List<dynamic>;
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Fetches Google Search Console daily trend data.
  /// Returns a list of `{ date, clicks, impressions, ctr, position }`.
  Future<List<Map<String, dynamic>>> getGscTrend(
    String projectId, {
    required String startDate,
    required String endDate,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.gscTrend(projectId),
      queryParameters: {'startDate': startDate, 'endDate': endDate},
    );
    final list = res.data as List<dynamic>;
    return list
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Triggers an on-demand analysis run on the backend.
  Future<void> triggerAnalysis(String projectId) async {
    await _dioClient.dio.post(Endpoints.triggerAnalysis(projectId));
  }

  /// Fetches the user's projects to resolve a projectId.
  /// Tries ACTIVE projects first, then /me, then all.
  Future<String?> resolveProjectId() async {
    // 1. Try active projects
    try {
      final res = await _dioClient.dio.get(
        Endpoints.projectsList,
        queryParameters: {'status': 'ACTIVE'},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      final id = _extractFirstProjectId(res.data);
      if (id != null) return id;
    } catch (_) {}

    // 2. Try /me
    try {
      final res = await _dioClient.dio.get(
        Endpoints.projectsMe,
        options: Options(headers: {'Accept': 'application/json'}),
      );
      final id = _extractFirstProjectId(res.data);
      if (id != null) return id;
    } catch (_) {}

    // 3. Try all projects
    try {
      final res = await _dioClient.dio.get(
        Endpoints.projectsList,
        options: Options(headers: {'Accept': 'application/json'}),
      );
      return _extractFirstProjectId(res.data);
    } catch (_) {}

    return null;
  }

  String? _extractFirstProjectId(dynamic payload) {
    if (payload is! List) return null;
    for (final raw in payload.whereType<Map>()) {
      final json = Map<String, dynamic>.from(raw);
      final id = (json['id'] ?? '').toString().trim();
      if (id.isNotEmpty) return id;
    }
    return null;
  }
}
