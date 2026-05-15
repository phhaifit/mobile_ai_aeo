import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:pkce/pkce.dart';

/// Result of Google OAuth authorization containing PKCE params.
class GoogleAuthResult {
  final String code;
  final String codeVerifier;
  final String redirectUri;

  GoogleAuthResult({
    required this.code,
    required this.codeVerifier,
    required this.redirectUri,
  });
}

/// Service that handles Google OAuth PKCE flow using flutter_web_auth_2.
/// This service only handles the client-side authorization request.
/// The actual token exchange happens on the backend.
class GoogleAuthService {
  // Google OAuth endpoints
  static const String _authorizationEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';

  /// Launch Google sign-in consent screen and return authorization code + PKCE params.
  /// Throws an exception if the user cancels or an error occurs.
  Future<GoogleAuthResult> signIn({
    List<String> scopes = const ['openid', 'email', 'profile'],
    bool offlineAccess = false,
  }) async {
    final String clientId = dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
    final String redirectUri = dotenv.env['GOOGLE_REDIRECT_URI'] ?? '';
    final String urlScheme = dotenv.env['GOOGLE_URL_SCHEME'] ?? '';

    if (clientId.isEmpty || redirectUri.isEmpty || urlScheme.isEmpty) {
      throw Exception(
        'Missing GOOGLE_CLIENT_ID, GOOGLE_REDIRECT_URI or GOOGLE_URL_SCHEME in .env',
      );
    }

    // Generate PKCE code verifier and code challenge
    final pkcePair = PkcePair.generate();

    // Construct the authorization URL
    final queryParams = <String, dynamic>{
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'code_challenge': pkcePair.codeChallenge,
      'code_challenge_method': 'S256',
    };

    if (offlineAccess) {
      queryParams['access_type'] = 'offline';
      queryParams['prompt'] = 'consent';
    }

    final Uri authUrl = Uri.parse(_authorizationEndpoint).replace(queryParameters: queryParams);

    try {
      // Authenticate using flutter_web_auth_2
      final resultUrl = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: urlScheme,
      );

      // Parse the result
      final Uri parsedUrl = Uri.parse(resultUrl);
      final String? authorizationCode = parsedUrl.queryParameters['code'];
      final String? error = parsedUrl.queryParameters['error'];

      if (error != null) {
        throw Exception('Google sign-in error: $error');
      }

      if (authorizationCode == null) {
        throw Exception('No authorization code received from Google');
      }

      return GoogleAuthResult(
        code: authorizationCode,
        codeVerifier: pkcePair.codeVerifier,
        redirectUri: redirectUri,
      );
    } catch (e) {
      if (e.toString().contains('CANCELED')) {
        throw Exception('Google sign-in was cancelled');
      }
      rethrow;
    }
  }
}
