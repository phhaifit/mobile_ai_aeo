import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { OAuth2Client } from 'google-auth-library';
import { ConfigService } from '@nestjs/config';
import { createHash } from 'crypto';
import { encryptValue, decryptValue } from '../shared/utils/encryption.util';

export interface GoogleProfile {
  id: string;
  email: string;
  verified_email: boolean;
  name: string;
  given_name: string;
  family_name: string;
  picture: string;
  locale: string;
}

export interface GoogleTokens {
  refreshToken: string;
  accessToken: string;
  scopes: string[];
  expiresAt: Date | null;
}

@Injectable()
export class GoogleService {
  private readonly logger = new Logger(GoogleService.name);
  private readonly oAuth2Client: OAuth2Client;
  private readonly encryptionKey: string;
  private readonly clientId: string;
  private readonly clientSecret: string;

  // In-memory cache for access tokens (keyed by encrypted refresh token hash)
  private accessTokenCache = new Map<
    string,
    { token: string; expiresAt: number }
  >();

  constructor(private readonly configService: ConfigService) {
    this.clientId = this.configService.get<string>('GOOGLE_CLIENT_ID') || '';
    this.clientSecret =
      this.configService.get<string>('GOOGLE_CLIENT_SECRET') || '';
    this.oAuth2Client = new OAuth2Client(this.clientId, this.clientSecret);
    this.encryptionKey =
      this.configService.get<string>('TOKEN_ENCRYPTION_KEY') || '';
  }

  async exchangeAuthorizationCode(
    code: string,
    codeVerifier: string,
    redirectUri: string,
  ): Promise<{
    profile: GoogleProfile;
    idToken: string;
  }> {
    const response = await this.oAuth2Client.getToken({
      code,
      codeVerifier,
      redirect_uri: redirectUri,
    });

    const tokens = response.tokens;
    if (!tokens.id_token) {
      throw new UnauthorizedException('Invalid Google token');
    }

    const ticket = await this.oAuth2Client.verifyIdToken({
      idToken: tokens.id_token,
      audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
    });

    const payload = ticket.getPayload();
    if (!payload) {
      throw new UnauthorizedException('Google verification failed');
    }

    const profile: GoogleProfile = {
      id: payload.sub,
      email: payload.email || '',
      verified_email: payload.email_verified || false,
      name: payload.name || '',
      given_name: payload.given_name || '',
      family_name: payload.family_name || '',
      picture: payload.picture || '',
      locale: payload.locale || '',
    };

    return {
      profile,
      idToken: tokens.id_token,
    };
  }

  /**
   * Exchange an authorization code for tokens (including refresh_token).
   * Used for incremental OAuth (e.g., GSC connection) where we need to persist tokens.
   */
  async exchangeCodeForTokens(
    code: string,
    codeVerifier: string,
    redirectUri: string,
  ): Promise<GoogleTokens> {
    const response = await this.oAuth2Client.getToken({
      code,
      codeVerifier,
      redirect_uri: redirectUri,
    });

    const tokens = response.tokens;
    if (!tokens.refresh_token) {
      throw new UnauthorizedException(
        'No refresh token received. Ensure access_type=offline and prompt=consent are set.',
      );
    }

    const scopes = tokens.scope ? tokens.scope.split(' ') : [];
    const expiresAt = tokens.expiry_date ? new Date(tokens.expiry_date) : null;

    return {
      refreshToken: tokens.refresh_token,
      accessToken: tokens.access_token || '',
      scopes,
      expiresAt,
    };
  }

  /**
   * Get a fresh access token from an encrypted refresh token.
   * Uses in-memory cache to avoid unnecessary token refreshes (~55 min TTL).
   */
  async getAccessTokenFromRefresh(
    encryptedRefreshToken: string,
  ): Promise<string> {
    // Check in-memory cache (hash the full token to avoid collisions)
    const cacheKey = createHash('sha256')
      .update(encryptedRefreshToken)
      .digest('hex');
    const cached = this.accessTokenCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) {
      return cached.token;
    }

    const refreshToken = decryptValue(
      encryptedRefreshToken,
      this.encryptionKey,
    );

    // Create a new OAuth2Client per refresh to avoid shared state mutation
    const client = new OAuth2Client(this.clientId, this.clientSecret);
    client.setCredentials({ refresh_token: refreshToken });
    const { credentials } = await client.refreshAccessToken();

    if (!credentials.access_token) {
      throw new UnauthorizedException('Failed to refresh Google access token');
    }

    // Cache for 55 minutes (tokens last ~60 min)
    this.accessTokenCache.set(cacheKey, {
      token: credentials.access_token,
      expiresAt: Date.now() + 55 * 60 * 1000,
    });

    return credentials.access_token;
  }

  /**
   * Encrypt a refresh token for storage.
   */
  encryptRefreshToken(refreshToken: string): string {
    return encryptValue(refreshToken, this.encryptionKey);
  }
}
