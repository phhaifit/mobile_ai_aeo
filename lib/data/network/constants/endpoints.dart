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

  // ─── Feature 6: Cronjob Automation / Content Agent endpoints ─────────────

  static String contentAgents(String projectId) =>
      '/api/projects/$projectId/content-agents';

  static String contentAgentExecutions(String projectId) =>
      '/api/projects/$projectId/content-agents/executions';

  static String updateContentAgent(String agentId) =>
      '/api/content-agents/$agentId';

  static String contentProfiles(String projectId) =>
      '/api/projects/$projectId/content-profiles';
  // Performance monitoring endpoints (geo-brand-visibility-be)
  static String metricsOverview(String projectId) =>
      '/api/projects/$projectId/metrics/overview';
  static String metricsAnalytics(String projectId) =>
      '/api/projects/$projectId/metrics/analytics';
  static String gaTrend(String projectId) =>
      '/api/ga/analytics/$projectId/trend';

  // ─── Google Search Console (GSC) endpoints ───────────────────────────────
  static const String gscConnect = '/api/gsc/connect';
  static const String gscLink = '/api/gsc/link';
  static String gscLinkedSite(String projectId) => '/api/gsc/link/$projectId';
  static String gscStatus(String projectId) => '/api/gsc/status/$projectId';
  static String gscSites(String projectId) => '/api/gsc/sites/$projectId';
  static String gscDisconnect(String projectId) =>
      '/api/gsc/disconnect/$projectId';
  static String gscTrend(String projectId) =>
      '/api/gsc/analytics/$projectId/trend';
  static String triggerAnalysis(String projectId) =>
      '/api/projects/$projectId/test-analyze';
  static const String projectsMe = '/api/projects/me';
  static const String projectsList = '/api/projects';

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
}
