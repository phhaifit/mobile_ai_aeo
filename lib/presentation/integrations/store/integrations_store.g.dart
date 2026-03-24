// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integrations_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$IntegrationsStore on _IntegrationsStore, Store {
  late final _$isConnectingAtom =
      Atom(name: '_IntegrationsStore.isConnecting', context: context);

  @override
  bool get isConnecting {
    _$isConnectingAtom.reportRead();
    return super.isConnecting;
  }

  @override
  set isConnecting(bool value) {
    _$isConnectingAtom.reportWrite(value, super.isConnecting, () {
      super.isConnecting = value;
    });
  }

  late final _$isConnectedAtom =
      Atom(name: '_IntegrationsStore.isConnected', context: context);

  @override
  bool get isConnected {
    _$isConnectedAtom.reportRead();
    return super.isConnected;
  }

  @override
  set isConnected(bool value) {
    _$isConnectedAtom.reportWrite(value, super.isConnected, () {
      super.isConnected = value;
    });
  }

  late final _$hasErrorAtom =
      Atom(name: '_IntegrationsStore.hasError', context: context);

  @override
  bool get hasError {
    _$hasErrorAtom.reportRead();
    return super.hasError;
  }

  @override
  set hasError(bool value) {
    _$hasErrorAtom.reportWrite(value, super.hasError, () {
      super.hasError = value;
    });
  }

  late final _$selectedGscPropertyAtom =
      Atom(name: '_IntegrationsStore.selectedGscProperty', context: context);

  @override
  String? get selectedGscProperty {
    _$selectedGscPropertyAtom.reportRead();
    return super.selectedGscProperty;
  }

  @override
  set selectedGscProperty(String? value) {
    _$selectedGscPropertyAtom.reportWrite(value, super.selectedGscProperty, () {
      super.selectedGscProperty = value;
    });
  }

  late final _$selectedGa4StreamAtom =
      Atom(name: '_IntegrationsStore.selectedGa4Stream', context: context);

  @override
  String? get selectedGa4Stream {
    _$selectedGa4StreamAtom.reportRead();
    return super.selectedGa4Stream;
  }

  @override
  set selectedGa4Stream(String? value) {
    _$selectedGa4StreamAtom.reportWrite(value, super.selectedGa4Stream, () {
      super.selectedGa4Stream = value;
    });
  }

  late final _$connectGoogleAsyncAction =
      AsyncAction('_IntegrationsStore.connectGoogle', context: context);

  @override
  Future<void> connectGoogle() {
    return _$connectGoogleAsyncAction.run(() => super.connectGoogle());
  }

  late final _$_IntegrationsStoreActionController =
      ActionController(name: '_IntegrationsStore', context: context);

  @override
  void disconnect() {
    final _$actionInfo = _$_IntegrationsStoreActionController.startAction(
        name: '_IntegrationsStore.disconnect');
    try {
      return super.disconnect();
    } finally {
      _$_IntegrationsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void simulateError() {
    final _$actionInfo = _$_IntegrationsStoreActionController.startAction(
        name: '_IntegrationsStore.simulateError');
    try {
      return super.simulateError();
    } finally {
      _$_IntegrationsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isConnecting: ${isConnecting},
isConnected: ${isConnected},
hasError: ${hasError},
selectedGscProperty: ${selectedGscProperty},
selectedGa4Stream: ${selectedGa4Stream}
    ''';
  }
}
