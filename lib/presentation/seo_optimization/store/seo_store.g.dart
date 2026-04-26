// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SeoStore on _SeoStore, Store {
  late final _$contentIdAtom =
      Atom(name: '_SeoStore.contentId', context: context);

  @override
  String get contentId {
    _$contentIdAtom.reportRead();
    return super.contentId;
  }

  @override
  set contentId(String value) {
    _$contentIdAtom.reportWrite(value, super.contentId, () {
      super.contentId = value;
    });
  }

  late final _$projectIdAtom =
      Atom(name: '_SeoStore.projectId', context: context);

  @override
  String get projectId {
    _$projectIdAtom.reportRead();
    return super.projectId;
  }

  @override
  set projectId(String value) {
    _$projectIdAtom.reportWrite(value, super.projectId, () {
      super.projectId = value;
    });
  }

  late final _$onPageSeoItemsAtom =
      Atom(name: '_SeoStore.onPageSeoItems', context: context);

  @override
  List<SeoCheckItem> get onPageSeoItems {
    _$onPageSeoItemsAtom.reportRead();
    return super.onPageSeoItems;
  }

  @override
  set onPageSeoItems(List<SeoCheckItem> value) {
    _$onPageSeoItemsAtom.reportWrite(value, super.onPageSeoItems, () {
      super.onPageSeoItems = value;
    });
  }

  late final _$topicClustersAtom =
      Atom(name: '_SeoStore.topicClusters', context: context);

  @override
  List<TopicCluster> get topicClusters {
    _$topicClustersAtom.reportRead();
    return super.topicClusters;
  }

  @override
  set topicClusters(List<TopicCluster> value) {
    _$topicClustersAtom.reportWrite(value, super.topicClusters, () {
      super.topicClusters = value;
    });
  }

  late final _$clusterPlanAtom =
      Atom(name: '_SeoStore.clusterPlan', context: context);

  @override
  ClusterPlan? get clusterPlan {
    _$clusterPlanAtom.reportRead();
    return super.clusterPlan;
  }

  @override
  set clusterPlan(ClusterPlan? value) {
    _$clusterPlanAtom.reportWrite(value, super.clusterPlan, () {
      super.clusterPlan = value;
    });
  }

  late final _$clusterJobAtom =
      Atom(name: '_SeoStore.clusterJob', context: context);

  @override
  ClusterJob? get clusterJob {
    _$clusterJobAtom.reportRead();
    return super.clusterJob;
  }

  @override
  set clusterJob(ClusterJob? value) {
    _$clusterJobAtom.reportWrite(value, super.clusterJob, () {
      super.clusterJob = value;
    });
  }

  late final _$isGeneratingClusterAtom =
      Atom(name: '_SeoStore.isGeneratingCluster', context: context);

  @override
  bool get isGeneratingCluster {
    _$isGeneratingClusterAtom.reportRead();
    return super.isGeneratingCluster;
  }

  @override
  set isGeneratingCluster(bool value) {
    _$isGeneratingClusterAtom.reportWrite(value, super.isGeneratingCluster, () {
      super.isGeneratingCluster = value;
    });
  }

  late final _$internalLinkSuggestionsAtom =
      Atom(name: '_SeoStore.internalLinkSuggestions', context: context);

  @override
  List<InternalLinkSuggestion> get internalLinkSuggestions {
    _$internalLinkSuggestionsAtom.reportRead();
    return super.internalLinkSuggestions;
  }

  @override
  set internalLinkSuggestions(List<InternalLinkSuggestion> value) {
    _$internalLinkSuggestionsAtom
        .reportWrite(value, super.internalLinkSuggestions, () {
      super.internalLinkSuggestions = value;
    });
  }

  late final _$isPublishingAtom =
      Atom(name: '_SeoStore.isPublishing', context: context);

  @override
  bool get isPublishing {
    _$isPublishingAtom.reportRead();
    return super.isPublishing;
  }

  @override
  set isPublishing(bool value) {
    _$isPublishingAtom.reportWrite(value, super.isPublishing, () {
      super.isPublishing = value;
    });
  }

  late final _$publishSuccessAtom =
      Atom(name: '_SeoStore.publishSuccess', context: context);

  @override
  bool get publishSuccess {
    _$publishSuccessAtom.reportRead();
    return super.publishSuccess;
  }

  @override
  set publishSuccess(bool value) {
    _$publishSuccessAtom.reportWrite(value, super.publishSuccess, () {
      super.publishSuccess = value;
    });
  }

  late final _$contentStructureItemsAtom =
      Atom(name: '_SeoStore.contentStructureItems', context: context);

  @override
  List<ContentStructureItem> get contentStructureItems {
    _$contentStructureItemsAtom.reportRead();
    return super.contentStructureItems;
  }

  @override
  set contentStructureItems(List<ContentStructureItem> value) {
    _$contentStructureItemsAtom.reportWrite(value, super.contentStructureItems,
        () {
      super.contentStructureItems = value;
    });
  }

  late final _$isOptimizingAtom =
      Atom(name: '_SeoStore.isOptimizing', context: context);

  @override
  bool get isOptimizing {
    _$isOptimizingAtom.reportRead();
    return super.isOptimizing;
  }

  @override
  set isOptimizing(bool value) {
    _$isOptimizingAtom.reportWrite(value, super.isOptimizing, () {
      super.isOptimizing = value;
    });
  }

  late final _$contentInsightsAtom =
      Atom(name: '_SeoStore.contentInsights', context: context);

  @override
  List<ContentInsight> get contentInsights {
    _$contentInsightsAtom.reportRead();
    return super.contentInsights;
  }

  @override
  set contentInsights(List<ContentInsight> value) {
    _$contentInsightsAtom.reportWrite(value, super.contentInsights, () {
      super.contentInsights = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_SeoStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_SeoStore.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$fetchContentInsightsAsyncAction =
      AsyncAction('_SeoStore.fetchContentInsights', context: context);

  @override
  Future<void> fetchContentInsights() {
    return _$fetchContentInsightsAsyncAction
        .run(() => super.fetchContentInsights());
  }

  late final _$generateClusterPlanAsyncAction =
      AsyncAction('_SeoStore.generateClusterPlan', context: context);

  @override
  Future<void> generateClusterPlan(String topic) {
    return _$generateClusterPlanAsyncAction
        .run(() => super.generateClusterPlan(topic));
  }

  late final _$generateClusterArticlesAsyncAction =
      AsyncAction('_SeoStore.generateClusterArticles', context: context);

  @override
  Future<void> generateClusterArticles() {
    return _$generateClusterArticlesAsyncAction
        .run(() => super.generateClusterArticles());
  }

  late final _$optimizeContentAsyncAction =
      AsyncAction('_SeoStore.optimizeContent', context: context);

  @override
  Future<void> optimizeContent(String improvement) {
    return _$optimizeContentAsyncAction
        .run(() => super.optimizeContent(improvement));
  }

  late final _$publishContentAsyncAction =
      AsyncAction('_SeoStore.publishContent', context: context);

  @override
  Future<void> publishContent({bool republish = false}) {
    return _$publishContentAsyncAction
        .run(() => super.publishContent(republish: republish));
  }

  late final _$_SeoStoreActionController =
      ActionController(name: '_SeoStore', context: context);

  @override
  void setContext({required String cId, required String pId}) {
    final _$actionInfo =
        _$_SeoStoreActionController.startAction(name: '_SeoStore.setContext');
    try {
      return super.setContext(cId: cId, pId: pId);
    } finally {
      _$_SeoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo =
        _$_SeoStoreActionController.startAction(name: '_SeoStore.dispose');
    try {
      return super.dispose();
    } finally {
      _$_SeoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
contentId: ${contentId},
projectId: ${projectId},
onPageSeoItems: ${onPageSeoItems},
topicClusters: ${topicClusters},
clusterPlan: ${clusterPlan},
clusterJob: ${clusterJob},
isGeneratingCluster: ${isGeneratingCluster},
internalLinkSuggestions: ${internalLinkSuggestions},
isPublishing: ${isPublishing},
publishSuccess: ${publishSuccess},
contentStructureItems: ${contentStructureItems},
isOptimizing: ${isOptimizing},
contentInsights: ${contentInsights},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
