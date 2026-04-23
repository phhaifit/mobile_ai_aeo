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

const LINKEDIN_API_BASE = 'https://api.linkedin.com';
const LINKEDIN_AUTH_BASE = 'https://www.linkedin.com/oauth/v2';

@Injectable()
export class LinkedInProvider
  implements
    PlatformProvider,
    OAuthConnectable,
    PostPublishable,
    PostDeletable,
    TokenRefreshable,
    RateLimitable,
    MediaValidatable
{
  private readonly logger = new Logger(LinkedInProvider.name);

  readonly platform = SocialPlatform.LinkedIn;
  readonly connectionType = ConnectionType.OAuth;

  constructor(private readonly configService: ConfigService) {}

  // ============================================================
  // PlatformProvider (base)
  // ============================================================

  getConnectionConfig(): ConnectionConfig {
    return {
      connectionType: ConnectionType.OAuth,
      platform: SocialPlatform.LinkedIn,
      displayName: 'LinkedIn',
      fields: [], // OAuth — no manual fields needed
    };
  }

  async validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult> {
    try {
      const response = await fetch(`${LINKEDIN_API_BASE}/v2/userinfo`, {
        headers: {
          Authorization: `Bearer ${credentials.accessToken}`,
        },
      });
      const data = await response.json();

      if (data.status && data.status >= 400) {
        return { valid: false, error: data.message || 'Invalid token' };
      }

      return {
        valid: true,
        accountId: data.sub,
        accountName: data.name,
        accountAvatar: data.picture,
      };
    } catch (error) {
      return { valid: false, error: error.message };
    }
  }

  // ============================================================
  // OAuthConnectable
  // ============================================================

  getConnectUrl(state: string): string {
    const clientId = this.configService.get<string>('LINKEDIN_CLIENT_ID');
    const redirectUri = this.configService.get<string>(
      'SOCIAL_OAUTH_CALLBACK_URL',
    );
    const scopes = ['openid', 'profile', 'w_member_social'].join(' ');

    return (
      `${LINKEDIN_AUTH_BASE}/authorization?` +
      `response_type=code` +
      `&client_id=${clientId}` +
      `&redirect_uri=${encodeURIComponent(redirectUri + '/linkedin')}` +
      `&scope=${encodeURIComponent(scopes)}` +
      `&state=${state}`
    );
  }

  async handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult> {
    const clientId = this.configService.get<string>('LINKEDIN_CLIENT_ID');
    const clientSecret = this.configService.get<string>(
      'LINKEDIN_CLIENT_SECRET',
    );

    const params = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: redirectUri,
      client_id: clientId!,
      client_secret: clientSecret!,
    });

    const response = await fetch(`${LINKEDIN_AUTH_BASE}/accessToken`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error) {
      throw new Error(
        `LinkedIn OAuth error: ${data.error_description || data.error}`,
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
    // LinkedIn access tokens from authorization_code are already long-lived (60 days)
    // No separate exchange needed
    return {
      token: shortToken,
      expiresAt: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000), // 60 days
    };
  }

  async listChannels(userAccessToken: string): Promise<PlatformChannel[]> {
    // Get user personal profile
    const profileRes = await fetch(`${LINKEDIN_API_BASE}/v2/userinfo`, {
      headers: { Authorization: `Bearer ${userAccessToken}` },
    });
    const profile = await profileRes.json();

    if (profile.error || !profile.sub) {
      throw new Error(
        `LinkedIn profile fetch error: ${profile.error_description || 'Unknown error'}`,
      );
    }

    return [
      {
        id: profile.sub,
        name: profile.name || 'Personal Profile',
        avatar: profile.picture,
        accessToken: userAccessToken,
        tokenExpiresAt: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000),
        metadata: { type: 'person', email: profile.email },
      },
    ];
  }

  // ============================================================
  // PostPublishable
  // ============================================================

  /**
   * Strip HTML tags and convert Markdown syntax to plain text.
   * LinkedIn's commentary field accepts plain text only — no HTML, no Markdown.
   */
  private toPlainText(text: string): string {
    // Strip HTML tags
    let plain = text.replace(/<[^>]+>/g, ' ');
    // Decode common HTML entities
    plain = plain
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&nbsp;/g, ' ')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'");
    // Strip Markdown headings (# Heading → Heading)
    plain = plain.replace(/^#{1,6}\s+/gm, '');
    // Strip bold/italic markers (**text**, __text__, *text*, _text_)
    plain = plain.replace(/(\*{1,3}|_{1,3})(.*?)\1/g, '$2');
    // Strip inline code
    plain = plain.replace(/`([^`]+)`/g, '$1');
    // Strip Markdown links [text](url) → text
    plain = plain.replace(/\[([^\]]+)\]\([^)]+\)/g, '$1');
    // Collapse multiple blank lines to a single blank line
    plain = plain.replace(/\n{3,}/g, '\n\n');
    return plain.trim();
  }

  async adaptContent(post: PublishPayload): Promise<Record<string, any>> {
    const payload: Record<string, any> = {};

    const MAX_COMMENTARY = 3000;
    // For image posts, use message only — title is not needed as LinkedIn shows
    // the first line of commentary as a visual header. Prepending title to image
    // posts pushes the commentary over LinkedIn's undocumented display threshold.
    const isImagePost = (post.mediaUrls?.length ?? 0) > 0;
    const rawMessage =
      !isImagePost && post.title
        ? `${post.title}\n\n${post.message}`
        : post.message;

    let fullMessage = this.toPlainText(rawMessage);

    if (fullMessage.length > MAX_COMMENTARY) {
      const truncated = fullMessage.substring(0, MAX_COMMENTARY - 3);
      const lastSpace = truncated.lastIndexOf(' ');
      fullMessage =
        (lastSpace > MAX_COMMENTARY * 0.8
          ? truncated.substring(0, lastSpace)
          : truncated) + '...';
    }

    if (post.mediaUrls?.length === 1) {
      // Single image → use singleImage API
      payload.type = 'singleImage';
      payload.message = fullMessage;
      payload.mediaUrls = post.mediaUrls;
    } else if (post.mediaUrls && post.mediaUrls.length > 1) {
      // Multiple images → use multiImage API (min 2, max 20)
      payload.type = 'multiImage';
      payload.message = fullMessage;
      payload.mediaUrls = post.mediaUrls;
    } else if (post.linkUrl) {
      payload.type = 'article';
      payload.message = fullMessage;
      payload.linkUrl = post.linkUrl;
      payload.title = post.title;
    } else {
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

      // Determine author URN
      const authorUrn = platformAccountId.startsWith('urn:li:')
        ? platformAccountId
        : `urn:li:person:${platformAccountId}`;

      let postBody: Record<string, any>;

      switch (payload.type) {
        case 'singleImage':
        case 'multiImage': {
          // Upload all images
          const imageAssets: string[] = [];
          for (const mediaUrl of payload.mediaUrls || []) {
            const initRes = await fetch(
              `${LINKEDIN_API_BASE}/rest/images?action=initializeUpload`,
              {
                method: 'POST',
                headers: {
                  Authorization: `Bearer ${accessToken}`,
                  'Content-Type': 'application/json',
                  'LinkedIn-Version': '202503',
                },
                body: JSON.stringify({
                  initializeUploadRequest: {
                    owner: authorUrn,
                  },
                }),
              },
            );
            const initData = await initRes.json();

            if (initData.value?.uploadUrl) {
              const imageResponse = await fetch(mediaUrl);
              const imageBuffer = await imageResponse.arrayBuffer();

              await fetch(initData.value.uploadUrl, {
                method: 'PUT',
                headers: {
                  Authorization: `Bearer ${accessToken}`,
                  'Content-Type': 'application/octet-stream',
                },
                body: imageBuffer,
              });

              imageAssets.push(initData.value.image);
            }
          }

          // Single image vs multi image content structure
          const content =
            imageAssets.length === 1
              ? { media: { id: imageAssets[0] } }
              : {
                  multiImage: {
                    images: imageAssets.map((asset: string) => ({
                      id: asset,
                    })),
                  },
                };

          postBody = {
            author: authorUrn,
            commentary: payload.message,
            visibility: 'PUBLIC',
            distribution: {
              feedDistribution: 'MAIN_FEED',
            },
            content,
            lifecycleState: 'PUBLISHED',
          };
          break;
        }

        case 'article':
          postBody = {
            author: authorUrn,
            commentary: payload.message,
            visibility: 'PUBLIC',
            distribution: {
              feedDistribution: 'MAIN_FEED',
            },
            content: {
              article: {
                source: payload.linkUrl,
                title: payload.title || '',
              },
            },
            lifecycleState: 'PUBLISHED',
          };
          break;

        default: // text
          postBody = {
            author: authorUrn,
            commentary: payload.message,
            visibility: 'PUBLIC',
            distribution: {
              feedDistribution: 'MAIN_FEED',
            },
            lifecycleState: 'PUBLISHED',
          };
      }

      this.logger.debug(
        `[publishPost] commentary length=${postBody.commentary?.length ?? 0} type=${payload.type} body bytes=${JSON.stringify(postBody).length}`,
      );

      const response = await fetch(`${LINKEDIN_API_BASE}/rest/posts`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
          'LinkedIn-Version': '202503',
        },
        body: JSON.stringify(postBody),
      });

      if (response.status === 201) {
        // LinkedIn API v202503 returns URN in x-linkedin-id header
        const postUrn =
          response.headers.get('x-linkedin-id') ||
          response.headers.get('x-restli-id') ||
          '';

        this.logger.debug(`[publishPost] Success — postUrn=${postUrn}`);

        return {
          success: true,
          platformPostId: postUrn,
          platformPostUrl: postUrn
            ? `https://www.linkedin.com/feed/update/${postUrn}`
            : '',
        };
      }

      const responseText = await response.text();
      this.logger.error(
        `[publishPost] LinkedIn API error status=${response.status} body=${responseText}`,
      );
      let errorData: any = {};
      try {
        errorData = JSON.parse(responseText);
      } catch {
        errorData = { message: responseText };
      }
      return {
        success: false,
        error: {
          code: String(response.status),
          message: errorData.message || 'Unknown LinkedIn API error',
          type: this.classifyError(response.status, errorData),
        },
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
      `${LINKEDIN_API_BASE}/rest/posts/${encodeURIComponent(platformPostId)}`,
      {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${credentials.accessToken}`,
          'LinkedIn-Version': '202503',
        },
      },
    );

    if (!response.ok) {
      const data = await response.json();
      throw new Error(
        `LinkedIn delete error: ${data.message || response.statusText}`,
      );
    }
  }

  // ============================================================
  // TokenRefreshable
  // ============================================================

  async refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }> {
    const clientId = this.configService.get<string>('LINKEDIN_CLIENT_ID');
    const clientSecret = this.configService.get<string>(
      'LINKEDIN_CLIENT_SECRET',
    );

    const params = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: credentials.refreshToken,
      client_id: clientId!,
      client_secret: clientSecret!,
    });

    const response = await fetch(`${LINKEDIN_AUTH_BASE}/accessToken`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString(),
    });
    const data = await response.json();

    if (data.error) {
      throw new Error(
        `LinkedIn token refresh error: ${data.error_description}`,
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
      maxRequests: 100,
      windowMs: 24 * 60 * 60 * 1000, // 24 hours
      perAccount: true,
    };
  }

  // ============================================================
  // MediaValidatable
  // ============================================================

  getMediaConstraints(): MediaConstraints {
    return {
      maxImageSizeBytes: 10 * 1024 * 1024, // 10MB
      maxVideoSizeBytes: 200 * 1024 * 1024, // 200MB
      supportedImageFormats: ['jpg', 'jpeg', 'png', 'gif'],
      supportedVideoFormats: ['mp4'],
      maxMediaCount: 9,
      maxMessageLength: 3000,
    };
  }

  // ============================================================
  // Private helpers
  // ============================================================

  private classifyError(status: number, _errorData: any): PublishErrorType {
    // 401 Unauthorized — token expired
    if (status === 401) {
      return PublishErrorType.AuthExpired;
    }

    // 429 Rate limited, 5xx Server errors — retryable
    if (status === 429 || status >= 500) {
      return PublishErrorType.Retryable;
    }

    // 400, 403, etc. — fatal
    return PublishErrorType.Fatal;
  }
}
