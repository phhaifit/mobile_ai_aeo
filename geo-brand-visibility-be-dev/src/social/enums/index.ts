export enum SocialPlatform {
  Facebook = 'facebook',
  Instagram = 'instagram',
  YouTube = 'youtube',
  TikTok = 'tiktok',
  X = 'x',
  LinkedIn = 'linkedin',
  Threads = 'threads',
  Pinterest = 'pinterest',
  Reddit = 'reddit',
  Telegram = 'telegram',
  Zalo = 'zalo',
  Line = 'line',
  Discord = 'discord',
  Slack = 'slack',
  WordPress = 'wordpress',
  Blogger = 'blogger',
  Medium = 'medium',
}

export enum ConnectionType {
  OAuth = 'oauth',
  Token = 'token',
  Webhook = 'webhook',
  Credentials = 'credentials',
}

export enum PostTargetStatus {
  Pending = 'PENDING',
  Queued = 'QUEUED',
  Publishing = 'PUBLISHING',
  Published = 'PUBLISHED',
  Failed = 'FAILED',
  Cancelled = 'CANCELLED',
}

export enum PublishErrorType {
  Retryable = 'RETRYABLE',
  Fatal = 'FATAL',
  AuthExpired = 'AUTH_EXPIRED',
  RateLimited = 'RATE_LIMITED',
  Duplicate = 'DUPLICATE',
}

export enum SocialPostSource {
  Manual = 'manual',
  AutoPublish = 'auto_publish',
}

export enum RateLimitErrorCode {
  DailyCap = 'RATE_LIMIT_DAILY_CAP',
  Spacing = 'RATE_LIMIT_SPACING',
  HardFloor = 'RATE_LIMIT_HARD_FLOOR',
  AccountCooldown = 'ACCOUNT_COOLDOWN',
  AccountInvalid = 'ACCOUNT_INVALID',
  AccountTokenExpired = 'ACCOUNT_TOKEN_EXPIRED',
  PlatformRateLimited = 'PLATFORM_RATE_LIMITED',
  PlatformBanned = 'PLATFORM_BANNED',
  OverrideRateLimited = 'OVERRIDE_RATE_LIMITED',
  UserOverrideSoft = 'USER_OVERRIDE_SOFT',
}

export enum CooldownReason {
  PlatformRateLimit = 'platform_rate_limit',
  CircuitBreaker = 'circuit_breaker',
  Manual = 'manual',
}
