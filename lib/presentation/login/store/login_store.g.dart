// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on _UserStore, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading => (_$isLoadingComputed ??=
          Computed<bool>(() => super.isLoading, name: '_UserStore.isLoading'))
      .value;

  late final _$successAtom = Atom(name: '_UserStore.success', context: context);

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

  late final _$loginFutureAtom =
      Atom(name: '_UserStore.loginFuture', context: context);

  @override
  ObservableFuture<User?> get loginFuture {
    _$loginFutureAtom.reportRead();
    return super.loginFuture;
  }

  @override
  set loginFuture(ObservableFuture<User?> value) {
    _$loginFutureAtom.reportWrite(value, super.loginFuture, () {
      super.loginFuture = value;
    });
  }

  late final _$googleLoginErrorAtom =
      Atom(name: '_UserStore.googleLoginError', context: context);

  @override
  String? get googleLoginError {
    _$googleLoginErrorAtom.reportRead();
    return super.googleLoginError;
  }

  @override
  set googleLoginError(String? value) {
    _$googleLoginErrorAtom.reportWrite(value, super.googleLoginError, () {
      super.googleLoginError = value;
    });
  }

  late final _$loginErrorAtom =
      Atom(name: '_UserStore.loginError', context: context);

  @override
  String? get loginError {
    _$loginErrorAtom.reportRead();
    return super.loginError;
  }

  @override
  set loginError(String? value) {
    _$loginErrorAtom.reportWrite(value, super.loginError, () {
      super.loginError = value;
    });
  }

  late final _$isGoogleLoadingAtom =
      Atom(name: '_UserStore.isGoogleLoading', context: context);

  @override
  bool get isGoogleLoading {
    _$isGoogleLoadingAtom.reportRead();
    return super.isGoogleLoading;
  }

  @override
  set isGoogleLoading(bool value) {
    _$isGoogleLoadingAtom.reportWrite(value, super.isGoogleLoading, () {
      super.isGoogleLoading = value;
    });
  }

  late final _$isEmailLoadingAtom =
      Atom(name: '_UserStore.isEmailLoading', context: context);

  @override
  bool get isEmailLoading {
    _$isEmailLoadingAtom.reportRead();
    return super.isEmailLoading;
  }

  @override
  set isEmailLoading(bool value) {
    _$isEmailLoadingAtom.reportWrite(value, super.isEmailLoading, () {
      super.isEmailLoading = value;
    });
  }

  late final _$loginAsyncAction =
      AsyncAction('_UserStore.login', context: context);

  @override
  Future<dynamic> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$loginWithGoogleAsyncAction =
      AsyncAction('_UserStore.loginWithGoogle', context: context);

  @override
  Future<void> loginWithGoogle() {
    return _$loginWithGoogleAsyncAction.run(() => super.loginWithGoogle());
  }

  @override
  String toString() {
    return '''
success: ${success},
loginFuture: ${loginFuture},
googleLoginError: ${googleLoginError},
loginError: ${loginError},
isGoogleLoading: ${isGoogleLoading},
isEmailLoading: ${isEmailLoading},
isLoading: ${isLoading}
    ''';
  }
}
