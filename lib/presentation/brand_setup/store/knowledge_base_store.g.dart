// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_base_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$KnowledgeBaseStore on _KnowledgeBaseStore, Store {
  late final _$entriesAtom =
      Atom(name: '_KnowledgeBaseStore.entries', context: context);

  @override
  ObservableList<KnowledgeBaseEntry> get entries {
    _$entriesAtom.reportRead();
    return super.entries;
  }

  @override
  set entries(ObservableList<KnowledgeBaseEntry> value) {
    _$entriesAtom.reportWrite(value, super.entries, () {
      super.entries = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_KnowledgeBaseStore.isLoading', context: context);

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
      Atom(name: '_KnowledgeBaseStore.errorMessage', context: context);

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
      Atom(name: '_KnowledgeBaseStore.isProcessing', context: context);

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

  late final _$getEntriesAsyncAction =
      AsyncAction('_KnowledgeBaseStore.getEntries', context: context);

  @override
  Future<void> getEntries(String projectId) {
    return _$getEntriesAsyncAction.run(() => super.getEntries(projectId));
  }

  late final _$addEntryAsyncAction =
      AsyncAction('_KnowledgeBaseStore.addEntry', context: context);

  @override
  Future<void> addEntry(String projectId, Map<String, dynamic> entryData) {
    return _$addEntryAsyncAction
        .run(() => super.addEntry(projectId, entryData));
  }

  late final _$updateEntryAsyncAction =
      AsyncAction('_KnowledgeBaseStore.updateEntry', context: context);

  @override
  Future<void> updateEntry(
      String projectId, String entryId, Map<String, dynamic> entryData) {
    return _$updateEntryAsyncAction
        .run(() => super.updateEntry(projectId, entryId, entryData));
  }

  late final _$deleteEntryAsyncAction =
      AsyncAction('_KnowledgeBaseStore.deleteEntry', context: context);

  @override
  Future<void> deleteEntry(String projectId, String entryId) {
    return _$deleteEntryAsyncAction
        .run(() => super.deleteEntry(projectId, entryId));
  }

  late final _$_KnowledgeBaseStoreActionController =
      ActionController(name: '_KnowledgeBaseStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_KnowledgeBaseStoreActionController.startAction(
        name: '_KnowledgeBaseStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_KnowledgeBaseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_KnowledgeBaseStoreActionController.startAction(
        name: '_KnowledgeBaseStore.reset');
    try {
      return super.reset();
    } finally {
      _$_KnowledgeBaseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
entries: ${entries},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isProcessing: ${isProcessing}
    ''';
  }
}
