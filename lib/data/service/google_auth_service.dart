import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

/// Service that handles Google OAuth PKCE flow using flutter_appauth.
/// This service only handles the client-side authorization request.
/// The actual token exchange happens on the backend.
class GoogleAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // Google OAuth endpoints
  static const String _authorizationEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenEndpoint =
      'https://oauth2.googleapis.com/token';

  /// Launch Google sign-in consent screen and return authorization code + PKCE params.
  /// Throws an exception if the user cancels or an error occurs.
  Future<GoogleAuthResult> signIn() async {
    final String clientId =
        dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
    final String redirectUri =
        dotenv.env['GOOGLE_REDIRECT_URI'] ?? '';

    if (clientId.isEmpty || redirectUri.isEmpty) {
      throw Exception(
        'Missing GOOGLE_SERVER_CLIENT_ID or GOOGLE_REDIRECT_URI in .env',
      );
    }

    // Use authorize() instead of authorizeAndExchangeCode()
    // because we want to send the code + codeVerifier to our backend
    // for server-side exchange.
    final AuthorizationResponse? result = await _appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUri,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: _authorizationEndpoint,
          tokenEndpoint: _tokenEndpoint,
        ),
        scopes: ['openid', 'email', 'profile'],
        // flutter_appauth auto-generates codeVerifier and codeChallenge
        // when using PKCE (which is the default)
      ),
    );

    if (result == null) {
      throw Exception('Google sign-in was cancelled');
    }

    if (result.authorizationCode == null) {
      throw Exception('No authorization code received from Google');
    }

    if (result.codeVerifier == null) {
      throw Exception('No code verifier generated');
    }

    return GoogleAuthResult(
      code: result.authorizationCode!,
      codeVerifier: result.codeVerifier!,
      redirectUri: redirectUri,
    );
  }
}
