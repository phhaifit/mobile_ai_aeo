import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/domain/entity/seo/cluster_plan.dart';
import 'package:boilerplate/domain/entity/seo/content_insight.dart';
import 'package:boilerplate/domain/entity/seo/content_structure_item.dart';
import 'package:boilerplate/domain/entity/seo/internal_link_suggestion.dart';
import 'package:boilerplate/domain/entity/seo/seo_check_item.dart';
import 'package:boilerplate/domain/entity/seo/seo_data.dart';
import 'package:boilerplate/domain/entity/seo/topic_cluster.dart';
import 'package:boilerplate/domain/repository/seo_repository.dart';

class SeoRepositoryImpl implements SeoRepository {
  final SeoApi _seoApi;

  SeoRepositoryImpl(this._seoApi);

  // ─── Phase 1 backward-compat ────────────────────────────────────────────────
  /// Maps ContentInsights from the API into the legacy SeoData aggregate.
  /// Uses a hardcoded placeholder contentId — in real usage the store passes a real ID.
  @override
  Future<SeoData> getSeoOptimizationData() async {
    // Return empty SeoData — store now calls the specific methods directly.
    return SeoData(
      onPageSeoItems: [],
      topicClusters: [],
      internalLinkSuggestions: [],
      contentStructureItems: [],
    );
  }

  // ─── Phase 2: Content Insights ─────────────────────────────────────────────
  @override
  Future<List<ContentInsight>> getContentInsights(String contentId) {
    return _seoApi.getContentInsights(contentId);
  }

  // ─── Phase 2: Topic Clustering ─────────────────────────────────────────────
  @override
  Future<ClusterPlan> generateClusterPlan(
      String projectId, String topic) {
    return _seoApi.generateClusterPlan(projectId, topic);
  }

  @override
  Future<String> generateClusterArticles(
      String projectId, ClusterPlan plan) {
    return _seoApi.generateClusterArticles(projectId, plan);
  }

  // ─── Phase 2: Content Optimization ─────────────────────────────────────────
  @override
  Future<void> optimizeContent(String contentId, String improvement) {
    return _seoApi.regenerateContent(contentId, improvement);
  }

  // ─── Phase 2: Internal Linking ─────────────────────────────────────────────
  @override
  Future<void> publishContent(String contentId) {
    return _seoApi.publishContent(contentId);
  }

  @override
  Future<void> republishContent(String contentId) {
    return _seoApi.republishContent(contentId);
  }

  // ─── Helper: map ContentInsight → SeoCheckItem ─────────────────────────────
  static List<SeoCheckItem> insightsToSeoItems(List<ContentInsight> insights) {
    return insights.map((insight) {
      return SeoCheckItem(
        id: insight.id,
        name: insight.title,
        description: insight.description,
        status: _mapStatus(insight.status),
        recommendation: insight.recommendation,
        score: insight.score,
      );
    }).toList();
  }

  // ─── Helper: map ContentInsight → ContentStructureItem ─────────────────────
  static List<ContentStructureItem> insightsToStructureItems(
      List<ContentInsight> insights) {
    return insights.map((insight) {
      return ContentStructureItem(
        section: insight.type,
        recommendation: insight.recommendation ?? insight.description,
        priority: _mapPriority(insight.score),
      );
    }).toList();
  }

  // ─── Helper: map ContentInsight → TopicCluster ─────────────────────────────
  static List<TopicCluster> insightsToClusters(
      List<ContentInsight> insights) {
    // Group insights by type — used for initial load before cluster plan is generated
    final Map<String, List<String>> grouped = {};
    for (final i in insights) {
      grouped.putIfAbsent(i.type, () => []).add(i.title);
    }
    return grouped.entries.map((e) {
      return TopicCluster(pillarTopic: e.key, subtopics: e.value);
    }).toList();
  }

  // ─── Helper: map ContentInsight → InternalLinkSuggestion ───────────────────
  static List<InternalLinkSuggestion> insightsToLinks(
      List<ContentInsight> insights) {
    // Internal links are populated by the publish flow.
    // This returns stub data from insights that relate to linking.
    return insights
        .where((i) => i.type.toLowerCase().contains('link'))
        .map((i) => InternalLinkSuggestion(
              sourcePage: i.title,
              targetPage: i.recommendation ?? '',
              anchorText: i.description,
              relevanceScore: (i.score ?? 70).toInt(),
            ))
        .toList();
  }

  static CheckStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pass':
      case 'good':
        return CheckStatus.pass;
      case 'fail':
      case 'error':
        return CheckStatus.fail;
      default:
        return CheckStatus.warning;
    }
  }

  static StructurePriority _mapPriority(double? score) {
    if (score == null || score < 40) return StructurePriority.high;
    if (score < 70) return StructurePriority.medium;
    return StructurePriority.low;
  }
}

