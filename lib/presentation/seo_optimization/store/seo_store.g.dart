// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seo_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SeoStore on _SeoStore, Store {
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

  late final _$fetchMockDataAsyncAction =
      AsyncAction('_SeoStore.fetchMockData', context: context);

  @override
  Future<void> fetchMockData() {
    return _$fetchMockDataAsyncAction.run(() => super.fetchMockData());
  }

  late final _$_SeoStoreActionController =
      ActionController(name: '_SeoStore', context: context);

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
onPageSeoItems: ${onPageSeoItems},
topicClusters: ${topicClusters},
internalLinkSuggestions: ${internalLinkSuggestions},
contentStructureItems: ${contentStructureItems},
isLoading: ${isLoading}
    ''';
  }
}
