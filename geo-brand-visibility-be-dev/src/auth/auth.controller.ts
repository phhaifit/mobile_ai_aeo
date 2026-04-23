import { Controller, Post, Body, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { SignupRequestDto } from './dto/signup-request.dto';
import { SignupResponseDto } from './dto/signup-response.dto';
import { LoginRequestDto } from './dto/login-request.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { Public } from './decorators/public.decorator';
import { GoogleLoginRequestDto } from './dto/google-login-request.dto';
//import { N8nTokenRequestDto } from './dto/n8n-token-request.dto';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  @Public()
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'User successfully registered',
    type: SignupResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.CONFLICT,
    description: 'User with this email already exists',
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Invalid input data',
  })
  async signup(@Body() data: SignupRequestDto): Promise<SignupResponseDto> {
    return this.authService.signup(data);
  }

  @Post('login')
  @Public()
  @ApiOperation({ summary: 'Authenticate user and get access token' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'User successfully authenticated',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Invalid credentials',
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Invalid input data',
  })
  async login(@Body() data: LoginRequestDto): Promise<LoginResponseDto> {
    return this.authService.login(data);
  }

  @Post('login-google')
  @Public()
  @ApiOperation({
    summary: 'Login with Google OAuth2.0',
    description:
      'Exchange Google authorization code for access token using PKCE flow',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Successfully authenticated with Google',
    type: LoginResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description:
      'Invalid Google authorization code or PKCE verification failed',
  })
  @ApiResponse({
    status: HttpStatus.CONFLICT,
    description: 'Email already registered with standard login',
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Invalid input data or missing required fields',
  })
  async loginWithGoogle(@Body() data: GoogleLoginRequestDto) {
    return this.authService.loginWithGoogle(data);
  }

  // @Post('n8n-token')
  // @Public()
  // @ApiOperation({ summary: 'Generate perpetual token for n8n' })
  // @ApiResponse({ status: 200, type: LoginResponseDto })
  // async generateN8nToken(@Body() body: N8nTokenRequestDto) {
  //   return this.authService.generateN8nToken(body.userId);
  // }
}
