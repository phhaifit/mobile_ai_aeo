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
  PostPublishable,
  PublishPayload,
  PublishResult,
  RateLimitConfig,
  RateLimitable,
  TokenRefreshable,
  ValidationResult,
} from '../platform-provider.interface';

const ZALO_AUTH_BASE = 'https://oauth.zaloapp.com/v4';
const ZALO_API_BASE = 'https://openapi.zalo.me';

@Injectable()
export class ZaloOAProvider
  implements
    PlatformProvider,
    OAuthConnectable,
    PostPublishable,
    TokenRefreshable,
    RateLimitable,
    MediaValidatable
{
  private readonly logger = new Logger(ZaloOAProvider.name);

  readonly platform = SocialPlatform.Zalo;
  readonly connectionType = ConnectionType.OAuth;

  constructor(private readonly configService: ConfigService) {}

  // ============================================================
  // PlatformProvider (base)
  // ============================================================

  getConnectionConfig(): ConnectionConfig {
    return {
      connectionType: ConnectionType.OAuth,
      platform: SocialPlatform.Zalo,
      displayName: 'Zalo Official Account',
      fields: [],
    };
  }

  async validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult> {
    try {
      const response = await fetch(`${ZALO_API_BASE}/v2.0/oa/getoa`, {
        headers: {
          access_token: credentials.accessToken,
        },
      });
      const data = await response.json();

      if (data.error !== 0) {
        return {
          valid: false,
          error: data.message || 'Invalid Zalo OA token',
        };
      }

      return {
        valid: true,
        accountId: String(data.data.oa_id),
        accountName: data.data.name,
        accountAvatar: data.data.avatar,
      };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  // ============================================================
  // OAuthConnectable
  // ============================================================

  getConnectUrl(state: string): string {
    const appId = this.configService.get<string>('ZALO_OA_APP_ID');
    const redirectUri = this.configService.get<string>(
      'SOCIAL_OAUTH_CALLBACK_URL',
    );

    return (
      `${ZALO_AUTH_BASE}/oa/permission?` +
      `app_id=${appId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri + '/zalo')}` +
      `&state=${state}`
    );
  }

  async handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult> {
    const appId = this.configService.get<string>('ZALO_OA_APP_ID');
    const appSecret = this.configService.get<string>('ZALO_OA_SECRET_KEY');

    const params = new URLSearchParams({
      app_id: appId!,
      code,
      grant_type: 'authorization_code',
    });

    const response = await fetch(`${ZALO_AUTH_BASE}/oa/access_token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        secret_key: appSecret!,
      },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error && data.error !== 0) {
      throw new Error(
        `Zalo OA OAuth error: ${data.error_description || data.error_name || data.message}`,
      );
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
    // Zalo OA access_token from authorization_code is already the main token
    // It expires in ~90 days and is refreshed via refresh_token
    return {
      token: shortToken,
      expiresAt: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000), // ~90 days
    };
  }

  async listChannels(userAccessToken: string): Promise<PlatformChannel[]> {
    // Zalo OA token is tied to a single OA — get OA info
    const response = await fetch(`${ZALO_API_BASE}/v2.0/oa/getoa`, {
      headers: {
        access_token: userAccessToken,
      },
    });
    const data = await response.json();

    if (data.error !== 0) {
      throw new Error(
        `Zalo OA fetch error: ${data.message || 'Unknown error'}`,
      );
    }

    return [
      {
        id: String(data.data.oa_id),
        name: data.data.name,
        avatar: data.data.avatar,
        accessToken: userAccessToken,
        tokenExpiresAt: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
        metadata: {
          description: data.data.description,
          numFollower: data.data.num_follower,
        },
      },
    ];
  }

  // ============================================================
  // PostPublishable
  // Zalo OA uses "broadcast" API to send article to followers
  // ============================================================

  async adaptContent(post: PublishPayload): Promise<Record<string, any>> {
    const payload: Record<string, any> = {};

    if (post.mediaUrls?.length && post.linkUrl) {
      // Article with cover image and link
      payload.type = 'article';
      payload.title = post.title || '';
      payload.description = post.message;
      payload.coverUrl = post.mediaUrls[0];
      payload.linkUrl = post.linkUrl;
    } else if (post.linkUrl) {
      // Link article
      payload.type = 'article';
      payload.title = post.title || '';
      payload.description = post.message;
      payload.linkUrl = post.linkUrl;
    } else if (post.mediaUrls?.length) {
      // Image with text
      payload.type = 'image_text';
      payload.message = post.title
        ? `${post.title}\n\n${post.message}`
        : post.message;
      payload.imageUrl = post.mediaUrls[0];
    } else {
      // Text only broadcast
      payload.type = 'text';
      payload.message = post.title
        ? `${post.title}\n\n${post.message}`
        : post.message;
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

      let requestBody: Record<string, any>;
      let apiUrl: string;

      switch (payload.type) {
        case 'article': {
          // Create article via Zalo OA Article API
          apiUrl = `${ZALO_API_BASE}/v2.0/oa/article/create`;

          const body: Record<string, any> = {
            type: 'normal',
            title: payload.title || 'Untitled',
            author: '',
            cover: {
              cover_type: 'photo',
              ...(payload.coverUrl
                ? { photo_url: payload.coverUrl }
                : { status: 'show' }),
            },
            description: payload.description || '',
            body: [
              {
                type: 'text',
                content: payload.description || '',
              },
            ],
          };

          if (payload.linkUrl) {
            body.body.push({
              type: 'text',
              content: `\n\nXem thêm: ${payload.linkUrl}`,
            });
          }

          requestBody = body;
          break;
        }

        case 'image_text': {
          // Broadcast message with image to followers
          apiUrl = `${ZALO_API_BASE}/v3.0/oa/message/cs`;
          requestBody = {
            recipient: { user_id: 'all' }, // broadcast
            message: {
              attachment: {
                type: 'template',
                payload: {
                  template_type: 'media',
                  elements: [
                    {
                      media_type: 'image',
                      url: payload.imageUrl,
                    },
                  ],
                },
              },
              text: payload.message,
            },
          };
          break;
        }

        default: {
          // Text broadcast
          apiUrl = `${ZALO_API_BASE}/v3.0/oa/message/cs`;
          requestBody = {
            recipient: { user_id: 'all' },
            message: {
              text: payload.message,
            },
          };
        }
      }

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          access_token: accessToken,
        },
        body: JSON.stringify(requestBody),
      });

      const data = await response.json();

      if (data.error !== 0 && data.error !== undefined) {
        return {
          success: false,
          error: {
            code: String(data.error),
            message: data.message || 'Zalo OA API error',
            type: this.classifyError(data.error),
          },
        };
      }

      const postId =
        data.data?.article_id || data.data?.message_id || data.data?.id || '';

      return {
        success: true,
        platformPostId: String(postId),
        platformPostUrl: postId ? `https://oa.zalo.me/home` : undefined,
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
  // TokenRefreshable
  // ============================================================

  async refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }> {
    const appId = this.configService.get<string>('ZALO_OA_APP_ID');
    const appSecret = this.configService.get<string>('ZALO_OA_SECRET_KEY');

    const params = new URLSearchParams({
      app_id: appId!,
      refresh_token: credentials.refreshToken,
      grant_type: 'refresh_token',
    });

    const response = await fetch(`${ZALO_AUTH_BASE}/oa/access_token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        secret_key: appSecret!,
      },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error && data.error !== 0) {
      throw new Error(
        `Zalo OA token refresh error: ${data.error_description || data.message}`,
      );
    }

    return {
      credentials: {
        ...credentials,
        accessToken: data.access_token,
        refreshToken: data.refresh_token || credentials.refreshToken,
      },
      expiresAt: data.expires_in
        ? new Date(Date.now() + data.expires_in * 1000)
        : null,
    };
  }

  // ============================================================
  // RateLimitable
  // ============================================================

  getRateLimitConfig(): RateLimitConfig {
    return {
      maxRequests: 500,
      windowMs: 24 * 60 * 60 * 1000, // 24 hours
      perAccount: true,
    };
  }

  // ============================================================
  // MediaValidatable
  // ============================================================

  getMediaConstraints(): MediaConstraints {
    return {
      maxImageSizeBytes: 5 * 1024 * 1024, // 5MB
      maxVideoSizeBytes: 50 * 1024 * 1024, // 50MB
      supportedImageFormats: ['jpg', 'jpeg', 'png', 'gif'],
      supportedVideoFormats: ['mp4'],
      maxMediaCount: 10,
      maxMessageLength: 2000,
    };
  }

  // ============================================================
  // Private helpers
  // ============================================================

  private classifyError(errorCode: number): PublishErrorType {
    // Token expired (-216, -124)
    if (errorCode === -216 || errorCode === -124) {
      return PublishErrorType.AuthExpired;
    }

    // Rate limit (-210), server error (-1)
    if (errorCode === -210 || errorCode === -1) {
      return PublishErrorType.Retryable;
    }

    return PublishErrorType.Fatal;
  }
}
