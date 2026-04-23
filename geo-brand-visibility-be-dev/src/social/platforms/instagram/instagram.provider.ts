import { Injectable } from '@nestjs/common';
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
const GRAPH_API_BASE = `https://graph.instagram.com/${GRAPH_API_VERSION}`;
const INSTAGRAM_AUTH_BASE = 'https://api.instagram.com/oauth/authorize';
const INSTAGRAM_TOKEN_URL = 'https://api.instagram.com/oauth/access_token';
const INSTAGRAM_LONG_LIVED_TOKEN_URL =
  'https://graph.instagram.com/access_token';
const INSTAGRAM_REFRESH_TOKEN_URL =
  'https://graph.instagram.com/refresh_access_token';

/**
 * Instagram publishing via Instagram API with Instagram Login.
 * Supports Business and Creator accounts.
 * OAuth: api.instagram.com (Instagram Login, not Facebook Login).
 * Publishing: 2-step — create container → publish via graph.instagram.com.
 * Note: Instagram does not support text-only posts, must have media.
 */
@Injectable()
export class InstagramProvider
  implements
    PlatformProvider,
    OAuthConnectable,
    PostPublishable,
    PostDeletable,
    TokenRefreshable,
    RateLimitable,
    MediaValidatable
{
  readonly platform = SocialPlatform.Instagram;
  readonly connectionType = ConnectionType.OAuth;

  constructor(private readonly configService: ConfigService) {}

  // ============================================================
  // PlatformProvider (base)
  // ============================================================

  getConnectionConfig(): ConnectionConfig {
    return {
      connectionType: ConnectionType.OAuth,
      platform: SocialPlatform.Instagram,
      displayName: 'Instagram',
      fields: [],
    };
  }

  async validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult> {
    try {
      const response = await fetch(
        `${GRAPH_API_BASE}/me?fields=id,name,username,profile_picture_url&access_token=${credentials.accessToken}`,
      );
      const data = await response.json();

      if (data.error) {
        return { valid: false, error: data.error.message };
      }

      return {
        valid: true,
        accountId: data.id,
        accountName: data.username || data.name,
        accountAvatar: data.profile_picture_url,
      };
    } catch (error: any) {
      return { valid: false, error: error.message };
    }
  }

  // ============================================================
  // OAuthConnectable
  // Instagram Login flow (api.instagram.com)
  // ============================================================

  getConnectUrl(state: string): string {
    const appId = this.configService.get<string>('INSTAGRAM_APP_ID');
    const redirectUri = this.configService.get<string>(
      'SOCIAL_OAUTH_CALLBACK_URL',
    );
    const scopes = [
      'instagram_business_basic',
      'instagram_business_content_publish',
      'instagram_business_manage_comments',
    ].join(',');

    return (
      `${INSTAGRAM_AUTH_BASE}?` +
      `client_id=${appId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri + '/instagram')}` +
      `&scope=${scopes}` +
      `&response_type=code` +
      `&state=${state}`
    );
  }

  async handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult> {
    const appId = this.configService.get<string>('INSTAGRAM_APP_ID');
    const appSecret = this.configService.get<string>('INSTAGRAM_APP_SECRET');

    const params = new URLSearchParams({
      client_id: appId!,
      client_secret: appSecret!,
      grant_type: 'authorization_code',
      redirect_uri: redirectUri,
      code,
    });

    const response = await fetch(INSTAGRAM_TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error_type || data.error) {
      throw new Error(
        `Instagram OAuth error: ${data.error_message || data.error?.message || data.error}`,
      );
    }

    return {
      userAccessToken: data.access_token,
      expiresAt: null, // Short-lived token, will exchange below
    };
  }

  async exchangeForLongLivedToken(
    shortToken: string,
  ): Promise<{ token: string; expiresAt: Date | null }> {
    const appSecret = this.configService.get<string>('INSTAGRAM_APP_SECRET');

    const url =
      `${INSTAGRAM_LONG_LIVED_TOKEN_URL}?` +
      `grant_type=ig_exchange_token` +
      `&client_secret=${appSecret}` +
      `&access_token=${shortToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(
        `Instagram token exchange error: ${data.error.message || data.error}`,
      );
    }

    return {
      token: data.access_token,
      expiresAt: data.expires_in
        ? new Date(Date.now() + data.expires_in * 1000)
        : null, // ~60 days
    };
  }

  /**
   * Instagram Login returns the user's own IG account directly.
   * No need to go through Facebook pages.
   */
  async listChannels(userAccessToken: string): Promise<PlatformChannel[]> {
    const response = await fetch(
      `${GRAPH_API_BASE}/me?fields=id,name,username,profile_picture_url,account_type&access_token=${userAccessToken}`,
    );
    const data = await response.json();

    if (data.error) {
      throw new Error(`Instagram profile fetch error: ${data.error.message}`);
    }

    return [
      {
        id: data.id,
        name: data.username || data.name || 'Instagram Account',
        avatar: data.profile_picture_url,
        accessToken: userAccessToken,
        tokenExpiresAt: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000), // ~60 days
        metadata: {
          username: data.username,
          accountType: data.account_type,
        },
      },
    ];
  }

  // ============================================================
  // PostPublishable
  // 2-step: create container → publish
  // ============================================================

  async adaptContent(post: PublishPayload): Promise<Record<string, any>> {
    const payload: Record<string, any> = {};

    const caption = post.title
      ? `${post.title}\n\n${post.message}`
      : post.message;

    if (post.mediaUrls && post.mediaUrls.length > 1) {
      payload.type = 'CAROUSEL';
      payload.caption = caption;
      payload.mediaUrls = post.mediaUrls;
    } else if (post.mediaUrls?.length === 1) {
      payload.type = 'IMAGE';
      payload.caption = caption;
      payload.imageUrl = post.mediaUrls[0];
    } else {
      // Instagram does not support text-only posts
      payload.type = 'TEXT_UNSUPPORTED';
      payload.caption = caption;
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

      if (payload.type === 'TEXT_UNSUPPORTED') {
        return {
          success: false,
          error: {
            code: 'TEXT_ONLY_NOT_SUPPORTED',
            message:
              'Instagram does not support text-only posts. Please include at least one image.',
            type: PublishErrorType.Fatal,
          },
        };
      }

      let containerId: string;

      if (payload.type === 'CAROUSEL') {
        // Step 1a: Create individual item containers
        const itemIds: string[] = [];
        for (const mediaUrl of payload.mediaUrls || []) {
          const params = new URLSearchParams({
            image_url: mediaUrl,
            is_carousel_item: 'true',
            access_token: accessToken,
          });

          const itemRes = await fetch(
            `${GRAPH_API_BASE}/${platformAccountId}/media`,
            {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: params.toString(),
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
          caption: payload.caption || '',
          access_token: accessToken,
        });

        const containerRes = await fetch(
          `${GRAPH_API_BASE}/${platformAccountId}/media`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: carouselParams.toString(),
          },
        );
        const containerData = await containerRes.json();
        if (containerData.error) {
          return this.buildErrorResult(containerData.error);
        }
        containerId = containerData.id;
      } else {
        // Step 1: Create single IMAGE container
        const containerParams = new URLSearchParams({
          image_url: payload.imageUrl,
          caption: payload.caption || '',
          access_token: accessToken,
        });

        const containerRes = await fetch(
          `${GRAPH_API_BASE}/${platformAccountId}/media`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
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
        `${GRAPH_API_BASE}/${platformAccountId}/media_publish`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: publishParams.toString(),
        },
      );
      const publishData = await publishRes.json();

      if (publishData.error) {
        return this.buildErrorResult(publishData.error);
      }

      // Fetch permalink for the published media
      const permalink = await this.fetchPermalink(publishData.id, accessToken);

      return {
        success: true,
        platformPostId: publishData.id,
        platformPostUrl: permalink,
      };
    } catch (error: any) {
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
      throw new Error(`Instagram delete error: ${data.error.message}`);
    }
  }

  // ============================================================
  // TokenRefreshable
  // ============================================================

  async refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }> {
    const url =
      `${INSTAGRAM_REFRESH_TOKEN_URL}?` +
      `grant_type=ig_refresh_token` +
      `&access_token=${credentials.accessToken}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.error) {
      throw new Error(`Instagram token refresh error: ${data.error.message}`);
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
      maxRequests: 25, // 25 posts per 24h per account
      windowMs: 24 * 60 * 60 * 1000,
      perAccount: true,
    };
  }

  // ============================================================
  // MediaValidatable
  // ============================================================

  getMediaConstraints(): MediaConstraints {
    return {
      maxImageSizeBytes: 8 * 1024 * 1024, // 8MB
      maxVideoSizeBytes: 100 * 1024 * 1024, // 100MB
      supportedImageFormats: ['jpg', 'jpeg', 'png'],
      supportedVideoFormats: ['mp4', 'mov'],
      maxMediaCount: 10, // carousel max 10
      maxMessageLength: 2200,
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
        `${GRAPH_API_BASE}/${mediaId}?fields=permalink&access_token=${accessToken}`,
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
        message: error.message || 'Unknown Instagram API error',
        type: this.classifyError(error),
      },
    };
  }

  private classifyError(error: any): PublishErrorType {
    const code = error.code;

    if (code === 190 || code === 102) {
      return PublishErrorType.AuthExpired;
    }

    if (code === 4 || code === 17 || code === 32 || code === 2) {
      return PublishErrorType.Retryable;
    }

    return PublishErrorType.Fatal;
  }
}
