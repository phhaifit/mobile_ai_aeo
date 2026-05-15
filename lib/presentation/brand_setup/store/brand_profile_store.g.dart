// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_profile_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$BrandProfileStore on _BrandProfileStore, Store {
  late final _$brandProfileAtom =
      Atom(name: '_BrandProfileStore.brandProfile', context: context);

  @override
  BrandProfile? get brandProfile {
    _$brandProfileAtom.reportRead();
    return super.brandProfile;
  }

  @override
  set brandProfile(BrandProfile? value) {
    _$brandProfileAtom.reportWrite(value, super.brandProfile, () {
      super.brandProfile = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_BrandProfileStore.isLoading', context: context);

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
      Atom(name: '_BrandProfileStore.errorMessage', context: context);

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
      Atom(name: '_BrandProfileStore.isSaving', context: context);

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

  late final _$getBrandProfileAsyncAction =
      AsyncAction('_BrandProfileStore.getBrandProfile', context: context);

  @override
  Future<void> getBrandProfile(String projectId) {
    return _$getBrandProfileAsyncAction
        .run(() => super.getBrandProfile(projectId));
  }

  late final _$saveBrandProfileAsyncAction =
      AsyncAction('_BrandProfileStore.saveBrandProfile', context: context);

  @override
  Future<void> saveBrandProfile(
      String projectId, Map<String, dynamic> profileData) {
    return _$saveBrandProfileAsyncAction
        .run(() => super.saveBrandProfile(projectId, profileData));
  }

  late final _$updateBrandProfileAsyncAction =
      AsyncAction('_BrandProfileStore.updateBrandProfile', context: context);

  @override
  Future<void> updateBrandProfile(
      String projectId, Map<String, dynamic> profileData) {
    return _$updateBrandProfileAsyncAction
        .run(() => super.updateBrandProfile(projectId, profileData));
  }

  late final _$_BrandProfileStoreActionController =
      ActionController(name: '_BrandProfileStore', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_BrandProfileStoreActionController.startAction(
        name: '_BrandProfileStore.clearError');
    try {
      return super.clearError();
    } finally {
      _$_BrandProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_BrandProfileStoreActionController.startAction(
        name: '_BrandProfileStore.reset');
    try {
      return super.reset();
    } finally {
      _$_BrandProfileStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
brandProfile: ${brandProfile},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isSaving: ${isSaving}
    ''';
  }
}
