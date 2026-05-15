// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_rewrite_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UrlRewriteStore on _UrlRewriteStore, Store {
  late final _$rewritesAtom =
      Atom(name: '_UrlRewriteStore.rewrites', context: context);

  @override
  ObservableList<UrlRewrite> get rewrites {
    _$rewritesAtom.reportRead();
    return super.rewrites;
  }

  @override
  set rewrites(ObservableList<UrlRewrite> value) {
    _$rewritesAtom.reportWrite(value, super.rewrites, () {
      super.rewrites = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_UrlRewriteStore.isLoading', context: context);

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
      Atom(name: '_UrlRewriteStore.errorMessage', context: context);

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
      Atom(name: '_UrlRewriteStore.isProcessing', context: context);

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

  late final _$getRewritesAsyncAction =
      AsyncAction('_UrlRewriteStore.getRewrites', context: context);

  @override
  Future<void> getRewrites(String projectId) {
    return _$getRewritesAsyncAction.run(() => super.getRewrites(projectId));
  }

  late final _$addRewriteAsyncAction =
      AsyncAction('_UrlRewriteStore.addRewrite', context: context);

  @override
  Future<void> addRewrite(String projectId, Map<String, dynamic> rewriteData) {
    return _$addRewriteAsyncAction
        .run(() => super.addRewrite(projectId, rewriteData));
  }

  late final _$updateRewriteAsyncAction =
      AsyncAction('_UrlRewriteStore.updateRewrite', context: context);

  @override
  Future<void> updateRewrite(
      String projectId, String rewriteId, Map<String, dynamic> rewriteData) {
    return _$updateRewriteAsyncAction
        .run(() => super.updateRewrite(projectId, rewriteId, rewriteData));
  }

  late final _$deleteRewriteAsyncAction =
      AsyncAction('_UrlRewriteStore.deleteRewrite', context: context);

  @override
  Future<void> deleteRewrite(String projectId, String rewriteId) {
    return _$deleteRewriteAsyncAction
        .run(() => super.deleteRewrite(projectId, rewriteId));
  }

  late final _$_UrlRewriteStoreActionController =
      ActionController(name: '_UrlRewriteStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_UrlRewriteStoreActionController.startAction(
        name: '_UrlRewriteStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_UrlRewriteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_UrlRewriteStoreActionController.startAction(
        name: '_UrlRewriteStore.reset');
    try {
      return super.reset();
    } finally {
      _$_UrlRewriteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
rewrites: ${rewrites},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isProcessing: ${isProcessing}
    ''';
  }
}
