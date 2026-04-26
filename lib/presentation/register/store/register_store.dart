import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/usecase/user/signup_usecase.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'register_store.g.dart';

class RegisterStore = _RegisterStore with _$RegisterStore;

abstract class _RegisterStore with Store {
  // constructor:---------------------------------------------------------------
  _RegisterStore(
    this._signupUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();
  }

  // use cases:-----------------------------------------------------------------
  final SignupUseCase _signupUseCase;

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

  @observable
  String? registerError;

  @observable
  String? successMessage;

  @computed
  bool get isLoading => registerFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> register(
    String fullName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Client-side validation
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

    registerError = null;
    successMessage = null;

    // Call real API
    final future = _callSignupApi(fullName, email, password);
    registerFuture = ObservableFuture(future.then((_) => true));

    await future;
  }

  Future<void> _callSignupApi(String fullName, String email, String password) async {
    try {
      final result = await _signupUseCase.call(
        params: SignupParams(
          fullName: fullName,
          email: email,
          password: password,
        ),
      );

      if (result['success'] == true) {
        successMessage = result['message'] as String? ?? 'Đăng ký thành công!';
        success = true;
        errorStore.setErrorMessage('');
      } else {
        registerError = result['message'] as String? ?? 'Đăng ký thất bại';
        errorStore.setErrorMessage(registerError!);
      }
    } on DioException catch (e) {
      print('=== Signup Error ===');
      print('Status: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
      print('====================');

      final data = e.response?.data;
      String message = 'Đăng ký thất bại';

      if (data is Map<String, dynamic>) {
        if (data['message'] is String) {
          message = data['message'];
        } else if (data['message'] is List) {
          // NestJS validation errors come as list
          message = (data['message'] as List).map((e) {
            if (e is Map) return e['constraints']?.values?.first ?? e.toString();
            return e.toString();
          }).join(', ');
        }
      }

      if (e.response?.statusCode == 409) {
        message = 'Email đã được đăng ký';
      }

      registerError = message;
      errorStore.setErrorMessage(message);
    } catch (e) {
      print('Signup error: $e');
      registerError = e.toString();
      errorStore.setErrorMessage(e.toString());
    }
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
