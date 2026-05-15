// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_link_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UrlLinkStore on _UrlLinkStore, Store {
  late final _$linksAtom = Atom(name: '_UrlLinkStore.links', context: context);

  @override
  ObservableList<UrlLink> get links {
    _$linksAtom.reportRead();
    return super.links;
  }

  @override
  set links(ObservableList<UrlLink> value) {
    _$linksAtom.reportWrite(value, super.links, () {
      super.links = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_UrlLinkStore.isLoading', context: context);

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
      Atom(name: '_UrlLinkStore.errorMessage', context: context);

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

  late final _$isProcessingAtom =
      Atom(name: '_UrlLinkStore.isProcessing', context: context);

  @override
  bool get isProcessing {
    _$isProcessingAtom.reportRead();
    return super.isProcessing;
  }

  @override
  set isProcessing(bool value) {
    _$isProcessingAtom.reportWrite(value, super.isProcessing, () {
      super.isProcessing = value;
    });
  }

  late final _$getLinksAsyncAction =
      AsyncAction('_UrlLinkStore.getLinks', context: context);

  @override
  Future<void> getLinks(String projectId) {
    return _$getLinksAsyncAction.run(() => super.getLinks(projectId));
  }

  late final _$addLinkAsyncAction =
      AsyncAction('_UrlLinkStore.addLink', context: context);

  @override
  Future<void> addLink(String projectId, Map<String, dynamic> linkData) {
    return _$addLinkAsyncAction.run(() => super.addLink(projectId, linkData));
  }

  late final _$updateLinkAsyncAction =
      AsyncAction('_UrlLinkStore.updateLink', context: context);

  @override
  Future<void> updateLink(
      String projectId, String linkId, Map<String, dynamic> linkData) {
    return _$updateLinkAsyncAction
        .run(() => super.updateLink(projectId, linkId, linkData));
  }

  late final _$deleteLinkAsyncAction =
      AsyncAction('_UrlLinkStore.deleteLink', context: context);

  @override
  Future<void> deleteLink(String projectId, String linkId) {
    return _$deleteLinkAsyncAction
        .run(() => super.deleteLink(projectId, linkId));
  }

  late final _$_UrlLinkStoreActionController =
      ActionController(name: '_UrlLinkStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_UrlLinkStoreActionController.startAction(
        name: '_UrlLinkStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_UrlLinkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_UrlLinkStoreActionController.startAction(
        name: '_UrlLinkStore.reset');
    try {
      return super.reset();
    } finally {
      _$_UrlLinkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
links: ${links},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isProcessing: ${isProcessing}
    ''';
  }
}
