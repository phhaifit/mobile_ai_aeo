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
    final String token = persistedToken.isNotEmpty ? persistedToken : envToken;
    final String normalizedToken = token.startsWith('Bearer ')
        ? token.substring(7).trim()
        : token;
    if (normalizedToken.isNotEmpty) {
      options.headers.putIfAbsent(
        'Authorization',
        () => 'Bearer $normalizedToken',
      );
    }

    super.onRequest(options, handler);
  }
}
