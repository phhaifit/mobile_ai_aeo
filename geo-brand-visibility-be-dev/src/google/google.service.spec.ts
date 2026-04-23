import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { GoogleService } from './google.service';
import { OAuth2Client } from 'google-auth-library';
import { UnauthorizedException } from '@nestjs/common';
import { DEFAULT_LANGUAGE } from 'src/shared/constant';

jest.mock('google-auth-library');

describe('GoogleService', () => {
  let service: GoogleService;

  const mockTokens = {
    id_token: 'mock.id.token',
    access_token: 'mock.access.token',
  };

  const mockPayload = {
    sub: 'google-user-id',
    email: 'test@gmail.com',
    email_verified: true,
    name: 'Test User',
    given_name: 'Test',
    family_name: 'User',
    picture: 'https://example.com/photo.jpg',
    locale: DEFAULT_LANGUAGE,
  };

  const mockTicket = {
    getPayload: jest.fn(),
  };

  const mockOAuth2Client = {
    getToken: jest.fn(),
    verifyIdToken: jest.fn(),
  };

  const mockConfig = {
    GOOGLE_CLIENT_ID: 'mock-client-id',
    GOOGLE_CLIENT_SECRET: 'mock-client-secret',
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    // Reset mock implementations
    mockOAuth2Client.getToken.mockResolvedValue({ tokens: mockTokens });
    mockOAuth2Client.verifyIdToken.mockResolvedValue(mockTicket);
    mockTicket.getPayload.mockReturnValue(mockPayload);

    (OAuth2Client as unknown as jest.Mock).mockImplementation(
      () => mockOAuth2Client,
    );

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GoogleService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(
              (key: 'GOOGLE_CLIENT_ID' | 'GOOGLE_CLIENT_SECRET') =>
                mockConfig[key],
            ),
          },
        },
      ],
    }).compile();

    service = module.get<GoogleService>(GoogleService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('exchangeAuthorizationCode', () => {
    const mockCode = 'mock-auth-code';
    const mockCodeVerifier = 'mock-code-verifier';
    const mockRedirectUri = 'http://localhost:3000/callback';

    it('should successfully exchange authorization code and return profile', async () => {
      const result = await service.exchangeAuthorizationCode(
        mockCode,
        mockCodeVerifier,
        mockRedirectUri,
      );

      expect(result).toEqual({
        profile: {
          id: mockPayload.sub,
          email: mockPayload.email,
          verified_email: mockPayload.email_verified,
          name: mockPayload.name,
          given_name: mockPayload.given_name,
          family_name: mockPayload.family_name,
          picture: mockPayload.picture,
          locale: mockPayload.locale,
        },
        idToken: mockTokens.id_token,
      });

      expect(mockOAuth2Client.getToken).toHaveBeenCalledWith({
        code: mockCode,
        codeVerifier: mockCodeVerifier,
        redirect_uri: mockRedirectUri,
      });

      expect(mockOAuth2Client.verifyIdToken).toHaveBeenCalledWith({
        idToken: mockTokens.id_token,
        audience: 'mock-client-id',
      });
    });

    it('should throw UnauthorizedException when id_token is missing', async () => {
      mockOAuth2Client.getToken.mockResolvedValueOnce({
        tokens: { access_token: 'token' },
      });

      await expect(
        service.exchangeAuthorizationCode(
          mockCode,
          mockCodeVerifier,
          mockRedirectUri,
        ),
      ).rejects.toThrow(UnauthorizedException);

      expect(mockOAuth2Client.verifyIdToken).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when payload is missing', async () => {
      mockTicket.getPayload.mockReturnValueOnce(null);

      await expect(
        service.exchangeAuthorizationCode(
          mockCode,
          mockCodeVerifier,
          mockRedirectUri,
        ),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw error when token exchange fails', async () => {
      const error = new Error('Token exchange failed');
      mockOAuth2Client.getToken.mockRejectedValueOnce(error);

      await expect(
        service.exchangeAuthorizationCode(
          mockCode,
          mockCodeVerifier,
          mockRedirectUri,
        ),
      ).rejects.toThrow(error);

      expect(mockOAuth2Client.verifyIdToken).not.toHaveBeenCalled();
    });

    it('should throw error when token verification fails', async () => {
      const error = new Error('Token verification failed');
      mockOAuth2Client.verifyIdToken.mockRejectedValueOnce(error);

      await expect(
        service.exchangeAuthorizationCode(
          mockCode,
          mockCodeVerifier,
          mockRedirectUri,
        ),
      ).rejects.toThrow(error);
    });

    it('should handle missing optional profile fields', async () => {
      const minimalPayload = {
        sub: 'google-user-id',
        email: 'test@gmail.com',
      };

      mockTicket.getPayload.mockReturnValueOnce(minimalPayload);

      const result = await service.exchangeAuthorizationCode(
        mockCode,
        mockCodeVerifier,
        mockRedirectUri,
      );

      expect(result.profile).toEqual({
        id: minimalPayload.sub,
        email: minimalPayload.email,
        verified_email: false,
        name: '',
        given_name: '',
        family_name: '',
        picture: '',
        locale: '',
      });
    });

    it('should handle all missing profile fields', async () => {
      const emptyPayload = {
        sub: 'google-user-id',
      };

      mockTicket.getPayload.mockReturnValueOnce(emptyPayload);

      const result = await service.exchangeAuthorizationCode(
        mockCode,
        mockCodeVerifier,
        mockRedirectUri,
      );

      expect(result.profile).toEqual({
        id: emptyPayload.sub,
        email: '',
        verified_email: false,
        name: '',
        given_name: '',
        family_name: '',
        picture: '',
        locale: '',
      });
    });

    it('should throw error for invalid code verifier', async () => {
      const error = new Error('Invalid code_verifier');
      mockOAuth2Client.getToken.mockRejectedValueOnce(error);

      await expect(
        service.exchangeAuthorizationCode(
          mockCode,
          'invalid-verifier',
          mockRedirectUri,
        ),
      ).rejects.toThrow(error);
    });
  });
});
