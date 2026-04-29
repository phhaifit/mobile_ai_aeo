import 'dart:async';

import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/data/network/apis/auth/auth_api.dart';
import 'package:boilerplate/data/service/google_auth_service.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

class UserRepositoryImpl extends UserRepository {
  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;
  final AuthApi _authApi;
  final GoogleAuthService _googleAuthService;

  // constructor
  UserRepositoryImpl(
    this._sharedPrefsHelper,
    this._authApi,
    this._googleAuthService,
  );

  // Login (legacy mock):-------------------------------------------------------
  @override
  Future<User?> login(LoginParams params) async {
    return await Future.delayed(Duration(seconds: 2), () => User());
  }

  // Email/Password Login:------------------------------------------------------
  @override
  Future<String> loginWithEmail(String email, String password) async {
    final response = await _authApi.login(
      email: email,
      password: password,
    );

    final String accessToken = response['accessToken'] as String;

    // Persist the JWT token
    await _sharedPrefsHelper.saveAuthToken(accessToken);

    return accessToken;
  }

  // Google Login:--------------------------------------------------------------
  @override
  Future<String> loginWithGoogle() async {
    // Step 1: Open Google consent screen and get PKCE params
    final googleResult = await _googleAuthService.signIn();

    // Step 2: Send code + codeVerifier to backend for exchange
    final response = await _authApi.loginWithGoogle(
      code: googleResult.code,
      codeVerifier: googleResult.codeVerifier,
      redirectUri: googleResult.redirectUri,
    );

    final String accessToken = response['accessToken'] as String;

    // Step 3: Persist the JWT token
    await _sharedPrefsHelper.saveAuthToken(accessToken);

    return accessToken;
  }

  // Signup:--------------------------------------------------------------------
  @override
  Future<Map<String, dynamic>> signup(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await _authApi.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    return response;
  }

  @override
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  @override
  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;
}
