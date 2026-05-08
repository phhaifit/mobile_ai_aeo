import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;

  AuthInterceptor({
    required this.accessToken,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String persistedToken = (await accessToken() ?? '').trim();
    final String envToken = (dotenv.env['ACCESS_TOKEN'] ?? '').trim();
    // Debug: .env.dev ACCESS_TOKEN overrides saved login so one JWT can be used for local API.
    final String token = kDebugMode && envToken.isNotEmpty
        ? envToken
        : (persistedToken.isNotEmpty ? persistedToken : envToken);
    final String normalizedToken = token.startsWith('Bearer ')
        ? token.substring(7).trim()
        : token;
    // ignore: avoid_print
    print('[AuthInterceptor] persisted=${persistedToken.isNotEmpty} env=${envToken.isNotEmpty} final=${normalizedToken.isNotEmpty} url=${options.uri}');
    if (normalizedToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $normalizedToken';
    }

    super.onRequest(options, handler);
  }
}
