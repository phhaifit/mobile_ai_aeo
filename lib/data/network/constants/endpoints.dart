/// API endpoint constants.
/// Base URLs are injected from EnvironmentConfig via DI.
class Endpoints {
  Endpoints._();

  // base url (default fallback, overridden by EnvironmentConfig)
  static const String baseUrl = "https://api.aeo.how";

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

  // overview metrics endpoints
  static String getOverviewMetrics(String projectId) =>
      "/api/projects/$projectId/metrics/overview";

  // analytics metrics endpoints
  static String getAnalyticsMetrics(String projectId) =>
      "/api/projects/$projectId/metrics/analytics";

  // content profiles endpoints
  static String getContentProfiles(String projectId) =>
      "/api/projects/$projectId/content-profiles";

  // prompts & content generation
  static const String promptsByProject = "/api/prompts/by-project";

  static String promptContentGenerations(String promptId) =>
      "/api/prompts/$promptId/content-generations";

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

  // ─── Brand Setup & Configuration endpoints ─────────────────────────────

  // Brand Profile endpoints
  static String brandProfile(String projectId) =>
      '/api/projects/$projectId/brand-profile';
  static String updateBrandProfile(String projectId) =>
      '/api/projects/$projectId/brand-profile';
  static String getBrandProfile(String projectId) =>
      '/api/projects/$projectId/brand-profile';

  // Knowledge Base endpoints
  static String knowledgeBaseEntries(String projectId) =>
      '/api/projects/$projectId/knowledge-base';
  static String knowledgeBaseEntry(String projectId, String entryId) =>
      '/api/projects/$projectId/knowledge-base/$entryId';

  // URL Link Management endpoints
  static String urlLinks(String projectId) =>
      '/api/projects/$projectId/url-links';
  static String urlLink(String projectId, String linkId) =>
      '/api/projects/$projectId/url-links/$linkId';

  // URL Rewrite Configuration endpoints
  static String urlRewrites(String projectId) =>
      '/api/projects/$projectId/url-rewrites';
  static String urlRewrite(String projectId, String rewriteId) =>
      '/api/projects/$projectId/url-rewrites/$rewriteId';

  // LLM Monitoring endpoints
  static String llmMonitoring(String projectId) =>
      '/api/projects/$projectId/llm-monitoring';
  static String llmMonitoringToggle(String projectId, String llmId) =>
      '/api/projects/$projectId/llm-monitoring/$llmId/toggle';
  static String llmPollingFrequency(String projectId) =>
      '/api/projects/$projectId/llm-polling-frequency';

  // Brand Positioning endpoints
  static String brandPositioning(String projectId) =>
      '/api/projects/$projectId/brand-positioning';

  // Project Management endpoints
  static const String projects = '/api/projects';
  static String project(String projectId) => '/api/projects/$projectId';
  static String switchProject(String projectId) =>
      '/api/projects/$projectId/switch';
  static String deleteProject(String projectId) => '/api/projects/$projectId';
}
