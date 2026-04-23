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

const THREADS_API_BASE = 'https://graph.threads.net';
const THREADS_AUTH_BASE = 'https://threads.net/oauth/authorize';

@Injectable()
export class ThreadsProvider
  implements
    PlatformProvider,
    OAuthConnectable,
    PostPublishable,
    PostDeletable,
    TokenRefreshable,
    RateLimitable,
    MediaValidatable
{
  private readonly logger = new Logger(ThreadsProvider.name);

  readonly platform = SocialPlatform.Threads;
  readonly connectionType = ConnectionType.OAuth;

  constructor(private readonly configService: ConfigService) {}

  // ============================================================
  // PlatformProvider (base)
  // ============================================================

  getConnectionConfig(): ConnectionConfig {
    return {
      connectionType: ConnectionType.OAuth,
      platform: SocialPlatform.Threads,
      displayName: 'Threads',
      fields: [],
    };
  }

  async validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult> {
    try {
      const response = await fetch(
        `${THREADS_API_BASE}/v1.0/me?fields=id,username,name,threads_profile_picture_url&access_token=${credentials.accessToken}`,
      );
      const data = await response.json();

      if (data.error) {
        return { valid: false, error: data.error.message };
      }

      return {
        valid: true,
        accountId: data.id,
        accountName: data.username || data.name,
        accountAvatar: data.threads_profile_picture_url,
      };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  // ============================================================
  // OAuthConnectable
  // ============================================================

  getConnectUrl(state: string): string {
    const appId = this.configService.get<string>('THREADS_APP_ID');
    const redirectUri = this.configService.get<string>(
      'SOCIAL_OAUTH_CALLBACK_URL',
    );
    const scopes = [
      'threads_basic',
      'threads_content_publish',
      'threads_manage_replies',
    ].join(',');

    return (
      `${THREADS_AUTH_BASE}?` +
      `client_id=${appId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri + '/threads')}` +
      `&scope=${encodeURIComponent(scopes)}` +
      `&response_type=code` +
      `&state=${state}`
    );
  }

  async handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult> {
    const appId = this.configService.get<string>('THREADS_APP_ID');
    const appSecret = this.configService.get<string>('THREADS_APP_SECRET');

    const params = new URLSearchParams({
      client_id: appId!,
      client_secret: appSecret!,
      grant_type: 'authorization_code',
      redirect_uri: redirectUri,
      code,
    });

    const response = await fetch(`${THREADS_API_BASE}/oauth/access_token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error_type || data.error) {
      throw new Error(
        `Threads OAuth error: ${data.error_message || data.error}`,
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
    const appSecret = this.configService.get<string>('THREADS_APP_SECRET');

    const url =
      `${THREADS_API_BASE}/access_token?` +
      `grant_type=th_exchange_token` +
      `&client_secret=${appSecret}` +
      `&access_token=${shortToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(
        `Threads token exchange error: ${data.error.message || data.error}`,
      );
    }

    return {
      token: data.access_token,
      expiresAt: data.expires_in
        ? new Date(Date.now() + data.expires_in * 1000)
        : null, // ~60 days
    };
  }

  async listChannels(userAccessToken: string): Promise<PlatformChannel[]> {
    // Threads has a single channel per user (their profile)
    const response = await fetch(
      `${THREADS_API_BASE}/v1.0/me?fields=id,username,name,threads_profile_picture_url&access_token=${userAccessToken}`,
    );
    const data = await response.json();

    if (data.error) {
      throw new Error(`Threads profile fetch error: ${data.error.message}`);
    }

    return [
      {
        id: data.id,
        name: data.username || data.name || 'Threads Profile',
        avatar: data.threads_profile_picture_url,
        accessToken: userAccessToken,
        tokenExpiresAt: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000), // 60 days
        metadata: { username: data.username },
      },
    ];
  }

  // ============================================================
  // PostPublishable
  // Threads uses 2-step publishing: create container → publish
  // ============================================================

  async adaptContent(post: PublishPayload): Promise<Record<string, any>> {
    const payload: Record<string, any> = {};

    const fullMessage = post.title
      ? `${post.title}\n\n${post.message}`
      : post.message;

    if (post.mediaUrls?.length === 1) {
      // Single image post
      payload.type = 'IMAGE';
      payload.text = fullMessage;
      payload.imageUrl = post.mediaUrls[0];
    } else if (post.mediaUrls && post.mediaUrls.length > 1) {
      // Carousel post
      payload.type = 'CAROUSEL';
      payload.text = fullMessage;
      payload.mediaUrls = post.mediaUrls;
    } else if (post.linkUrl) {
      // Text post with link (Threads auto-embeds links)
      payload.type = 'TEXT';
      payload.text = `${fullMessage}\n\n${post.linkUrl}`;
    } else {
      // Text-only post
      payload.type = 'TEXT';
      payload.text = fullMessage;
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

      let containerId: string;

      if (payload.type === 'CAROUSEL') {
        // Step 1a: Create individual media containers
        const itemIds: string[] = [];
        for (const mediaUrl of payload.mediaUrls || []) {
          const itemParams = new URLSearchParams({
            media_type: 'IMAGE',
            image_url: mediaUrl,
            is_carousel_item: 'true',
            access_token: accessToken,
          });

          const itemRes = await fetch(
            `${THREADS_API_BASE}/v1.0/${platformAccountId}/threads`,
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: itemParams.toString(),
            },
          );
          const itemData = await itemRes.json();
          if (itemData.error) {
            return this.buildErrorResult(itemData.error);
          }
          itemIds.push(itemData.id);
        }

        // Step 1b: Create carousel container
        const carouselParams = new URLSearchParams({
          media_type: 'CAROUSEL',
          children: itemIds.join(','),
          text: payload.text || '',
          access_token: accessToken,
        });

        const containerRes = await fetch(
          `${THREADS_API_BASE}/v1.0/${platformAccountId}/threads`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: carouselParams.toString(),
          },
        );
        const containerData = await containerRes.json();
        if (containerData.error) {
          return this.buildErrorResult(containerData.error);
        }
        containerId = containerData.id;
      } else {
        // Step 1: Create media container (TEXT or IMAGE)
        const containerParams = new URLSearchParams({
          media_type: payload.type,
          text: payload.text || '',
          access_token: accessToken,
        });

        if (payload.type === 'IMAGE' && payload.imageUrl) {
          containerParams.append('image_url', payload.imageUrl);
        }

        const containerRes = await fetch(
          `${THREADS_API_BASE}/v1.0/${platformAccountId}/threads`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: containerParams.toString(),
          },
        );
        const containerData = await containerRes.json();

        if (containerData.error) {
          return this.buildErrorResult(containerData.error);
        }
        containerId = containerData.id;
      }

      // Step 2: Publish the container
      const publishParams = new URLSearchParams({
        creation_id: containerId,
        access_token: accessToken,
      });

      const publishRes = await fetch(
        `${THREADS_API_BASE}/v1.0/${platformAccountId}/threads_publish`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: publishParams.toString(),
        },
      );
      const publishData = await publishRes.json();

      if (publishData.error) {
        return this.buildErrorResult(publishData.error);
      }

      // Fetch permalink for the published thread
      const permalink = await this.fetchPermalink(publishData.id, accessToken);

      return {
        success: true,
        platformPostId: publishData.id,
        platformPostUrl: permalink,
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
      `${THREADS_API_BASE}/v1.0/${platformPostId}?access_token=${credentials.accessToken}`,
      { method: 'DELETE' },
    );

    const data = await response.json();
    if (data.error) {
      throw new Error(`Threads delete error: ${data.error.message}`);
    }
  }

  // ============================================================
  // TokenRefreshable
  // ============================================================

  async refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }> {
    const url =
      `${THREADS_API_BASE}/refresh_access_token?` +
      `grant_type=th_refresh_token` +
      `&access_token=${credentials.accessToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(`Threads token refresh error: ${data.error.message}`);
    }

    return {
      credentials: {
        ...credentials,
        accessToken: data.access_token,
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
      maxRequests: 250,
      windowMs: 24 * 60 * 60 * 1000, // 24 hours
      perAccount: true,
    };
  }

  // ============================================================
  // MediaValidatable
  // ============================================================

  getMediaConstraints(): MediaConstraints {
    return {
      maxImageSizeBytes: 8 * 1024 * 1024, // 8MB
      maxVideoSizeBytes: 1024 * 1024 * 1024, // 1GB
      supportedImageFormats: ['jpg', 'jpeg', 'png', 'webp'],
      supportedVideoFormats: ['mp4', 'mov'],
      maxMediaCount: 20, // carousel max 20 items
      maxMessageLength: 500,
    };
  }

  // ============================================================
  // Private helpers
  // ============================================================

  private async fetchPermalink(
    mediaId: string,
    accessToken: string,
  ): Promise<string | undefined> {
    try {
      const res = await fetch(
        `${THREADS_API_BASE}/v1.0/${mediaId}?fields=permalink&access_token=${accessToken}`,
      );
      const data = await res.json();
      return data.permalink || undefined;
    } catch {
      return undefined;
    }
  }

  private buildErrorResult(error: any): PublishResult {
    return {
      success: false,
      error: {
        code: String(error.code || error.error_subcode || 'UNKNOWN'),
        message: error.message || 'Unknown Threads API error',
        type: this.classifyError(error),
      },
    };
  }

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

    return PublishErrorType.Fatal;
  }
}
