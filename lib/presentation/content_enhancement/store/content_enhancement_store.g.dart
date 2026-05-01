// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_enhancement_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ContentEnhancementStore on _ContentEnhancementStore, Store {
  late final _$availableContentsAtom = Atom(
      name: '_ContentEnhancementStore.availableContents', context: context);

  @override
  ObservableList<ContentItem> get availableContents {
    _$availableContentsAtom.reportRead();
    return super.availableContents;
  }

  @override
  set availableContents(ObservableList<ContentItem> value) {
    _$availableContentsAtom.reportWrite(value, super.availableContents, () {
      super.availableContents = value;
    });
  }

  late final _$selectedContentAtom =
      Atom(name: '_ContentEnhancementStore.selectedContent', context: context);

  @override
  ContentItem? get selectedContent {
    _$selectedContentAtom.reportRead();
    return super.selectedContent;
  }

  @override
  set selectedContent(ContentItem? value) {
    _$selectedContentAtom.reportWrite(value, super.selectedContent, () {
      super.selectedContent = value;
    });
  }

  late final _$loadingContentsAtom =
      Atom(name: '_ContentEnhancementStore.loadingContents', context: context);

  @override
  bool get loadingContents {
    _$loadingContentsAtom.reportRead();
    return super.loadingContents;
  }

  @override
  set loadingContents(bool value) {
    _$loadingContentsAtom.reportWrite(value, super.loadingContents, () {
      super.loadingContents = value;
    });
  }

  late final _$activeProjectIdAtom =
      Atom(name: '_ContentEnhancementStore.activeProjectId', context: context);

  @override
  String? get activeProjectId {
    _$activeProjectIdAtom.reportRead();
    return super.activeProjectId;
  }

  @override
  set activeProjectId(String? value) {
    _$activeProjectIdAtom.reportWrite(value, super.activeProjectId, () {
      super.activeProjectId = value;
    });
  }

  late final _$selectedOperationAtom = Atom(
      name: '_ContentEnhancementStore.selectedOperation', context: context);

  @override
  ContentOperation get selectedOperation {
    _$selectedOperationAtom.reportRead();
    return super.selectedOperation;
  }

  @override
  set selectedOperation(ContentOperation value) {
    _$selectedOperationAtom.reportWrite(value, super.selectedOperation, () {
      super.selectedOperation = value;
    });
  }

  late final _$selectedToneAtom =
      Atom(name: '_ContentEnhancementStore.selectedTone', context: context);

  @override
  String? get selectedTone {
    _$selectedToneAtom.reportRead();
    return super.selectedTone;
  }

  @override
  set selectedTone(String? value) {
    _$selectedToneAtom.reportWrite(value, super.selectedTone, () {
      super.selectedTone = value;
    });
  }

  late final _$selectedLengthAtom =
      Atom(name: '_ContentEnhancementStore.selectedLength', context: context);

  @override
  String get selectedLength {
    _$selectedLengthAtom.reportRead();
    return super.selectedLength;
  }

  @override
  set selectedLength(String value) {
    _$selectedLengthAtom.reportWrite(value, super.selectedLength, () {
      super.selectedLength = value;
    });
  }

  late final _$customInstructionAtom = Atom(
      name: '_ContentEnhancementStore.customInstruction', context: context);

  @override
  String get customInstruction {
    _$customInstructionAtom.reportRead();
    return super.customInstruction;
  }

  @override
  set customInstruction(String value) {
    _$customInstructionAtom.reportWrite(value, super.customInstruction, () {
      super.customInstruction = value;
    });
  }

  late final _$currentResultAtom =
      Atom(name: '_ContentEnhancementStore.currentResult', context: context);

  @override
  ContentResult? get currentResult {
    _$currentResultAtom.reportRead();
    return super.currentResult;
  }

  @override
  set currentResult(ContentResult? value) {
    _$currentResultAtom.reportWrite(value, super.currentResult, () {
      super.currentResult = value;
    });
  }

  late final _$sessionHistoryAtom =
      Atom(name: '_ContentEnhancementStore.sessionHistory', context: context);

  @override
  ObservableList<ContentResult> get sessionHistory {
    _$sessionHistoryAtom.reportRead();
    return super.sessionHistory;
  }

  @override
  set sessionHistory(ObservableList<ContentResult> value) {
    _$sessionHistoryAtom.reportWrite(value, super.sessionHistory, () {
      super.sessionHistory = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_ContentEnhancementStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$successAtom =
      Atom(name: '_ContentEnhancementStore.success', context: context);

  @override
  bool get success {
    _$successAtom.reportRead();
    return super.success;
  }

  @override
  set success(bool value) {
    _$successAtom.reportWrite(value, super.success, () {
      super.success = value;
    });
  }

  late final _$activeJobIdAtom =
      Atom(name: '_ContentEnhancementStore.activeJobId', context: context);

  @override
  String? get activeJobId {
    _$activeJobIdAtom.reportRead();
    return super.activeJobId;
  }

  @override
  set activeJobId(String? value) {
    _$activeJobIdAtom.reportWrite(value, super.activeJobId, () {
      super.activeJobId = value;
    });
  }

  late final _$loadAvailableContentsAsyncAction = AsyncAction(
      '_ContentEnhancementStore.loadAvailableContents',
      context: context);

  @override
  Future<void> loadAvailableContents({bool force = false}) {
    return _$loadAvailableContentsAsyncAction
        .run(() => super.loadAvailableContents(force: force));
  }

  late final _$processContentAsyncAction =
      AsyncAction('_ContentEnhancementStore.processContent', context: context);

  @override
  Future<void> processContent() {
    return _$processContentAsyncAction.run(() => super.processContent());
  }

  late final _$_ContentEnhancementStoreActionController =
      ActionController(name: '_ContentEnhancementStore', context: context);

  @override
  void selectContent(ContentItem item) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.selectContent');
    try {
      return super.selectContent(item);
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.clearSelection');
    try {
      return super.clearSelection();
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setOperation(ContentOperation operation) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.setOperation');
    try {
      return super.setOperation(operation);
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTone(String? tone) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.setTone');
    try {
      return super.setTone(tone);
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLength(String length) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.setLength');
    try {
      return super.setLength(length);
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCustomInstruction(String value) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.setCustomInstruction');
    try {
      return super.setCustomInstruction(value);
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearResult() {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.clearResult');
    try {
      return super.clearResult();
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearHistory() {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.clearHistory');
    try {
      return super.clearHistory();
    } finally {
      _$_ContentEnhancementStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
availableContents: ${availableContents},
selectedContent: ${selectedContent},
loadingContents: ${loadingContents},
activeProjectId: ${activeProjectId},
selectedOperation: ${selectedOperation},
selectedTone: ${selectedTone},
selectedLength: ${selectedLength},
customInstruction: ${customInstruction},
currentResult: ${currentResult},
sessionHistory: ${sessionHistory},
loading: ${loading},
success: ${success},
activeJobId: ${activeJobId}
    ''';
  }
}
