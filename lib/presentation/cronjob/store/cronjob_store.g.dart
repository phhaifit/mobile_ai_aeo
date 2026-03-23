// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cronjob_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CronjobStore on _CronjobStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError => (_$hasErrorComputed ??=
          Computed<bool>(() => super.hasError, name: '_CronjobStore.hasError'))
      .value;
  Computed<int>? _$totalCronjobsComputed;

  @override
  int get totalCronjobs =>
      (_$totalCronjobsComputed ??= Computed<int>(() => super.totalCronjobs,
              name: '_CronjobStore.totalCronjobs'))
          .value;
  Computed<int>? _$enabledCountComputed;

  @override
  int get enabledCount =>
      (_$enabledCountComputed ??= Computed<int>(() => super.enabledCount,
              name: '_CronjobStore.enabledCount'))
          .value;
  Computed<int>? _$disabledCountComputed;

  @override
  int get disabledCount =>
      (_$disabledCountComputed ??= Computed<int>(() => super.disabledCount,
              name: '_CronjobStore.disabledCount'))
          .value;

  late final _$cronjobsAtom =
      Atom(name: '_CronjobStore.cronjobs', context: context);

  @override
  List<Cronjob> get cronjobs {
    _$cronjobsAtom.reportRead();
    return super.cronjobs;
  }

  @override
  set cronjobs(List<Cronjob> value) {
    _$cronjobsAtom.reportWrite(value, super.cronjobs, () {
      super.cronjobs = value;
    });
  }

  late final _$selectedCronjobAtom =
      Atom(name: '_CronjobStore.selectedCronjob', context: context);

  @override
  Cronjob? get selectedCronjob {
    _$selectedCronjobAtom.reportRead();
    return super.selectedCronjob;
  }

  @override
  set selectedCronjob(Cronjob? value) {
    _$selectedCronjobAtom.reportWrite(value, super.selectedCronjob, () {
      super.selectedCronjob = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_CronjobStore.isLoading', context: context);

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
      Atom(name: '_CronjobStore.errorMessage', context: context);

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

  late final _$executionsAtom =
      Atom(name: '_CronjobStore.executions', context: context);

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

  late final _$currentExecutionAtom =
      Atom(name: '_CronjobStore.currentExecution', context: context);

  @override
  CronjobExecution? get currentExecution {
    _$currentExecutionAtom.reportRead();
    return super.currentExecution;
  }

  @override
  set currentExecution(CronjobExecution? value) {
    _$currentExecutionAtom.reportWrite(value, super.currentExecution, () {
      super.currentExecution = value;
    });
  }

  late final _$isLoadingHistoryAtom =
      Atom(name: '_CronjobStore.isLoadingHistory', context: context);

  @override
  bool get isLoadingHistory {
    _$isLoadingHistoryAtom.reportRead();
    return super.isLoadingHistory;
  }

  @override
  set isLoadingHistory(bool value) {
    _$isLoadingHistoryAtom.reportWrite(value, super.isLoadingHistory, () {
      super.isLoadingHistory = value;
    });
  }

  late final _$historyErrorAtom =
      Atom(name: '_CronjobStore.historyError', context: context);

  @override
  String? get historyError {
    _$historyErrorAtom.reportRead();
    return super.historyError;
  }

  @override
  set historyError(String? value) {
    _$historyErrorAtom.reportWrite(value, super.historyError, () {
      super.historyError = value;
    });
  }

  late final _$activeAgentTypeAtom =
      Atom(name: '_CronjobStore.activeAgentType', context: context);

  @override
  String? get activeAgentType {
    _$activeAgentTypeAtom.reportRead();
    return super.activeAgentType;
  }

  @override
  set activeAgentType(String? value) {
    _$activeAgentTypeAtom.reportWrite(value, super.activeAgentType, () {
      super.activeAgentType = value;
    });
  }

  late final _$activeAgentConfigAtom =
      Atom(name: '_CronjobStore.activeAgentConfig', context: context);

  @override
  Map<String, dynamic>? get activeAgentConfig {
    _$activeAgentConfigAtom.reportRead();
    return super.activeAgentConfig;
  }

  @override
  set activeAgentConfig(Map<String, dynamic>? value) {
    _$activeAgentConfigAtom.reportWrite(value, super.activeAgentConfig, () {
      super.activeAgentConfig = value;
    });
  }

  late final _$loadCronjobsAsyncAction =
      AsyncAction('_CronjobStore.loadCronjobs', context: context);

  @override
  Future<void> loadCronjobs() {
    return _$loadCronjobsAsyncAction.run(() => super.loadCronjobs());
  }

  late final _$createCronjobAsyncAction =
      AsyncAction('_CronjobStore.createCronjob', context: context);

  @override
  Future<void> createCronjob(Cronjob cronjob) {
    return _$createCronjobAsyncAction.run(() => super.createCronjob(cronjob));
  }

  late final _$updateCronjobAsyncAction =
      AsyncAction('_CronjobStore.updateCronjob', context: context);

  @override
  Future<void> updateCronjob(Cronjob cronjob) {
    return _$updateCronjobAsyncAction.run(() => super.updateCronjob(cronjob));
  }

  late final _$deleteCronjobAsyncAction =
      AsyncAction('_CronjobStore.deleteCronjob', context: context);

  @override
  Future<void> deleteCronjob(String cronjobId) {
    return _$deleteCronjobAsyncAction.run(() => super.deleteCronjob(cronjobId));
  }

  late final _$loadExecutionHistoryAsyncAction =
      AsyncAction('_CronjobStore.loadExecutionHistory', context: context);

  @override
  Future<void> loadExecutionHistory(String cronjobId) {
    return _$loadExecutionHistoryAsyncAction
        .run(() => super.loadExecutionHistory(cronjobId));
  }

  late final _$retryLoadExecutionHistoryAsyncAction =
      AsyncAction('_CronjobStore.retryLoadExecutionHistory', context: context);

  @override
  Future<void> retryLoadExecutionHistory(String cronjobId) {
    return _$retryLoadExecutionHistoryAsyncAction
        .run(() => super.retryLoadExecutionHistory(cronjobId));
  }

  late final _$loadExecutionDetailsAsyncAction =
      AsyncAction('_CronjobStore.loadExecutionDetails', context: context);

  @override
  Future<void> loadExecutionDetails(String executionId) {
    return _$loadExecutionDetailsAsyncAction
        .run(() => super.loadExecutionDetails(executionId));
  }

  late final _$retryLoadExecutionDetailsAsyncAction =
      AsyncAction('_CronjobStore.retryLoadExecutionDetails', context: context);

  @override
  Future<void> retryLoadExecutionDetails(String executionId) {
    return _$retryLoadExecutionDetailsAsyncAction
        .run(() => super.retryLoadExecutionDetails(executionId));
  }

  late final _$_CronjobStoreActionController =
      ActionController(name: '_CronjobStore', context: context);

  @override
  void selectCronjob(String? cronjobId) {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.selectCronjob');
    try {
      return super.selectCronjob(cronjobId);
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearSelection() {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.clearSelection');
    try {
      return super.clearSelection();
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearHistoryError() {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.clearHistoryError');
    try {
      return super.clearHistoryError();
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearExecutionHistory() {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.clearExecutionHistory');
    try {
      return super.clearExecutionHistory();
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void activateAgent(String agentType, Map<String, dynamic> config) {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.activateAgent');
    try {
      return super.activateAgent(agentType, config);
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deactivateAgent() {
    final _$actionInfo = _$_CronjobStoreActionController.startAction(
        name: '_CronjobStore.deactivateAgent');
    try {
      return super.deactivateAgent();
    } finally {
      _$_CronjobStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cronjobs: ${cronjobs},
selectedCronjob: ${selectedCronjob},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
executions: ${executions},
currentExecution: ${currentExecution},
isLoadingHistory: ${isLoadingHistory},
historyError: ${historyError},
activeAgentType: ${activeAgentType},
activeAgentConfig: ${activeAgentConfig},
hasError: ${hasError},
totalCronjobs: ${totalCronjobs},
enabledCount: ${enabledCount},
disabledCount: ${disabledCount}
    ''';
  }
}
