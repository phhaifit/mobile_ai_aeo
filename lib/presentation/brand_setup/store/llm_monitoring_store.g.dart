// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_monitoring_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LlmMonitoringStore on _LlmMonitoringStore, Store {
  late final _$monitoringConfigAtom =
      Atom(name: '_LlmMonitoringStore.monitoringConfig', context: context);

  @override
  ObservableList<LlmMonitoring> get monitoringConfig {
    _$monitoringConfigAtom.reportRead();
    return super.monitoringConfig;
  }

  @override
  set monitoringConfig(ObservableList<LlmMonitoring> value) {
    _$monitoringConfigAtom.reportWrite(value, super.monitoringConfig, () {
      super.monitoringConfig = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_LlmMonitoringStore.isLoading', context: context);

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
      Atom(name: '_LlmMonitoringStore.errorMessage', context: context);

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
      Atom(name: '_LlmMonitoringStore.isProcessing', context: context);

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

  late final _$getMonitoringConfigAsyncAction =
      AsyncAction('_LlmMonitoringStore.getMonitoringConfig', context: context);

  @override
  Future<void> getMonitoringConfig(String projectId) {
    return _$getMonitoringConfigAsyncAction
        .run(() => super.getMonitoringConfig(projectId));
  }

  late final _$toggleMonitoringAsyncAction =
      AsyncAction('_LlmMonitoringStore.toggleMonitoring', context: context);

  @override
  Future<void> toggleMonitoring(String projectId, String llmId, bool enabled) {
    return _$toggleMonitoringAsyncAction
        .run(() => super.toggleMonitoring(projectId, llmId, enabled));
  }

  late final _$_LlmMonitoringStoreActionController =
      ActionController(name: '_LlmMonitoringStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_LlmMonitoringStoreActionController.startAction(
        name: '_LlmMonitoringStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_LlmMonitoringStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_LlmMonitoringStoreActionController.startAction(
        name: '_LlmMonitoringStore.reset');
    try {
      return super.reset();
    } finally {
      _$_LlmMonitoringStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
monitoringConfig: ${monitoringConfig},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isProcessing: ${isProcessing}
    ''';
  }
}
