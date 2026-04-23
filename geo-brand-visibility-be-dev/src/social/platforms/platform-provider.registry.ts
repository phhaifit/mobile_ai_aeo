import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { SocialPlatform } from '../enums';
import { PlatformProvider } from './platform-provider.interface';

@Injectable()
export class PlatformProviderRegistry {
  private readonly logger = new Logger(PlatformProviderRegistry.name);
  private readonly providers = new Map<SocialPlatform, PlatformProvider>();

  register(provider: PlatformProvider): void {
    this.providers.set(provider.platform, provider);
    this.logger.log(`Registered platform provider: ${provider.platform}`);
  }

  getProvider(platform: SocialPlatform): PlatformProvider {
    const provider = this.providers.get(platform);
    if (!provider) {
      throw new NotFoundException(
        `No provider registered for platform: ${platform}`,
      );
    }
    return provider;
  }

  getAllProviders(): PlatformProvider[] {
    return Array.from(this.providers.values());
  }

  hasProvider(platform: SocialPlatform): boolean {
    return this.providers.has(platform);
  }
}
