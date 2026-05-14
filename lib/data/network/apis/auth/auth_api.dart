import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:dio/dio.dart';

/// API client for authentication endpoints.
class AuthApi {
  final DioClient _dioClient;

  AuthApi(this._dioClient);

  /// Call POST /api/auth/login with email/password.
  /// Returns the response map containing { accessToken }.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('=== Login API Error ===');
      print('Status: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
      print('=======================');
      rethrow;
    }
  }

  /// Call POST /api/auth/signup with fullName, email, password.
  /// Returns { success, message, userId }.
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/signup',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('=== Signup API Error ===');
      print('Status: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
      print('========================');
      rethrow;
    }
  }

  /// Call POST /api/auth/login-google with PKCE params.
  /// Returns the response map containing { accessToken }.
  Future<Map<String, dynamic>> loginWithGoogle({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/login-google',
        data: {
          'code': code,
          'codeVerifier': codeVerifier,
          'redirectUri': redirectUri,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print('=== Google Login API Error ===');
      print('Status: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
      final safeCode = code.length > 20 ? code.substring(0, 20) : code;
      print('Request data: code=$safeCode..., codeVerifier=$codeVerifier, redirectUri=$redirectUri');
      print('=============================');
      rethrow;
    }
  }
}
