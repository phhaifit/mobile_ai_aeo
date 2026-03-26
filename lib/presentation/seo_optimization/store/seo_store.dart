import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';

import '../../../domain/entity/seo/seo_check_item.dart';
import '../../../domain/entity/seo/topic_cluster.dart';
import '../../../domain/entity/seo/internal_link_suggestion.dart';
import '../../../domain/entity/seo/content_structure_item.dart';
import '../../../domain/usecase/seo/get_seo_data_usecase.dart';

part 'seo_store.g.dart';

class SeoStore = _SeoStore with _$SeoStore;

abstract class _SeoStore with Store {
  final String TAG = "_SeoStore";

  final ErrorStore errorStore;
  final GetSeoDataUseCase getSeoDataUseCase;

  // ─── On-page SEO ───────────────────────────────────────────────────────────
  @observable
  List<SeoCheckItem> onPageSeoItems = [];

  // ─── Topic Clustering ──────────────────────────────────────────────────────
  @observable
  List<TopicCluster> topicClusters = [];

  // ─── Internal Linking ──────────────────────────────────────────────────────
  @observable
  List<InternalLinkSuggestion> internalLinkSuggestions = [];

  // ─── Content Structure ─────────────────────────────────────────────────────
  @observable
  List<ContentStructureItem> contentStructureItems = [];

  @observable
  bool isLoading = false;

  // constructor:---------------------------------------------------------------
  _SeoStore(this.errorStore, this.getSeoDataUseCase);

  // actions:-------------------------------------------------------------------
  @action
  Future<void> fetchMockData() async {
    isLoading = true;
    try {
      final seoData = await getSeoDataUseCase.call();

      onPageSeoItems = seoData.onPageSeoItems;
      topicClusters = seoData.topicClusters;
      internalLinkSuggestions = seoData.internalLinkSuggestions;
      contentStructureItems = seoData.contentStructureItems;

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage('Failed to load SEO data: ${error.toString()}');
    } finally {
      isLoading = false;
    }
  }

  // dispose:-------------------------------------------------------------------
  @action
  void dispose() {}
}
