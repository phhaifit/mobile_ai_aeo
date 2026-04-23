import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { BetaAnalyticsDataClient } from '@google-analytics/data';
import { AnalyticsAdminServiceClient } from '@google-analytics/admin';
import { OAuth2Client } from 'google-auth-library';
import { GoogleService } from '../google/google.service';
import { GaRepository, GaProperty } from './google-analytics.repository';
import { GoogleOAuthCredential } from '../google-search-console/google-search-console.repository';
import { ConnectGaDto } from './dto/connect-ga.dto';
import { LinkPropertyDto } from './dto/link-property.dto';

const GA_SCOPE = 'https://www.googleapis.com/auth/analytics.readonly';

export interface GaPropertyInfo {
  propertyId: string;
  displayName: string;
  account: string;
}

export interface GaAnalyticsSummary {
  sessions: number;
  totalUsers: number;
  organicUsers: number;
  engagementRate: number;
  avgSessionDuration: number;
}

export interface GaLandingPageRow {
  pagePath: string;
  sessions: number;
  users: number;
  bounceRate: number;
  avgSessionDuration: number;
}

export interface GaTrendPoint {
  date: string;
  sessions: number;
  totalUsers: number;
  engagementRate: number;
}

@Injectable()
export class GaService {
  private readonly logger = new Logger(GaService.name);

  constructor(
    private readonly googleService: GoogleService,
    private readonly gaRepository: GaRepository,
  ) {}

  // ── OAuth Connection ──

  async handleOAuthCallback(
    userId: string,
    projectId: string,
    dto: ConnectGaDto,
  ): Promise<void> {
    const tokens = await this.googleService.exchangeCodeForTokens(
      dto.code,
      dto.codeVerifier,
      dto.redirectUri,
    );

    this.logger.log(
      `GA OAuth callback for project ${projectId}, scopes from Google: ${tokens.scopes.join(', ')}`,
    );

    const encryptedRefreshToken = this.googleService.encryptRefreshToken(
      tokens.refreshToken,
    );

    // Store scopes exactly as Google returned them (include_granted_scopes=true
    // should include previously granted scopes like GSC in the new token)
    await this.gaRepository.upsertCredential(
      userId,
      projectId,
      encryptedRefreshToken,
      tokens.scopes,
    );
  }

  async getConnectionStatus(projectId: string): Promise<{
    connected: boolean;
    hasGaScope: boolean;
    isValid: boolean;
  }> {
    const credential =
      await this.gaRepository.findCredentialByProjectId(projectId);

    if (!credential) {
      return { connected: false, hasGaScope: false, isValid: false };
    }

    const hasGaScope = credential.scopes.includes(GA_SCOPE);

    return {
      connected: hasGaScope,
      hasGaScope,
      isValid: credential.isValid,
    };
  }

  async disconnect(projectId: string): Promise<void> {
    await this.gaRepository.deleteProperty(projectId);
    // Only remove GA scope, preserve GSC and other scopes
    await this.gaRepository.removeScopesFromCredential(projectId, [GA_SCOPE]);
  }

  // ── Property Management ──

  async listProperties(projectId: string): Promise<GaPropertyInfo[]> {
    const credential = await this.getValidCredential(projectId);
    const oauth2Client = await this.createOAuth2Client(
      credential.encryptedRefreshToken,
    );

    const adminClient = new AnalyticsAdminServiceClient({
      authClient: oauth2Client as any,
      projectId: 'aeo',
    });

    const properties: GaPropertyInfo[] = [];

    try {
      const [accounts] = await this.callGoogleApi(projectId, () =>
        adminClient.listAccountSummaries(),
      );

      for (const account of accounts || []) {
        for (const propertySummary of account.propertySummaries || []) {
          if (propertySummary.property && propertySummary.displayName) {
            properties.push({
              propertyId: propertySummary.property,
              displayName: propertySummary.displayName,
              account: account.displayName || account.name || '',
            });
          }
        }
      }
    } catch (error) {
      this.logger.error(`Failed to list GA4 properties: ${error}`);
      throw error;
    }

    return properties;
  }

  async linkProperty(
    userId: string,
    dto: LinkPropertyDto,
  ): Promise<GaProperty> {
    const existing = await this.gaRepository.findPropertyByProjectId(
      dto.projectId,
    );
    if (existing) {
      throw new BadRequestException(
        'This project already has a linked GA4 property. Unlink it first.',
      );
    }

    // Verify user has access to this property
    const properties = await this.listProperties(dto.projectId);
    const property = properties.find((p) => p.propertyId === dto.propertyId);
    if (!property) {
      throw new NotFoundException(
        'Property not found in your Google Analytics account.',
      );
    }

    return this.gaRepository.createProperty(
      dto.projectId,
      userId,
      dto.propertyId,
      property.displayName,
    );
  }

  async getLinkedProperty(projectId: string): Promise<GaProperty | null> {
    return this.gaRepository.findPropertyByProjectId(projectId);
  }

  async unlinkProperty(userId: string, projectId: string): Promise<void> {
    const property = await this.gaRepository.findPropertyByProjectId(projectId);
    if (!property) {
      throw new NotFoundException('No GA4 property linked to this project.');
    }
    if (property.userId !== userId) {
      throw new BadRequestException(
        'Only the user who connected GA4 can unlink it.',
      );
    }

    await this.gaRepository.deleteProperty(projectId);
  }

  // ── Analytics (Live API Calls) ──

  async getAnalyticsSummary(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
  ): Promise<GaAnalyticsSummary> {
    const { client, property } = await this.getClientForProject(projectId);

    // Main metrics
    const [response] = await this.callGoogleApi(projectId, () =>
      client.runReport({
        property: property.propertyId,
        dateRanges: [{ startDate, endDate }],
        metrics: [
          { name: 'sessions' },
          { name: 'totalUsers' },
          { name: 'engagementRate' },
          { name: 'averageSessionDuration' },
        ],
      }),
    );

    // Organic users (filtered)
    const [organicResponse] = await this.callGoogleApi(projectId, () =>
      client.runReport({
        property: property.propertyId,
        dateRanges: [{ startDate, endDate }],
        metrics: [{ name: 'totalUsers' }],
        dimensionFilter: {
          filter: {
            fieldName: 'sessionDefaultChannelGroup',
            stringFilter: { matchType: 'EXACT', value: 'Organic Search' },
          },
        },
      }),
    );

    const row = response.rows?.[0];
    const organicRow = organicResponse.rows?.[0];

    return {
      sessions: Number(row?.metricValues?.[0]?.value) || 0,
      totalUsers: Number(row?.metricValues?.[1]?.value) || 0,
      engagementRate: Number(row?.metricValues?.[2]?.value) || 0,
      avgSessionDuration: Number(row?.metricValues?.[3]?.value) || 0,
      organicUsers: Number(organicRow?.metricValues?.[0]?.value) || 0,
    };
  }

  async getTopLandingPages(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
    rowLimit: number = 20,
  ): Promise<GaLandingPageRow[]> {
    const { client, property } = await this.getClientForProject(projectId);

    const [response] = await this.callGoogleApi(projectId, () =>
      client.runReport({
        property: property.propertyId,
        dateRanges: [{ startDate, endDate }],
        dimensions: [{ name: 'landingPage' }],
        metrics: [
          { name: 'sessions' },
          { name: 'totalUsers' },
          { name: 'bounceRate' },
          { name: 'averageSessionDuration' },
        ],
        orderBys: [{ metric: { metricName: 'sessions' }, desc: true }],
        limit: rowLimit,
      }),
    );

    return (response.rows || []).map((row) => ({
      pagePath: row.dimensionValues?.[0]?.value || '',
      sessions: Number(row.metricValues?.[0]?.value) || 0,
      users: Number(row.metricValues?.[1]?.value) || 0,
      bounceRate: Number(row.metricValues?.[2]?.value) || 0,
      avgSessionDuration: Number(row.metricValues?.[3]?.value) || 0,
    }));
  }

  async getDateTrend(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
  ): Promise<GaTrendPoint[]> {
    const { client, property } = await this.getClientForProject(projectId);

    const [response] = await this.callGoogleApi(projectId, () =>
      client.runReport({
        property: property.propertyId,
        dateRanges: [{ startDate, endDate }],
        dimensions: [{ name: 'date' }],
        metrics: [
          { name: 'sessions' },
          { name: 'totalUsers' },
          { name: 'engagementRate' },
        ],
        orderBys: [{ dimension: { dimensionName: 'date' } }],
        limit: 25000,
      }),
    );

    return (response.rows || []).map((row) => ({
      date: row.dimensionValues?.[0]?.value || '',
      sessions: Number(row.metricValues?.[0]?.value) || 0,
      totalUsers: Number(row.metricValues?.[1]?.value) || 0,
      engagementRate: Number(row.metricValues?.[2]?.value) || 0,
    }));
  }

  // ── Private Helpers ──

  private async callGoogleApi<T>(
    credentialProjectId: string,
    apiCall: () => Promise<T>,
  ): Promise<T> {
    try {
      return await apiCall();
    } catch (error: unknown) {
      const status = (error as { code?: number })?.code;

      if (status === 401 || status === 403 || status === 16 || status === 7) {
        // gRPC codes: 16 = UNAUTHENTICATED, 7 = PERMISSION_DENIED
        this.logger.warn(
          `Google API returned ${status} for project ${credentialProjectId}, marking credential as invalid`,
        );
        await this.gaRepository.setCredentialInvalid(credentialProjectId);
        throw new UnauthorizedException(
          'Your Google Analytics access has been revoked. Please reconnect.',
        );
      }

      this.logger.error(
        `Google API error for project ${credentialProjectId}: ${error instanceof Error ? error.message : String(error)}`,
      );
      throw error;
    }
  }

  private async createOAuth2Client(
    encryptedRefreshToken: string,
  ): Promise<OAuth2Client> {
    const accessToken = await this.googleService.getAccessTokenFromRefresh(
      encryptedRefreshToken,
    );
    const client = new OAuth2Client();
    client.setCredentials({ access_token: accessToken });
    return client;
  }

  private async createGaDataClient(
    projectId: string,
  ): Promise<BetaAnalyticsDataClient> {
    const credential = await this.getValidCredential(projectId);
    const oauth2Client = await this.createOAuth2Client(
      credential.encryptedRefreshToken,
    );

    return new BetaAnalyticsDataClient({
      authClient: oauth2Client as any,
      projectId: 'aeo',
    });
  }

  private async getClientForProject(projectId: string): Promise<{
    client: BetaAnalyticsDataClient;
    property: GaProperty;
  }> {
    const property = await this.gaRepository.findPropertyByProjectId(projectId);
    if (!property) {
      throw new NotFoundException('No GA4 property linked to this project.');
    }

    const client = await this.createGaDataClient(projectId);
    return { client, property };
  }

  private async getValidCredential(
    projectId: string,
  ): Promise<GoogleOAuthCredential> {
    const credential =
      await this.gaRepository.findCredentialByProjectId(projectId);

    if (!credential) {
      throw new UnauthorizedException(
        'Google Analytics is not connected. Please connect your account first.',
      );
    }

    if (!credential.isValid) {
      throw new UnauthorizedException(
        'Your Google Analytics connection has expired. Please reconnect.',
      );
    }

    if (!credential.scopes.includes(GA_SCOPE)) {
      throw new UnauthorizedException(
        'Google Analytics scope not granted. Please connect Google Analytics.',
      );
    }

    return credential;
  }
}
