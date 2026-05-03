import 'dart:async';
import 'dart:convert';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/seo/cluster_job.dart';
import 'package:boilerplate/domain/entity/seo/cluster_plan.dart';
import 'package:boilerplate/domain/entity/seo/content_insight.dart';
import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:http/http.dart' as http;

class SeoApi {
  final DioClient _dioClient;

  SeoApi(this._dioClient);

  // ─── Technical SEO (existing) ──────────────────────────────────────────────

  Future<String> startAudit(SeoAuditRequest request) async {
    final res = await _dioClient.dio.post(
      Endpoints.seoAudit,
      data: request.toMap(),
    );
    final data = res.data as Map<String, dynamic>;
    return (data['audit_id'] ?? data['auditId']) as String;
  }

  Future<SeoAuditResult> getAuditResult(String auditId) async {
    final res = await _dioClient.dio.get(Endpoints.seoAuditResult(auditId));
    return SeoAuditResult.fromMap(res.data as Map<String, dynamic>);
  }

  Future<List<CrawlerEvent>> getCrawlerEvents(String url) async {
    final res = await _dioClient.dio.get(Endpoints.seoCrawler(url));
    final list = res.data as List<dynamic>;
    return list
        .map((e) => CrawlerEvent.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Feature 9: Content Insights (On-page SEO & Content Structure) ─────────

  /// GET /api/contents/:contentId/content-insights
  Future<List<ContentInsight>> getContentInsights(String contentId) async {
    final res = await _dioClient.dio.get(Endpoints.contentInsights(contentId));
    final data = res.data;
    final list = (data is List) ? data : (data['data'] as List<dynamic>? ?? []);
    return list
        .whereType<Map>()
        .map((raw) => ContentInsight.fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  // ─── Feature 9: Topic Clustering ──────────────────────────────────────────

  /// POST /api/projects/:projectId/cluster/generate-plan
  Future<ClusterPlan> generateClusterPlan(
      String projectId, String topic) async {
    final res = await _dioClient.dio.post(
      Endpoints.clusterGeneratePlan(projectId),
      data: {'topic': topic},
    );
    final data = res.data;
    final payload =
        (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return ClusterPlan.fromMap(payload['data'] ?? payload);
  }

  /// POST /api/projects/:projectId/cluster/generate-articles
  /// Returns jobId for SSE polling.
  Future<String> generateClusterArticles(
      String projectId, ClusterPlan plan) async {
    final res = await _dioClient.dio.post(
      Endpoints.clusterGenerateArticles(projectId),
      data: plan.toMap(),
    );
    final data = res.data as Map<String, dynamic>;
    return (data['jobId'] ?? data['job_id'] ?? '').toString();
  }

  /// GET /api/cluster/jobs/:jobId/stream (Server-Sent Events)
  ///
  /// Uses the `http` package for chunked streaming since Dio doesn't
  /// natively support SSE keep-alive connections.
  Stream<ClusterJob> listenToClusterJob(String jobId) async* {
    // Build full URL from the Dio base URL
    final baseUrl = _dioClient.dio.options.baseUrl;
    final uri = Uri.parse('$baseUrl${Endpoints.clusterJobStream(jobId)}');

    // Fetch the auth token from Dio's request options interceptor
    final token =
        _dioClient.dio.options.headers['Authorization']?.toString() ?? '';

    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream'
      ..headers['Cache-Control'] = 'no-cache'
      ..headers['Authorization'] = token;

    final streamedResponse = await http.Client().send(request);

    String buffer = '';
    await for (final chunk
        in streamedResponse.stream.transform(utf8.decoder)) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line

      for (final line in lines) {
        if (line.startsWith('data:')) {
          final raw = line.substring(5).trim();
          if (raw.isEmpty || raw == '[DONE]') continue;
          try {
            final map = jsonDecode(raw) as Map<String, dynamic>;
            yield ClusterJob.fromSseEvent(jobId, map);
          } catch (_) {
            // Ignore malformed SSE lines
          }
        }
      }
    }
  }

  // ─── Feature 9: Content Optimization ──────────────────────────────────────

  /// POST /api/contents/:id/regenerate
  Future<void> regenerateContent(String contentId, String improvement) async {
    await _dioClient.dio.post(
      Endpoints.contentRegenerate(contentId),
      data: {'improvement': improvement},
    );
  }

  // ─── Feature 9: Internal Linking ──────────────────────────────────────────

  /// POST /api/contents/:id/publish
  Future<void> publishContent(String contentId) async {
    await _dioClient.dio.post(Endpoints.contentPublish(contentId));
  }

  /// POST /api/contents/:id/republish
  Future<void> republishContent(String contentId) async {
    await _dioClient.dio.post(Endpoints.contentRepublish(contentId));
  }
}

