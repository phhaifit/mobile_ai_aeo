/// API endpoint constants.
/// Base URLs are injected from EnvironmentConfig via DI.
class Endpoints {
  Endpoints._();

  // base url (default fallback, overridden by EnvironmentConfig)
  static const String baseUrl = "http://jsonplaceholder.typicode.com";

  // timeouts
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;

  // AI service timeout (longer for AI processing)
  static const int aiReceiveTimeout = 180000; // 3 min for AI tasks

  // post endpoints
  static const String getPosts = "/posts";

  // content enhancement endpoints — match BE PR
  // GEO-Brand-Visibility/geo-brand-visibility-be#148
  // Reuses the existing regenerate N8N flow: each op operates on an
  // existing content row identified by `id`. Returns { jobId } async;
  // poll `contentByJob` for the regenerated body.
  static const String contentBase = "/api/contents";
  static String contentOperation(String id, String op) =>
      "$contentBase/$id/$op";
  static String contentByJob(String jobId) => "$contentBase/by-job/$jobId";
  static String projectContents(String projectId) =>
      "/api/projects/$projectId/contents";

  // SEO audit endpoints — Phase 1 placeholders, BE not yet built (see issue #46)
  // The Technical SEO feature audit/crawler endpoints below are scaffolds; the
  // active SEO Content Optimization endpoints from PR #52 live further down.
  static const String seoAudit = "/api/v1/seo/audit";
  static String seoAuditResult(String id) => "/api/v1/seo/audit/$id";
  static String seoCrawler(String url) =>
      "/api/v1/seo/crawler?url=${Uri.encodeComponent(url)}";

  // ─── Feature 9: SEO Content Optimization endpoints ───────────────────────

  // On-page SEO Checker & Content Structure
  static String contentInsights(String contentId) =>
      '/api/contents/$contentId/content-insights';

  // Regenerate / optimize content
  static String contentRegenerate(String id) => '/api/contents/$id/regenerate';

  // Publish / republish (triggers auto-internal-linking)
  static String contentPublish(String id) => '/api/contents/$id/publish';
  static String contentRepublish(String id) => '/api/contents/$id/republish';

  // AI Topic Clustering
  static String clusterGeneratePlan(String projectId) =>
      '/api/projects/$projectId/cluster/generate-plan';
  static String clusterGenerateArticles(String projectId) =>
      '/api/projects/$projectId/cluster/generate-articles';
  static String clusterJobStream(String jobId) =>
      '/api/cluster/jobs/$jobId/stream';
}

