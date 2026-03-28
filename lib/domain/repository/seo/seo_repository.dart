import 'package:boilerplate/domain/entity/seo/crawler_event.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_request.dart';
import 'package:boilerplate/domain/entity/seo/seo_audit_result.dart';

abstract class SeoRepository {
  Future<String> startAudit(SeoAuditRequest request);
  Future<SeoAuditResult> getAuditResult(String auditId);
  Future<List<SeoAuditResult>> getAuditHistory();
  Future<void> saveAuditResult(SeoAuditResult result);
  Future<List<CrawlerEvent>> getCrawlerEvents(String url);
}
