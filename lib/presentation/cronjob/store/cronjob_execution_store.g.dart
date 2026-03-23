// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cronjob_execution_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CronjobExecutionStore on _CronjobExecutionStore, Store {
  Computed<List<CronjobExecution>>? _$filteredExecutionsComputed;

  @override
  List<CronjobExecution> get filteredExecutions =>
      (_$filteredExecutionsComputed ??= Computed<List<CronjobExecution>>(
              () => super.filteredExecutions,
              name: '_CronjobExecutionStore.filteredExecutions'))
          .value;
  Computed<bool>? _$isProcessingComputed;

  @override
  bool get isProcessing =>
      (_$isProcessingComputed ??= Computed<bool>(() => super.isProcessing,
              name: '_CronjobExecutionStore.isProcessing'))
          .value;
  Computed<int>? _$totalExecutionsComputed;

  @override
  int get totalExecutions =>
      (_$totalExecutionsComputed ??= Computed<int>(() => super.totalExecutions,
              name: '_CronjobExecutionStore.totalExecutions'))
          .value;
  Computed<String?>? _$lastExecutionTimeComputed;

  @override
  String? get lastExecutionTime => (_$lastExecutionTimeComputed ??=
          Computed<String?>(() => super.lastExecutionTime,
              name: '_CronjobExecutionStore.lastExecutionTime'))
      .value;
  Computed<int>? _$successCountComputed;

  @override
  int get successCount =>
      (_$successCountComputed ??= Computed<int>(() => super.successCount,
              name: '_CronjobExecutionStore.successCount'))
          .value;
  Computed<int>? _$failureCountComputed;

  @override
  int get failureCount =>
      (_$failureCountComputed ??= Computed<int>(() => super.failureCount,
              name: '_CronjobExecutionStore.failureCount'))
          .value;
  Computed<int>? _$partialCountComputed;

  @override
  int get partialCount =>
      (_$partialCountComputed ??= Computed<int>(() => super.partialCount,
              name: '_CronjobExecutionStore.partialCount'))
          .value;

  late final _$executionsAtom =
      Atom(name: '_CronjobExecutionStore.executions', context: context);

  @override
  List<CronjobExecution> get executions {
    _$executionsAtom.reportRead();
    return super.executions;
  }

  @override
  set executions(List<CronjobExecution> value) {
    _$executionsAtom.reportWrite(value, super.executions, () {
      super.executions = value;
    });
  }

  late final _$selectedExecutionAtom =
      Atom(name: '_CronjobExecutionStore.selectedExecution', context: context);

  @override
  CronjobExecution? get selectedExecution {
    _$selectedExecutionAtom.reportRead();
    return super.selectedExecution;
  }

  @override
  set selectedExecution(CronjobExecution? value) {
    _$selectedExecutionAtom.reportWrite(value, super.selectedExecution, () {
      super.selectedExecution = value;
    });
  }

  late final _$isExecutingAtom =
      Atom(name: '_CronjobExecutionStore.isExecuting', context: context);

  @override
  bool get isExecuting {
    _$isExecutingAtom.reportRead();
    return super.isExecuting;
  }

  @override
  set isExecuting(bool value) {
    _$isExecutingAtom.reportWrite(value, super.isExecuting, () {
      super.isExecuting = value;
    });
  }

  late final _$executionMessageAtom =
      Atom(name: '_CronjobExecutionStore.executionMessage', context: context);

  @override
  String? get executionMessage {
    _$executionMessageAtom.reportRead();
    return super.executionMessage;
  }

  @override
  set executionMessage(String? value) {
    _$executionMessageAtom.reportWrite(value, super.executionMessage, () {
      super.executionMessage = value;
    });
  }

  late final _$currentCronjobIdAtom =
      Atom(name: '_CronjobExecutionStore.currentCronjobId', context: context);

  @override
  String? get currentCronjobId {
    _$currentCronjobIdAtom.reportRead();
    return super.currentCronjobId;
  }

  @override
  set currentCronjobId(String? value) {
    _$currentCronjobIdAtom.reportWrite(value, super.currentCronjobId, () {
      super.currentCronjobId = value;
    });
  }

  late final _$loadExecutionsAsyncAction =
      AsyncAction('_CronjobExecutionStore.loadExecutions', context: context);

  @override
  Future<void> loadExecutions(String cronjobId) {
    return _$loadExecutionsAsyncAction
        .run(() => super.loadExecutions(cronjobId));
  }

  late final _$testRunCronjobAsyncAction =
      AsyncAction('_CronjobExecutionStore.testRunCronjob', context: context);

  @override
  Future<void> testRunCronjob(String cronjobId) {
    return _$testRunCronjobAsyncAction
        .run(() => super.testRunCronjob(cronjobId));
  }

  late final _$_CronjobExecutionStoreActionController =
      ActionController(name: '_CronjobExecutionStore', context: context);

  @override
  void selectExecution(String? executionId) {
    final _$actionInfo = _$_CronjobExecutionStoreActionController.startAction(
        name: '_CronjobExecutionStore.selectExecution');
    try {
      return super.selectExecution(executionId);
    } finally {
      _$_CronjobExecutionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearMessage() {
    final _$actionInfo = _$_CronjobExecutionStoreActionController.startAction(
        name: '_CronjobExecutionStore.clearMessage');
    try {
      return super.clearMessage();
    } finally {
      _$_CronjobExecutionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$_CronjobExecutionStoreActionController.startAction(
        name: '_CronjobExecutionStore.clearSelection');
    try {
      return super.clearSelection();
    } finally {
      _$_CronjobExecutionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
executions: ${executions},
selectedExecution: ${selectedExecution},
isExecuting: ${isExecuting},
executionMessage: ${executionMessage},
currentCronjobId: ${currentCronjobId},
filteredExecutions: ${filteredExecutions},
isProcessing: ${isProcessing},
totalExecutions: ${totalExecutions},
lastExecutionTime: ${lastExecutionTime},
successCount: ${successCount},
failureCount: ${failureCount},
partialCount: ${partialCount}
    ''';
  }
}
