import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { UserRepository } from '../user/user.repository';
import { TokenService } from '../token/token.service';
import { GoogleService } from '../google/google.service';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import type { Tables } from '../supabase/supabase.types';
import * as passwordUtils from './utils/password.util';

type User = Tables<'User'>;

describe('AuthService', () => {
  let service: AuthService;

  const mockUser: User = {
    id: 'user-id',
    email: 'test@example.com',
    fullname: 'Test User',
    passwordHash: 'hashed_password',
    googleId: null,
    isVerified: false,
    avatar: 'https://example.com/avatar.png',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const mockUserRepository = {
    findByEmail: jest.fn(),
    findByGoogleId: jest.fn(),
    create: jest.fn(),
    updateById: jest.fn(),
  };

  const mockTokenService = {
    generateTokens: jest.fn(),
  };

  const mockGoogleService = {
    exchangeAuthorizationCode: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UserRepository,
          useValue: mockUserRepository,
        },
        {
          provide: TokenService,
          useValue: mockTokenService,
        },
        {
          provide: GoogleService,
          useValue: mockGoogleService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);

    jest.spyOn(passwordUtils, 'hashPassword');
    jest.spyOn(passwordUtils, 'verifyPassword');
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('signup', () => {
    const signupRequest = {
      email: 'test@example.com',
      fullName: 'Test User',
      password: 'password123',
    };

    it('should throw ConflictException when email exists', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);

      await expect(service.signup(signupRequest)).rejects.toThrow(
        new ConflictException('A user with this email already exists'),
      );

      expect(mockUserRepository.create).not.toHaveBeenCalled();
    });

    it('should create user successfully', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(null);
      jest
        .spyOn(passwordUtils, 'hashPassword')
        .mockResolvedValue('hashed_password');
      mockUserRepository.create.mockResolvedValue(mockUser);

      const result = await service.signup(signupRequest);

      expect(result).toEqual({
        success: true,
        message: 'User registered successfully.',
        userId: mockUser.id,
      });
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        email: signupRequest.email,
        fullname: signupRequest.fullName,
        passwordHash: 'hashed_password',
        isVerified: false,
      });
    });
  });

  describe('login', () => {
    const loginRequest = {
      email: 'test@example.com',
      password: 'password123',
    };

    const mockTokens = {
      accessToken: 'mock.access.token',
    };

    it('should throw UnauthorizedException when email not exists', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(null);

      await expect(service.login(loginRequest)).rejects.toThrow(
        new UnauthorizedException('Invalid email'),
      );

      expect(mockTokenService.generateTokens).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when password is invalid', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      jest.spyOn(passwordUtils, 'verifyPassword').mockResolvedValue(false);

      await expect(service.login(loginRequest)).rejects.toThrow(
        new UnauthorizedException('Invalid password'),
      );

      expect(mockTokenService.generateTokens).not.toHaveBeenCalled();
    });

    it('should login successfully', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      jest.spyOn(passwordUtils, 'verifyPassword').mockResolvedValue(true);
      mockTokenService.generateTokens.mockResolvedValue(mockTokens);

      const result = await service.login(loginRequest);

      expect(result).toEqual({
        accessToken: mockTokens.accessToken,
      });
      expect(mockTokenService.generateTokens).toHaveBeenCalledWith(
        mockUser.id,
        mockUser.email,
      );
    });
  });

  describe('loginWithGoogle', () => {
    const googleLoginRequest = {
      code: 'google-auth-code',
      codeVerifier: 'code-verifier',
      redirectUri: 'http://localhost:3000',
    };

    const mockGoogleProfile = {
      id: 'google-123',
      email: 'test@gmail.com',
      name: 'Test Google User',
      picture: 'https://example.com/avatar.jpg',
      verified_email: true,
    };

    const mockTokens = {
      accessToken: 'mock.access.token',
    };

    it('should create new user when Google ID not exists', async () => {
      mockGoogleService.exchangeAuthorizationCode.mockResolvedValue({
        profile: mockGoogleProfile,
      });
      mockUserRepository.findByGoogleId.mockResolvedValue(null);
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue({
        ...mockUser,
        googleId: mockGoogleProfile.id,
      });
      mockTokenService.generateTokens.mockResolvedValue(mockTokens);

      const result = await service.loginWithGoogle(googleLoginRequest);

      expect(result).toEqual({
        accessToken: mockTokens.accessToken,
      });
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        email: mockGoogleProfile.email,
        fullname: mockGoogleProfile.name,
        googleId: mockGoogleProfile.id,
        avatar: mockGoogleProfile.picture,
        isVerified: mockGoogleProfile.verified_email,
      });
    });

    it('should update existing user when Google ID exists', async () => {
      const existingUser = {
        ...mockUser,
        googleId: mockGoogleProfile.id,
        avatar: mockGoogleProfile.picture,
      };

      mockGoogleService.exchangeAuthorizationCode.mockResolvedValue({
        profile: mockGoogleProfile,
      });
      mockUserRepository.findByGoogleId.mockResolvedValue(existingUser);
      mockUserRepository.updateById.mockResolvedValue(existingUser);
      mockTokenService.generateTokens.mockResolvedValue(mockTokens);

      const result = await service.loginWithGoogle(googleLoginRequest);

      expect(result).toEqual({
        accessToken: mockTokens.accessToken,
      });
      expect(mockUserRepository.updateById).toHaveBeenCalledWith(
        existingUser.id,
        {
          fullname: mockGoogleProfile.name,
          avatar: mockGoogleProfile.picture,
          isVerified: mockGoogleProfile.verified_email,
        },
      );
    });

    it('should throw UnauthorizedException when Google auth fails', async () => {
      const error = new UnauthorizedException('Invalid Google token');
      mockGoogleService.exchangeAuthorizationCode.mockRejectedValue(error);

      await expect(service.loginWithGoogle(googleLoginRequest)).rejects.toThrow(
        error,
      );

      expect(mockUserRepository.findByGoogleId).not.toHaveBeenCalled();
      expect(mockUserRepository.create).not.toHaveBeenCalled();
      expect(mockUserRepository.updateById).not.toHaveBeenCalled();
      expect(mockTokenService.generateTokens).not.toHaveBeenCalled();
    });
  });
});
