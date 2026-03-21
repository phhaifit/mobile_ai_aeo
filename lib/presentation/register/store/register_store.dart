import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:mobx/mobx.dart';

part 'register_store.g.dart';

class RegisterStore = _RegisterStore with _$RegisterStore;

abstract class _RegisterStore with Store {
  // constructor:---------------------------------------------------------------
  _RegisterStore(
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();
  }

  // stores:--------------------------------------------------------------------
  // for handling form errors
  final FormErrorStore formErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<bool> emptyRegisterResponse =
      ObservableFuture.value(false);

  // store variables:-----------------------------------------------------------
  @observable
  bool success = false;

  @observable
  bool agreedToTerms = false;

  @observable
  ObservableFuture<bool> registerFuture = emptyRegisterResponse;

  @computed
  bool get isLoading => registerFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> register(
      String email, String password, String confirmPassword) async {
    // Mock validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorStore.setErrorMessage('All fields are required');
      return;
    }

    if (password != confirmPassword) {
      errorStore.setErrorMessage('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      errorStore.setErrorMessage('Password must be at least 6 characters');
      return;
    }

    // Simulate network call
    final future = Future<bool>.delayed(
      const Duration(seconds: 2),
      () => true,
    );

    registerFuture = ObservableFuture(future);

    await future.then((value) {
      if (value) {
        success = true;
        errorStore.setErrorMessage('');
      }
    }).catchError((error) {
      errorStore.setErrorMessage(error.toString());
    });
  }

  @action
  void setAgreedToTerms(bool value) {
    agreedToTerms = value;
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
