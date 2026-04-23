import { ConnectionType, PublishErrorType, SocialPlatform } from '../enums';

// ============================================================
// Base interface — every platform MUST implement
// ============================================================
export interface ConnectionFieldConfig {
  key: string;
  label: string;
  type: 'text' | 'password' | 'url' | 'textarea';
  required: boolean;
  helpText?: string;
  placeholder?: string;
}

export interface ConnectionConfig {
  connectionType: ConnectionType;
  platform: SocialPlatform;
  displayName: string;
  fields: ConnectionFieldConfig[];
}

export interface ValidationResult {
  valid: boolean;
  accountId?: string;
  accountName?: string;
  accountAvatar?: string;
  error?: string;
}

export interface PlatformProvider {
  readonly platform: SocialPlatform;
  readonly connectionType: ConnectionType;

  getConnectionConfig(): ConnectionConfig;
  validateConnection(
    credentials: Record<string, any>,
  ): Promise<ValidationResult>;
}

// ============================================================
// OAuth — only OAuth platforms implement
// ============================================================
export interface OAuthCallbackResult {
  userAccessToken: string;
  expiresAt: Date | null;
}

export interface PlatformChannel {
  id: string;
  name: string;
  avatar?: string;
  accessToken: string;
  tokenExpiresAt: Date | null;
  metadata?: Record<string, any>;
}

export interface OAuthConnectable {
  getConnectUrl(state: string): string;
  handleCallback(
    code: string,
    redirectUri: string,
  ): Promise<OAuthCallbackResult>;
  exchangeForLongLivedToken(
    shortToken: string,
  ): Promise<{ token: string; expiresAt: Date | null }>;
  listChannels(userAccessToken: string): Promise<PlatformChannel[]>;
}

// ============================================================
// Publishing — every platform that can publish implements this
// ============================================================
export interface PublishPayload {
  title?: string;
  message: string;
  mediaUrls?: string[];
  linkUrl?: string;
  metadata?: Record<string, any>;
}

export interface PublishResult {
  success: boolean;
  platformPostId?: string;
  platformPostUrl?: string;
  error?: {
    code: string;
    message: string;
    type: PublishErrorType;
  };
}

export interface PostPublishable {
  adaptContent(post: PublishPayload): Promise<Record<string, any>>;
  publishPost(
    credentials: Record<string, any>,
    platformAccountId: string,
    payload: Record<string, any>,
  ): Promise<PublishResult>;
}

// ============================================================
// Optional capabilities
// ============================================================
export interface PostDeletable {
  deletePost(
    credentials: Record<string, any>,
    platformPostId: string,
  ): Promise<void>;
}

export interface TokenRefreshable {
  refreshToken(
    credentials: Record<string, any>,
  ): Promise<{ credentials: Record<string, any>; expiresAt: Date | null }>;
}

export interface RateLimitConfig {
  maxRequests: number;
  windowMs: number;
  perAccount: boolean;
}

export interface RateLimitable {
  getRateLimitConfig(): RateLimitConfig;
}

export interface MediaConstraints {
  maxImageSizeBytes: number;
  maxVideoSizeBytes: number;
  supportedImageFormats: string[];
  supportedVideoFormats: string[];
  maxMediaCount: number;
  maxMessageLength: number;
}

export interface MediaValidatable {
  getMediaConstraints(): MediaConstraints;
}

// ============================================================
// Type guards
// ============================================================
export function isOAuthConnectable(
  provider: PlatformProvider,
): provider is PlatformProvider & OAuthConnectable {
  return (
    'getConnectUrl' in provider &&
    'handleCallback' in provider &&
    'listChannels' in provider
  );
}

export function isPostPublishable(
  provider: PlatformProvider,
): provider is PlatformProvider & PostPublishable {
  return 'publishPost' in provider && 'adaptContent' in provider;
}

export function isPostDeletable(
  provider: PlatformProvider,
): provider is PlatformProvider & PostDeletable {
  return 'deletePost' in provider;
}

export function isTokenRefreshable(
  provider: PlatformProvider,
): provider is PlatformProvider & TokenRefreshable {
  return 'refreshToken' in provider;
}

export function isRateLimitable(
  provider: PlatformProvider,
): provider is PlatformProvider & RateLimitable {
  return 'getRateLimitConfig' in provider;
}

export function isMediaValidatable(
  provider: PlatformProvider,
): provider is PlatformProvider & MediaValidatable {
  return 'getMediaConstraints' in provider;
}
