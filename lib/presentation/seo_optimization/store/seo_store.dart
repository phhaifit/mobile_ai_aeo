import 'dart:async';

import 'package:boilerplate/data/network/apis/seo/seo_api.dart';
import 'package:boilerplate/data/repository/seo_repository_impl.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';

import '../../../domain/entity/seo/cluster_job.dart';
import '../../../domain/entity/seo/cluster_plan.dart';
import '../../../domain/entity/seo/content_insight.dart';
import '../../../domain/entity/seo/seo_check_item.dart';
import '../../../domain/entity/seo/topic_cluster.dart';
import '../../../domain/entity/seo/internal_link_suggestion.dart';
import '../../../domain/entity/seo/content_structure_item.dart';
import '../../../domain/usecase/seo/get_content_insights_usecase.dart';
import '../../../domain/usecase/seo/generate_cluster_plan_usecase.dart';
import '../../../domain/usecase/seo/generate_cluster_articles_usecase.dart';
import '../../../domain/usecase/seo/optimize_content_usecase.dart';
import '../../../domain/usecase/seo/publish_content_usecase.dart';

part 'seo_store.g.dart';

class SeoStore = _SeoStore with _$SeoStore;

abstract class _SeoStore with Store {
  final String TAG = "_SeoStore";

  final ErrorStore errorStore;
  final GetContentInsightsUseCase getContentInsightsUseCase;
  final GenerateClusterPlanUseCase generateClusterPlanUseCase;
  final GenerateClusterArticlesUseCase generateClusterArticlesUseCase;
  final OptimizeContentUseCase optimizeContentUseCase;
  final PublishContentUseCase publishContentUseCase;

  _SeoStore(
    this.errorStore,
    this.getContentInsightsUseCase,
    this.generateClusterPlanUseCase,
    this.generateClusterArticlesUseCase,
    this.optimizeContentUseCase,
    this.publishContentUseCase,
  );

  // ─── Context IDs ─────────────────────────────────────────────────────────
  @observable
  String contentId = '';

  @observable
  String projectId = '';

  // ─── On-page SEO Checker ─────────────────────────────────────────────────
  @observable
  List<SeoCheckItem> onPageSeoItems = [];

  // ─── Topic Clustering ─────────────────────────────────────────────────────
  @observable
  List<TopicCluster> topicClusters = [];

  @observable
  ClusterPlan? clusterPlan;

  @observable
  ClusterJob? clusterJob;

  @observable
  bool isGeneratingCluster = false;

  // ─── Internal Linking ─────────────────────────────────────────────────────
  @observable
  List<InternalLinkSuggestion> internalLinkSuggestions = [];

  @observable
  bool isPublishing = false;

  @observable
  bool publishSuccess = false;

  // ─── Content Structure ─────────────────────────────────────────────────────
  @observable
  List<ContentStructureItem> contentStructureItems = [];

  @observable
  bool isOptimizing = false;

  // ─── Raw insights (cached for mapping/display) ────────────────────────────
  @observable
  List<ContentInsight> contentInsights = [];

  // ─── Shared loading / error ───────────────────────────────────────────────
  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // SSE subscription
  StreamSubscription<ClusterJob>? _clusterJobSubscription;

  // ─── A C T I O N S ───────────────────────────────────────────────────────

  @action
  void setContext({required String cId, required String pId}) {
    contentId = cId;
    projectId = pId;
  }

  /// Fetch all content insights for the current contentId.
  /// Maps results into the 4 tab data structures.
  @action
  Future<void> fetchContentInsights() async {
    if (contentId.isEmpty) {
      errorMessage = 'Content ID is required to load SEO data.';
      return;
    }
    isLoading = true;
    errorMessage = null;
    try {
      final insights = await getContentInsightsUseCase.call(contentId);
      contentInsights = insights;

      // Map insights to per-tab data
      onPageSeoItems = SeoRepositoryImpl.insightsToSeoItems(insights);
      contentStructureItems = SeoRepositoryImpl.insightsToStructureItems(insights);
      internalLinkSuggestions = SeoRepositoryImpl.insightsToLinks(insights);

      // Only populate topicClusters from insights if no cluster plan has been generated yet
      if (clusterPlan == null) {
        topicClusters = SeoRepositoryImpl.insightsToClusters(insights);
      }
    } catch (e) {
      errorMessage = 'Failed to load SEO insights: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }

  // ─── Topic Clustering Actions ─────────────────────────────────────────────

  @action
  Future<void> generateClusterPlan(String topic) async {
    if (projectId.isEmpty) {
      errorMessage = 'Project ID is required.';
      return;
    }
    isGeneratingCluster = true;
    errorMessage = null;
    try {
      final plan = await generateClusterPlanUseCase.call(projectId, topic);
      clusterPlan = plan;

      // Build UI clusters from the plan
      final pillarCluster = TopicCluster(
        pillarTopic: plan.pillarTopic,
        subtopics: plan.satelliteTopics,
        pillarOutline: plan.pillarOutline,
        keywords: plan.keywords,
      );
      topicClusters = [pillarCluster];
    } catch (e) {
      errorMessage = 'Failed to generate cluster plan: ${e.toString()}';
    } finally {
      isGeneratingCluster = false;
    }
  }

  @action
  Future<void> generateClusterArticles() async {
    final plan = clusterPlan;
    if (plan == null || projectId.isEmpty) {
      errorMessage = 'Generate a cluster plan first.';
      return;
    }
    isGeneratingCluster = true;
    errorMessage = null;
    try {
      final jobId = await generateClusterArticlesUseCase.call(projectId, plan);
      clusterJob = ClusterJob.initial(jobId);

      // Subscribe to SSE stream
      await _clusterJobSubscription?.cancel();
      final seoApi = getIt<SeoApi>();
      _clusterJobSubscription = seoApi.listenToClusterJob(jobId).listen(
        (event) {
          clusterJob = event;
          if (event.status == ClusterJobStatus.completed ||
              event.status == ClusterJobStatus.failed) {
            isGeneratingCluster = false;
          }
        },
        onError: (e) {
          errorMessage = 'Cluster job stream error: ${e.toString()}';
          isGeneratingCluster = false;
        },
        onDone: () {
          isGeneratingCluster = false;
        },
      );
    } catch (e) {
      errorMessage = 'Failed to start article generation: ${e.toString()}';
      isGeneratingCluster = false;
    }
  }

  // ─── Content Optimization Action ──────────────────────────────────────────

  @action
  Future<void> optimizeContent(String improvement) async {
    if (contentId.isEmpty) {
      errorMessage = 'Content ID is required.';
      return;
    }
    isOptimizing = true;
    errorMessage = null;
    try {
      await optimizeContentUseCase.call(contentId, improvement);
      // Refresh insights after optimization
      await fetchContentInsights();
    } catch (e) {
      errorMessage = 'Failed to optimize content: ${e.toString()}';
    } finally {
      isOptimizing = false;
    }
  }

  // ─── Publish / Republish Action ───────────────────────────────────────────

  @action
  Future<void> publishContent({bool republish = false}) async {
    if (contentId.isEmpty) {
      errorMessage = 'Content ID is required.';
      return;
    }
    isPublishing = true;
    publishSuccess = false;
    errorMessage = null;
    try {
      if (republish) {
        await publishContentUseCase.republish(contentId);
      } else {
        await publishContentUseCase.publish(contentId);
      }
      publishSuccess = true;
    } catch (e) {
      errorMessage = 'Failed to publish: ${e.toString()}';
    } finally {
      isPublishing = false;
    }
  }

  // ─── dispose ─────────────────────────────────────────────────────────────
  @action
  void dispose() {
    _clusterJobSubscription?.cancel();
  }
}

