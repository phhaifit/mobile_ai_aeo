import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ConnectionType, PublishErrorType, SocialPlatform } from '../../enums';
import {
  ConnectionConfig,
  MediaConstraints,
  MediaValidatable,
  OAuthCallbackResult,
  OAuthConnectable,
  PlatformChannel,
  PlatformProvider,
  PostDeletable,
  PostPublishable,
  PublishPayload,
  PublishResult,
  RateLimitConfig,
  RateLimitable,
  TokenRefreshable,
  ValidationResult,
} from '../platform-provider.interface';

const GRAPH_API_VERSION = 'v25.0';
const GRAPH_API_BASE = `https://graph.facebook.com/${GRAPH_API_VERSION}`;

@Injectable()
export class FacebookProvider
  implements
    PlatformProvider,
    OAuthConnectable,
    PostPublishable,
    PostDeletable,
    TokenRefreshable,
    RateLimitable,
    MediaValidatable
{
  private readonly logger = new Logger(FacebookProvider.name);

  readonly platform = SocialPlatform.Facebook;
  readonly connectionType = ConnectionType.OAuth;

  constructor(private readonly configService: ConfigService) {}

  // ============================================================
  // PlatformProvider (base)
  // ============================================================

  getConnectionConfig(): ConnectionConfig {
    return {
      connectionType: ConnectionType.OAuth,
      platform: SocialPlatform.Facebook,
      displayName: 'Facebook Page',
      fields: [], // OAuth — no manual fields needed
    };
  }

  async validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult> {
    try {
      const response = await fetch(
        `${GRAPH_API_BASE}/me?fields=id,name&access_token=${credentials.accessToken}`,
      );
      const data = await response.json();

      if (data.error) {
        return { valid: false, error: data.error.message };
      }

      return {
        valid: true,
        accountId: data.id,
        accountName: data.name,
      };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  // ============================================================
  // OAuthConnectable
  // ============================================================

  getConnectUrl(state: string): string {
    const appId = this.configService.get<string>('FACEBOOK_APP_ID');
    const redirectUri = this.configService.get<string>(
      'SOCIAL_OAUTH_CALLBACK_URL',
    );
    const scopes = [
      'pages_manage_posts',
      'pages_read_engagement',
      'pages_show_list',
    ].join(',');

    return (
      `https://www.facebook.com/${GRAPH_API_VERSION}/dialog/oauth?` +
      `client_id=${appId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri + '/facebook')}` +
      `&scope=${scopes}` +
      `&state=${state}`
    );
  }

  async handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult> {
    const appId = this.configService.get<string>('FACEBOOK_APP_ID');
    const appSecret = this.configService.get<string>('FACEBOOK_APP_SECRET');

    // Exchange code for short-lived token
    const tokenUrl =
      `${GRAPH_API_BASE}/oauth/access_token?` +
      `client_id=${appId}` +
      `&client_secret=${appSecret}` +
      `&redirect_uri=${encodeURIComponent(redirectUri)}` +
      `&code=${code}`;

    const response = await fetch(tokenUrl);
    const data = await response.json();

    if (data.error) {
      throw new Error(`Facebook OAuth error: ${data.error.message}`);
    }

    return {
      userAccessToken: data.access_token,
      expiresAt: data.expires_in
        ? new Date(Date.now() + data.expires_in * 1000)
        : null,
    };
  }

  async exchangeForLongLivedToken(
    shortToken: string,
  ): Promise<{ token: string; expiresAt: Date | null }> {
    const appId = this.configService.get<string>('FACEBOOK_APP_ID');
    const appSecret = this.configService.get<string>('FACEBOOK_APP_SECRET');

    const url =
      `${GRAPH_API_BASE}/oauth/access_token?` +
      `grant_type=fb_exchange_token` +
      `&client_id=${appId}` +
      `&client_secret=${appSecret}` +
      `&fb_exchange_token=${shortToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(`Facebook token exchange error: ${data.error.message}`);
    }

    return {
      token: data.access_token,
      expiresAt: data.expires_in
        ? new Date(Date.now() + data.expires_in * 1000)
        : null,
    };
  }

  async listChannels(userAccessToken: string): Promise<PlatformChannel[]> {
    const url = `${GRAPH_API_BASE}/me/accounts?fields=id,name,access_token,picture&access_token=${userAccessToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(`Facebook list pages error: ${data.error.message}`);
    }

    return (data.data || []).map((page: any) => ({
      id: page.id,
      name: page.name,
      avatar: page.picture?.data?.url,
      accessToken: page.access_token,
      tokenExpiresAt: null, // Page tokens don't expire
      metadata: {},
    }));
  }

  // ============================================================
  // PostPublishable
  // ============================================================

  async adaptContent(post: PublishPayload): Promise<Record<string, any>> {
    const payload: Record<string, any> = {};

    // Combine title and message body
    const fullMessage = post.title
      ? `${post.title}\n\n${post.message}`
      : post.message;

    if (post.mediaUrls?.length) {
      // Photo post
      payload.type = 'photo';
      payload.url = post.mediaUrls[0];
      payload.caption = fullMessage;
      if (post.mediaUrls.length > 1) {
        payload.additionalPhotos = post.mediaUrls.slice(1);
      }
    } else if (post.linkUrl) {
      // Link post
      payload.type = 'link';
      payload.message = fullMessage;
      payload.link = post.linkUrl;
    } else {
      // Text post
      payload.type = 'text';
      payload.message = fullMessage;
    }

    return payload;
  }

  async publishPost(
    credentials: Record<string, any>,
    platformAccountId: string,
    payload: Record<string, any>,
  ): Promise<PublishResult> {
    try {
      const accessToken = credentials.accessToken;
      let url: string;
      let body: Record<string, any>;

      switch (payload.type) {
        case 'photo':
          url = `${GRAPH_API_BASE}/${platformAccountId}/photos`;
          body = {
            url: payload.url,
            caption: payload.caption,
            access_token: accessToken,
          };
          break;

        case 'link':
          url = `${GRAPH_API_BASE}/${platformAccountId}/feed`;
          body = {
            message: payload.message,
            link: payload.link,
            access_token: accessToken,
          };
          break;

        default: // text
          url = `${GRAPH_API_BASE}/${platformAccountId}/feed`;
          body = {
            message: payload.message,
            access_token: accessToken,
          };
      }

      // Facebook Graph API requires form-urlencoded format
      const params = new URLSearchParams();
      for (const [key, value] of Object.entries(body)) {
        if (value !== undefined && value !== null) {
          params.append(key, String(value));
        }
      }

      const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString(),
      });

      const data = await response.json();

      if (data.error) {
        return {
          success: false,
          error: {
            code: String(data.error.code),
            message: data.error.message,
            type: this.classifyError(data.error),
          },
        };
      }

      return {
        success: true,
        platformPostId: data.id || data.post_id,
        platformPostUrl: `https://www.facebook.com/${data.id || data.post_id}`,
      };
    } catch (error) {
      return {
        success: false,
        error: {
          code: 'NETWORK_ERROR',
          message: error.message,
          type: PublishErrorType.Retryable,
        },
      };
    }
  }

  // ============================================================
  // PostDeletable
  // ============================================================

  async deletePost(
    credentials: Record<string, any>,
    platformPostId: string,
  ): Promise<void> {
    const response = await fetch(
      `${GRAPH_API_BASE}/${platformPostId}?access_token=${credentials.accessToken}`,
      { method: 'DELETE' },
    );

    const data = await response.json();
    if (data.error) {
      throw new Error(`Facebook delete error: ${data.error.message}`);
    }
  }

  // ============================================================
  // TokenRefreshable
  // ============================================================

  async refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }> {
    // Page tokens don't expire, but user tokens do (60 days).
    // If this is a page token, no refresh needed.
    // For safety, we try to exchange again.
    const result = await this.exchangeForLongLivedToken(
      credentials.accessToken,
    );
    return {
      credentials: {
        ...credentials,
        accessToken: result.token,
      },
      expiresAt: result.expiresAt,
    };
  }

  // ============================================================
  // RateLimitable
  // ============================================================

  getRateLimitConfig(): RateLimitConfig {
    return {
      maxRequests: 200,
      windowMs: 60 * 60 * 1000, // 1 hour
      perAccount: true,
    };
  }

  // ============================================================
  // MediaValidatable
  // ============================================================

  getMediaConstraints(): MediaConstraints {
    return {
      maxImageSizeBytes: 10 * 1024 * 1024, // 10MB
      maxVideoSizeBytes: 10 * 1024 * 1024 * 1024, // 10GB
      supportedImageFormats: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      supportedVideoFormats: ['mp4', 'mov', 'avi'],
      maxMediaCount: 10,
      maxMessageLength: 63206,
    };
  }

  // ============================================================
  // Private helpers
  // ============================================================

  private classifyError(error: any): PublishErrorType {
    const code = error.code;

    // Token expired or invalid
    if (code === 190 || code === 102) {
      return PublishErrorType.AuthExpired;
    }

    // Rate limiting, temporary server errors
    if (code === 4 || code === 17 || code === 32 || code === 2) {
      return PublishErrorType.Retryable;
    }

    // Content policy violations, invalid parameters
    return PublishErrorType.Fatal;
  }
}
