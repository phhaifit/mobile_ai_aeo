// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_positioning_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BrandPositioningStore on _BrandPositioningStore, Store {
  late final _$brandPositioningAtom =
      Atom(name: '_BrandPositioningStore.brandPositioning', context: context);

  @override
  BrandPositioning? get brandPositioning {
    _$brandPositioningAtom.reportRead();
    return super.brandPositioning;
  }

  @override
  set brandPositioning(BrandPositioning? value) {
    _$brandPositioningAtom.reportWrite(value, super.brandPositioning, () {
      super.brandPositioning = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_BrandPositioningStore.isLoading', context: context);

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
      Atom(name: '_BrandPositioningStore.errorMessage', context: context);

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
      Atom(name: '_BrandPositioningStore.isSaving', context: context);

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

  late final _$getBrandPositioningAsyncAction = AsyncAction(
      '_BrandPositioningStore.getBrandPositioning',
      context: context);

  @override
  Future<void> getBrandPositioning(String projectId) {
    return _$getBrandPositioningAsyncAction
        .run(() => super.getBrandPositioning(projectId));
  }

  late final _$saveBrandPositioningAsyncAction = AsyncAction(
      '_BrandPositioningStore.saveBrandPositioning',
      context: context);

  @override
  Future<void> saveBrandPositioning(
      String projectId, Map<String, dynamic> positioningData) {
    return _$saveBrandPositioningAsyncAction
        .run(() => super.saveBrandPositioning(projectId, positioningData));
  }

  late final _$updateBrandPositioningAsyncAction = AsyncAction(
      '_BrandPositioningStore.updateBrandPositioning',
      context: context);

  @override
  Future<void> updateBrandPositioning(
      String projectId, Map<String, dynamic> positioningData) {
    return _$updateBrandPositioningAsyncAction
        .run(() => super.updateBrandPositioning(projectId, positioningData));
  }

  late final _$_BrandPositioningStoreActionController =
      ActionController(name: '_BrandPositioningStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_BrandPositioningStoreActionController.startAction(
        name: '_BrandPositioningStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_BrandPositioningStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BrandPositioningStoreActionController.startAction(
        name: '_BrandPositioningStore.reset');
    try {
      return super.reset();
    } finally {
      _$_BrandPositioningStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
brandPositioning: ${brandPositioning},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isSaving: ${isSaving}
    ''';
  }
}
