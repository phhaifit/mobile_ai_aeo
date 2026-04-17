import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:mobx/mobx.dart';
import 'package:boilerplate/domain/usecase/user/signup_usecase.dart';

part 'register_store.g.dart';

class RegisterStore = _RegisterStore with _$RegisterStore;

abstract class _RegisterStore with Store {
  // constructor:---------------------------------------------------------------
  _RegisterStore(
    this.signupUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();
  }

  // use cases:-----------------------------------------------------------------
  final SignupUseCase signupUseCase;

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
  String successMessage = '';

  @observable
  bool agreedToTerms = false;

  @observable
  ObservableFuture<bool> registerFuture = emptyRegisterResponse;

  @computed
  bool get isLoading => registerFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> register(String fullName, String email, String password, String confirmPassword) async {
    // Validation
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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

    final future = signupUseCase.call(
      params: SignupParams(
        fullName: fullName,
        email: email,
        password: password,
      ),
    );

    registerFuture = ObservableFuture(future.then((value) => true));

    await future.then((value) {
      if (value != null && value['success'] == true) {
        success = true;
        successMessage = value['message'] ?? 'Signup successful.';
        errorStore.setErrorMessage('');
      } else {
        errorStore.setErrorMessage(value?['message'] ?? 'Signup failed');
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
