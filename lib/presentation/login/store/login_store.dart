import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:boilerplate/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:boilerplate/domain/usecase/user/google_login_usecase.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:mobx/mobx.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

part 'login_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // constructor:---------------------------------------------------------------
  _UserStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._loginUseCase,
    this._googleLoginUseCase,
    this._userRepository,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    _isLoggedInUseCase.call(params: null).then((value) async {
      isLoggedIn = value;
    });
  }

  // use cases:-----------------------------------------------------------------
  final IsLoggedInUseCase _isLoggedInUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;
  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final UserRepository _userRepository;

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
  static ObservableFuture<User?> emptyLoginResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

  @observable
  String? googleLoginError;

  @observable
  String? loginError;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  @observable
  bool isGoogleLoading = false;

  @observable
  bool isEmailLoading = false;

  // actions:-------------------------------------------------------------------
  @action
  Future login(String email, String password) async {
    loginError = null;
    isEmailLoading = true;
    try {
      await _userRepository.loginWithEmail(email, password);
      await _saveLoginStatusUseCase.call(params: true);
      this.isLoggedIn = true;
      this.success = true;
    } catch (e) {
      print('Email login error: $e');
      loginError = _extractErrorMessage(e);
      this.isLoggedIn = false;
      this.success = false;
    } finally {
      isEmailLoading = false;
    }
  }

  @action
  Future<void> loginWithGoogle() async {
    googleLoginError = null;
    isGoogleLoading = true;
    try {
      await _googleLoginUseCase.call(params: null);
      await _saveLoginStatusUseCase.call(params: true);
      this.isLoggedIn = true;
      this.success = true;
    } catch (e) {
      print('Google login error: $e');
      googleLoginError = e.toString();
      this.isLoggedIn = false;
      this.success = false;
    } finally {
      isGoogleLoading = false;
    }
  }

  logout() async {
    this.isLoggedIn = false;
    await _saveLoginStatusUseCase.call(params: false);
  }

  /// Extract user-friendly error message from DioException or other errors
  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();
    // Try to extract the response message from DioException
    if (errorStr.contains('Response body:')) {
      return errorStr;
    }
    // Check for common HTTP status messages
    if (errorStr.contains('401')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (errorStr.contains('409')) {
      return 'Email đã được đăng ký';
    }
    return errorStr;
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
