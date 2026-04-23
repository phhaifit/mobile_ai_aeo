import { SocialPlatform } from '../enums';

export interface SafePublishConfig {
  maxPostsPerDay: number;
  minSpacingMinutes: number;
  errorCooldownHours: number;
}

export interface PlatformPeakHoursConfig {
  slots: string[];
  weekdaysOnly?: boolean;
}

const SAFE_PUBLISH_LIMITS: Partial<Record<SocialPlatform, SafePublishConfig>> =
  {
    [SocialPlatform.Facebook]: {
      maxPostsPerDay: 6,
      minSpacingMinutes: 60,
      errorCooldownHours: 24,
    },
    [SocialPlatform.LinkedIn]: {
      maxPostsPerDay: 3,
      minSpacingMinutes: 120,
      errorCooldownHours: 24,
    },
    [SocialPlatform.X]: {
      maxPostsPerDay: 15,
      minSpacingMinutes: 30,
      errorCooldownHours: 12,
    },
    [SocialPlatform.Instagram]: {
      maxPostsPerDay: 10,
      minSpacingMinutes: 60,
      errorCooldownHours: 24,
    },
    [SocialPlatform.TikTok]: {
      maxPostsPerDay: 5,
      minSpacingMinutes: 10,
      errorCooldownHours: 12,
    },
    [SocialPlatform.Threads]: {
      maxPostsPerDay: 10,
      minSpacingMinutes: 30,
      errorCooldownHours: 12,
    },
  };

const DEFAULT_SAFE_PUBLISH_CONFIG: SafePublishConfig = {
  maxPostsPerDay: 3,
  minSpacingMinutes: 60,
  errorCooldownHours: 24,
};

export function getSafePublishConfig(platform: string): SafePublishConfig {
  return (
    SAFE_PUBLISH_LIMITS[platform as SocialPlatform] ??
    DEFAULT_SAFE_PUBLISH_CONFIG
  );
}

const PLATFORM_PEAK_HOURS: Partial<
  Record<SocialPlatform, PlatformPeakHoursConfig>
> = {
  [SocialPlatform.Facebook]: {
    slots: ['09:00', '13:00', '17:00'],
  },
  [SocialPlatform.LinkedIn]: {
    slots: ['08:00', '12:00'],
    weekdaysOnly: true,
  },
  [SocialPlatform.X]: {
    slots: ['09:00', '12:00', '17:00', '20:00'],
  },
};

const DEFAULT_PEAK_HOURS: PlatformPeakHoursConfig = {
  slots: ['09:00', '12:00', '18:00'],
};

export function getPlatformPeakHours(
  platform: string,
): PlatformPeakHoursConfig {
  return PLATFORM_PEAK_HOURS[platform as SocialPlatform] ?? DEFAULT_PEAK_HOURS;
}

/** Maximum consecutive errors before auto-pausing an account */
export const MAX_CONSECUTIVE_ERRORS = 3;

/** Universal hard floor: minimum 15 minutes between any 2 posts on the same account */
export const HARD_FLOOR_MINUTES = 15;
