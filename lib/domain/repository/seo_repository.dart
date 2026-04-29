import '../entity/seo/cluster_plan.dart';
import '../entity/seo/content_insight.dart';
import '../entity/seo/seo_data.dart';

abstract class SeoRepository {
  // ─── Phase 1 (retained for backward-compat, now backed by real API) ────────
  Future<SeoData> getSeoOptimizationData();

  // ─── Phase 2: On-page SEO Checker & Content Structure ───────────────────────
  /// GET /api/contents/:contentId/content-insights
  Future<List<ContentInsight>> getContentInsights(String contentId);

  // ─── Phase 2: Topic Clustering ────────────────────────────────────────────
  /// POST /api/projects/:projectId/cluster/generate-plan
  Future<ClusterPlan> generateClusterPlan(String projectId, String topic);

  /// POST /api/projects/:projectId/cluster/generate-articles
  /// Returns a jobId that can be tracked via SSE
  Future<String> generateClusterArticles(String projectId, ClusterPlan plan);

  // ─── Phase 2: Content Optimization ────────────────────────────────────────
  /// POST /api/contents/:id/regenerate
  Future<void> optimizeContent(String contentId, String improvement);

  // ─── Phase 2: Internal Linking ────────────────────────────────────────────
  /// POST /api/contents/:id/publish  (triggers auto-internal-linking)
  Future<void> publishContent(String contentId);

  /// POST /api/contents/:id/republish
  Future<void> republishContent(String contentId);
}

