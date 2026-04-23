import {
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { UserRepository } from '../user/user.repository';
import { TokenService } from '../token/token.service';
import { SignupRequestDto } from './dto/signup-request.dto';
import { SignupResponseDto } from './dto/signup-response.dto';
import { LoginRequestDto } from './dto/login-request.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { hashPassword, verifyPassword } from './utils/password.util';
import { GoogleService } from '../google/google.service';
import { GoogleLoginRequestDto } from './dto/google-login-request.dto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly userRepository: UserRepository,
    private readonly tokenService: TokenService,
    private readonly googleService: GoogleService,
  ) {}

  async signup(request: SignupRequestDto): Promise<SignupResponseDto> {
    const { email, fullName: fullname, password } = request;

    const existingUser = await this.userRepository.findByEmail(email);

    if (existingUser) {
      if (existingUser.googleId && !existingUser.passwordHash) {
        throw new ConflictException(
          'This email is registered with Google OAuth. Please sign in with Google.',
        );
      }
      throw new ConflictException('A user with this email already exists');
    }

    const passwordHash = await hashPassword(password);

    const user = await this.userRepository.create({
      fullname,
      email,
      passwordHash,
      isVerified: false,
    });

    return {
      success: true,
      message: 'User registered successfully.',
      userId: user.id,
    };
  }

  async login(request: LoginRequestDto): Promise<LoginResponseDto> {
    const { email, password } = request;

    const user = await this.userRepository.findByEmail(email);

    if (!user) {
      throw new UnauthorizedException('Invalid email');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException(
        'This account uses Google OAuth. Please sign in with Google.',
      );
    }

    const isPasswordValid = await verifyPassword(password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid password');
    }

    const { accessToken } = await this.tokenService.generateTokens(
      user.id,
      user.email,
    );

    return {
      accessToken,
    };
  }

  // async generateN8nToken(userId: string): Promise<LoginResponseDto> {
  //   // Assuming userId is valid (e.g., from admin context)
  //   const user = await this.userRepository.findById(userId);
  //   if (!user) {
  //     throw new UnauthorizedException('User not found');
  //   }

  //   const { accessToken } = await this.tokenService.generatePerpetualTokens(
  //     user.id,
  //     user.email,
  //   );

  //   return {
  //     accessToken,
  //   };
  // }

  async loginWithGoogle(
    request: GoogleLoginRequestDto,
  ): Promise<LoginResponseDto> {
    const { code, codeVerifier, redirectUri } = request;

    const { profile } = await this.googleService.exchangeAuthorizationCode(
      code,
      codeVerifier,
      redirectUri,
    );

    let user = await this.userRepository.findByGoogleId(profile.id);

    if (user) {
      user = await this.userRepository.updateById(user.id, {
        fullname: profile.name,
        avatar: profile.picture,
        isVerified: profile.verified_email,
      });
    } else {
      const userByEmail = await this.userRepository.findByEmail(profile.email);

      if (userByEmail) {
        if (userByEmail.googleId && userByEmail.googleId !== profile.id) {
          throw new ConflictException(
            'Email is already linked to another Google account.',
          );
        }

        user = await this.userRepository.updateById(userByEmail.id, {
          googleId: profile.id,
          fullname: profile.name,
          avatar: profile.picture,
          isVerified: profile.verified_email,
        });
      } else {
        user = await this.userRepository.create({
          email: profile.email,
          fullname: profile.name,
          googleId: profile.id,
          avatar: profile.picture,
          isVerified: profile.verified_email,
        });
      }
    }

    if (!user) {
      throw new UnauthorizedException('Google login failed');
    }

    const { accessToken } = await this.tokenService.generateTokens(
      user.id,
      user.email,
    );

    return {
      accessToken,
    };
  }
}
