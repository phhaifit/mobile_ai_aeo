// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_enhancement_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ContentEnhancementStore on _ContentEnhancementStore, Store {
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

  late final _$inputTextAtom =
      Atom(name: '_ContentEnhancementStore.inputText', context: context);

  @override
  String get inputText {
    _$inputTextAtom.reportRead();
    return super.inputText;
  }

  @override
  set inputText(String value) {
    _$inputTextAtom.reportWrite(value, super.inputText, () {
      super.inputText = value;
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

  late final _$processContentAsyncAction =
      AsyncAction('_ContentEnhancementStore.processContent', context: context);

  @override
  Future<void> processContent() {
    return _$processContentAsyncAction.run(() => super.processContent());
  }

  late final _$_ContentEnhancementStoreActionController =
      ActionController(name: '_ContentEnhancementStore', context: context);

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
  void setInputText(String text) {
    final _$actionInfo = _$_ContentEnhancementStoreActionController.startAction(
        name: '_ContentEnhancementStore.setInputText');
    try {
      return super.setInputText(text);
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
selectedOperation: ${selectedOperation},
inputText: ${inputText},
currentResult: ${currentResult},
sessionHistory: ${sessionHistory},
loading: ${loading},
success: ${success}
    ''';
  }
}
