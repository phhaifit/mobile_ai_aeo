// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ForgotPasswordStore on _ForgotPasswordStore, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(() => super.isLoading,
              name: '_ForgotPasswordStore.isLoading'))
          .value;

  late final _$successAtom =
      Atom(name: '_ForgotPasswordStore.success', context: context);

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

  late final _$resetEmailSentAtom =
      Atom(name: '_ForgotPasswordStore.resetEmailSent', context: context);

  @override
  bool get resetEmailSent {
    _$resetEmailSentAtom.reportRead();
    return super.resetEmailSent;
  }

  @override
  set resetEmailSent(bool value) {
    _$resetEmailSentAtom.reportWrite(value, super.resetEmailSent, () {
      super.resetEmailSent = value;
    });
  }

  late final _$resetEmailAtom =
      Atom(name: '_ForgotPasswordStore.resetEmail', context: context);

  @override
  String get resetEmail {
    _$resetEmailAtom.reportRead();
    return super.resetEmail;
  }

  @override
  set resetEmail(String value) {
    _$resetEmailAtom.reportWrite(value, super.resetEmail, () {
      super.resetEmail = value;
    });
  }

  late final _$resetFutureAtom =
      Atom(name: '_ForgotPasswordStore.resetFuture', context: context);

  @override
  ObservableFuture<bool> get resetFuture {
    _$resetFutureAtom.reportRead();
    return super.resetFuture;
  }

  @override
  set resetFuture(ObservableFuture<bool> value) {
    _$resetFutureAtom.reportWrite(value, super.resetFuture, () {
      super.resetFuture = value;
    });
  }

  late final _$setResetEmailAsyncAction =
      AsyncAction('_ForgotPasswordStore.setResetEmail', context: context);

  @override
  Future<void> setResetEmail(String email) {
    return _$setResetEmailAsyncAction.run(() async => super.setResetEmail(email));
  }

  late final _$sendPasswordResetAsyncAction =
      AsyncAction('_ForgotPasswordStore.sendPasswordReset', context: context);

  @override
  Future<void> sendPasswordReset(String email) {
    return _$sendPasswordResetAsyncAction
        .run(() => super.sendPasswordReset(email));
  }

  late final _$clearErrorAsyncAction =
      AsyncAction('_ForgotPasswordStore.clearError', context: context);

  @override
  Future<void> clearError() {
    return _$clearErrorAsyncAction.run(() async => super.clearError());
  }

  @override
  String toString() {
    return '''
success: ${success},
resetEmailSent: ${resetEmailSent},
resetEmail: ${resetEmail},
resetFuture: ${resetFuture},
isLoading: ${isLoading}
    ''';
  }
}
