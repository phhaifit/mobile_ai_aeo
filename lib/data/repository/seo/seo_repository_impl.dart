import 'dart:async';

import 'package:boilerplate/data/local/datasources/seo/seo_audit_datasource.dart';
import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';
import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/repository/seo/seo_repository.dart';

class SeoRepositoryImpl implements SeoRepository {
  final SeoApi _seoApi;
  final SeoAuditDataSource _dataSource;

  SeoRepositoryImpl(this._seoApi, this._dataSource);

  @override
  Future<String> startAudit(SeoAuditRequest request) {
    return _seoApi.startAudit(request);
  }

  @override
  Future<SeoAuditResult> getAuditResult(String auditId) async {
    final result = await _seoApi.getAuditResult(auditId);
    if (result.status == AuditStatus.completed) {
      await _dataSource.insert(result);
    }
    return result;
  }

  @override
  Future<List<SeoAuditResult>> getAuditHistory() {
    return _dataSource.getAll();
  }

  @override
  Future<void> saveAuditResult(SeoAuditResult result) {
    return _dataSource.insert(result);
  }

  @override
  Future<List<CrawlerEvent>> getCrawlerEvents(String url) {
    return _seoApi.getCrawlerEvents(url);
  }
}
