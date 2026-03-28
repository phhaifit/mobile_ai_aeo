import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'forgot_password_store.g.dart';

class ForgotPasswordStore = _ForgotPasswordStore with _$ForgotPasswordStore;

abstract class _ForgotPasswordStore with Store {
  // constructor:---------------------------------------------------------------
  _ForgotPasswordStore(
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();
  }

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
      reaction((_) => resetEmailSent, (_) => resetEmailSent = false,
          delay: 3000),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<bool> emptyResetResponse =
      ObservableFuture.value(false);

  // store variables:-----------------------------------------------------------
  @observable
  bool success = false;

  @observable
  bool resetEmailSent = false;

  @observable
  String resetEmail = '';

  @observable
  ObservableFuture<bool> resetFuture = emptyResetResponse;

  @computed
  bool get isLoading => resetFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  void setResetEmail(String email) {
    resetEmail = email;
  }

  @action
  Future<void> sendPasswordReset(String email) async {
    // Mock validation
    if (email.isEmpty) {
      errorStore.setErrorMessage('Please enter your email address');
      return;
    }

    if (!email.contains('@')) {
      errorStore.setErrorMessage('Please enter a valid email address');
      return;
    }

    // Simulate network call
    final future = Future<bool>.delayed(
      const Duration(seconds: 2),
      () => true,
    );

    resetFuture = ObservableFuture(future);

    await future.then((value) {
      if (value) {
        resetEmailSent = true;
        success = true;
        errorStore.setErrorMessage('');
      }
    }).catchError((error) {
      errorStore
          .setErrorMessage('Failed to send reset email. Please try again.');
    });
  }

  @action
  void clearError() {
    errorStore.setErrorMessage('');
  }

  // dispose:-------------------------------------------------------------------
  void dispose() {
    for (final disposer in _disposers) {
      disposer();
    }
  }
}
