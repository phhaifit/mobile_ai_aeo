// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterStore on _RegisterStore, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(() => super.isLoading,
              name: '_RegisterStore.isLoading'))
          .value;

  late final _$successAtom =
      Atom(name: '_RegisterStore.success', context: context);

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

  late final _$agreedToTermsAtom =
      Atom(name: '_RegisterStore.agreedToTerms', context: context);

  @override
  bool get agreedToTerms {
    _$agreedToTermsAtom.reportRead();
    return super.agreedToTerms;
  }

  @override
  set agreedToTerms(bool value) {
    _$agreedToTermsAtom.reportWrite(value, super.agreedToTerms, () {
      super.agreedToTerms = value;
    });
  }

  late final _$registerFutureAtom =
      Atom(name: '_RegisterStore.registerFuture', context: context);

  @override
  ObservableFuture<bool> get registerFuture {
    _$registerFutureAtom.reportRead();
    return super.registerFuture;
  }

  @override
  set registerFuture(ObservableFuture<bool> value) {
    _$registerFutureAtom.reportWrite(value, super.registerFuture, () {
      super.registerFuture = value;
    });
  }

  late final _$registerAsyncAction =
      AsyncAction('_RegisterStore.register', context: context);

  @override
  Future<void> register(String email, String password, String confirmPassword) {
    return _$registerAsyncAction
        .run(() => super.register(email, password, confirmPassword));
  }

  late final _$setAgreedToTermsAsyncAction =
      AsyncAction('_RegisterStore.setAgreedToTerms', context: context);

  @override
  Future<void> setAgreedToTerms(bool value) {
    return _$setAgreedToTermsAsyncAction
        .run(() async => super.setAgreedToTerms(value));
  }

  late final _$clearErrorAsyncAction =
      AsyncAction('_RegisterStore.clearError', context: context);

  @override
  Future<void> clearError() {
    return _$clearErrorAsyncAction.run(() async => super.clearError());
  }

  @override
  String toString() {
    return '''
success: ${success},
agreedToTerms: ${agreedToTerms},
registerFuture: ${registerFuture},
isLoading: ${isLoading}
    ''';
  }
}
