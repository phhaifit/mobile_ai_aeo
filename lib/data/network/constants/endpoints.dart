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

  // content enhancement endpoints (AI service)
  static const String contentBase = "/api/v1/content";
  static String contentOperation(String op) => "$contentBase/$op";

  // SEO audit endpoints (Technical SEO feature)
  static const String seoAudit = "/api/v1/seo/audit";
  static String seoAuditResult(String id) => "/api/v1/seo/audit/$id";
  static String seoCrawler(String url) =>
      "/api/v1/seo/crawler?url=${Uri.encodeComponent(url)}";

  // Performance monitoring endpoints (geo-brand-visibility-be)
  static String metricsOverview(String projectId) =>
      '/api/projects/$projectId/metrics/overview';
  static String metricsAnalytics(String projectId) =>
      '/api/projects/$projectId/metrics/analytics';
  static String gaTrend(String projectId) =>
      '/api/ga/analytics/$projectId/trend';
  static String gscTrend(String projectId) =>
      '/api/gsc/analytics/$projectId/trend';
  static String triggerAnalysis(String projectId) =>
      '/api/projects/$projectId/test-analyze';
  static const String projectsMe = '/api/projects/me';
  static const String projectsList = '/api/projects';

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

