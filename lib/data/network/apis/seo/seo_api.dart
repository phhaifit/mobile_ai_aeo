import 'dart:async';

import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';

class SeoApi {
  final DioClient _dioClient;

  SeoApi(this._dioClient);

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
}
