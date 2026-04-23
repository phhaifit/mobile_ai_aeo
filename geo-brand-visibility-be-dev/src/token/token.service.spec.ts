import { Test, TestingModule } from '@nestjs/testing';
import { TokenService, TokenPayload } from './token.service';
import { JwtService } from '@nestjs/jwt';

describe('TokenService', () => {
  let service: TokenService;

  const mockUser = {
    id: 'test-user-id',
    email: 'test@example.com',
  };

  const mockToken = 'mock.jwt.token';
  const mockPayload: TokenPayload = {
    sub: mockUser.id,
    email: mockUser.email,
  };

  const mockJwtService = {
    signAsync: jest.fn(),
    verifyAsync: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TokenService,
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
      ],
    }).compile();

    service = module.get<TokenService>(TokenService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('generateToken', () => {
    it('should generate token successfully', async () => {
      mockJwtService.signAsync.mockResolvedValue(mockToken);

      const result = await service.generateTokens(mockUser.id, mockUser.email);

      expect(result).toEqual({ accessToken: mockToken });
      expect(mockJwtService.signAsync).toHaveBeenCalledWith({
        sub: mockUser.id,
        email: mockUser.email,
      });
    });
  });

  describe('validateToken', () => {
    it('should validate token successfully', async () => {
      mockJwtService.verifyAsync.mockResolvedValue(mockPayload);

      const result = await service.validateToken(mockToken);

      expect(result).toEqual(mockPayload);
      expect(mockJwtService.verifyAsync).toHaveBeenCalledWith(mockToken);
    });

    it('should throw UnauthorizedException for invalid token', async () => {
      mockJwtService.verifyAsync.mockRejectedValue(new Error('Invalid token'));

      await expect(service.validateToken(mockToken)).rejects.toThrow();
    });
  });

  describe('generateTokens', () => {
    it('should generate tokens successfully', async () => {
      mockJwtService.signAsync.mockResolvedValue(mockToken);

      const result = await service.generateTokens(mockUser.id, mockUser.email);

      expect(result).toEqual({
        accessToken: mockToken,
      });
      expect(mockJwtService.signAsync).toHaveBeenCalledWith({
        sub: mockUser.id,
        email: mockUser.email,
      });
    });
  });
});
