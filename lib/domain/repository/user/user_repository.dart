import 'dart:async';

import 'package:boilerplate/domain/usecase/user/login_usecase.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  /// Login with email/password via backend API.
  /// Returns the JWT access token on success.
  Future<String> loginWithEmail(String email, String password);

  /// Login with Google OAuth PKCE flow.
  /// Returns the JWT access token on success.
  Future<String> loginWithGoogle();

  /// Register a new user with fullName, email, password.
  /// Returns { success, message, userId }.
  Future<Map<String, dynamic>> signup(String fullName, String email, String password);

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;
}
