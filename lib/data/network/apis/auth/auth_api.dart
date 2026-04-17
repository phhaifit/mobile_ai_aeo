import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:dio/dio.dart';

class AuthApi {
  // dio instance
  final DioClient _dioClient;

  // injecting dio instance
  AuthApi(this._dioClient);

  /// Returns the response body containing the success message and user ID.
  Future<dynamic> signup(String fullName, String email, String password) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.signup,
        data: {
          "fullName": fullName,
          "email": email,
          "password": password,
        },
      );
      return res.data;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
