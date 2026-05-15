// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_polling_frequency_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LlmPollingFrequencyStore on _LlmPollingFrequencyStore, Store {
  late final _$pollingFrequencyAtom = Atom(
      name: '_LlmPollingFrequencyStore.pollingFrequency', context: context);

  @override
  LlmPollingFrequency? get pollingFrequency {
    _$pollingFrequencyAtom.reportRead();
    return super.pollingFrequency;
  }

  @override
  set pollingFrequency(LlmPollingFrequency? value) {
    _$pollingFrequencyAtom.reportWrite(value, super.pollingFrequency, () {
      super.pollingFrequency = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_LlmPollingFrequencyStore.isLoading', context: context);

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
      Atom(name: '_LlmPollingFrequencyStore.errorMessage', context: context);

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

  late final _$isSavingAtom =
      Atom(name: '_LlmPollingFrequencyStore.isSaving', context: context);

  @override
  bool get isSaving {
    _$isSavingAtom.reportRead();
    return super.isSaving;
  }

  @override
  set isSaving(bool value) {
    _$isSavingAtom.reportWrite(value, super.isSaving, () {
      super.isSaving = value;
    });
  }

  late final _$getPollingFrequencyAsyncAction = AsyncAction(
      '_LlmPollingFrequencyStore.getPollingFrequency',
      context: context);

  @override
  Future<void> getPollingFrequency(String projectId) {
    return _$getPollingFrequencyAsyncAction
        .run(() => super.getPollingFrequency(projectId));
  }

  late final _$updatePollingFrequencyAsyncAction = AsyncAction(
      '_LlmPollingFrequencyStore.updatePollingFrequency',
      context: context);

  @override
  Future<void> updatePollingFrequency(
      String projectId, Map<String, dynamic> frequencyData) {
    return _$updatePollingFrequencyAsyncAction
        .run(() => super.updatePollingFrequency(projectId, frequencyData));
  }

  late final _$_LlmPollingFrequencyStoreActionController =
      ActionController(name: '_LlmPollingFrequencyStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_LlmPollingFrequencyStoreActionController
        .startAction(name: '_LlmPollingFrequencyStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_LlmPollingFrequencyStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_LlmPollingFrequencyStoreActionController
        .startAction(name: '_LlmPollingFrequencyStore.reset');
    try {
      return super.reset();
    } finally {
      _$_LlmPollingFrequencyStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pollingFrequency: ${pollingFrequency},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isSaving: ${isSaving}
    ''';
  }
}
