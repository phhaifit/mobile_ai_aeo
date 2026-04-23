# GEO User Signup API Endpoint Development Plan

## Overview

The User Signup API Endpoint is a core component of the Generative Engine Optimization (GEO) Platform's authentication system. This REST API endpoint enables new users to create accounts with secure credential storage and email verification functionality. Built on NestJS with Prisma ORM for Supabase database interactions, it handles user registration, input validation, secure credential storage, and email verification.

## 1. Project Setup

- [x] Initialize authentication module structure
  - [x] Create auth module folder structure (`src/auth/`)
  - [x] Generate auth module using NestJS CLI: `nest g module auth`
  - [x] Set up folder organization following NestJS best practices (controllers, services, dto, entities)

- [x] Initialize user module structure
  - [x] Create user module folder structure (`src/user/`)
  - [x] Generate user module using NestJS CLI: `nest g module user`
  - [x] Set up folder organization (services, dto, entities)

- [ ] Initialize email module structure
  - [ ] Create email module folder structure (`src/email/`)
  - [ ] Generate email module using NestJS CLI: `nest g module email`
  - [ ] Set up folder organization (services, templates)

- [ ] Initialize token module structure
  - [ ] Create token module folder structure (`src/token/`)
  - [ ] Generate token module using NestJS CLI: `nest g module token`
  - [ ] Set up folder organization (services, interfaces)

- [ ] Set up utilities structure
  - [x] Create utils directory (`src/utils/`)
  - [ ] Set up utility files:
    - [x] `src/utils/password.util.ts` - Password hashing and verification
    - [ ] `src/utils/validation.util.ts` - Custom validators and validation helpers
  - [ ] Create index.ts file for clean exports

- [x] Database schema extension
  - [x] Add User model to Prisma schema

    ```prisma
    model User {
      id          String    @id @default(uuid())
      fullName    String
      email       String    @unique
      passwordHash String
      isVerified  Boolean   @default(false)
      createdAt   DateTime  @default(now())
      updatedAt   DateTime  @updatedAt

      @@index([email])
    }
    ```

  - [x] Generate Prisma client after schema update: `pnpm prisma generate`
  - [x] Create migration for new models: `pnpm prisma migrate dev --name add_user_models`

- [ ] Environment configuration
  - [ ] Update environment variables in .env file
    - [ ] Add EMAIL_SERVICE_API_KEY for email provider
    - [ ] Add EMAIL_FROM_ADDRESS for verification emails
    - [x] Add JWT_SECRET for token signing
    - [x] Add JWT_VERIFICATION_EXPIRY (default: 24h)
  - [ ] Update env-sample with new variables (without actual values)
  - [ ] Create config service for environment variable validation and access

- [ ] Dependency management
  - [ ] Install required packages:
    - [x] `bcrypt` for password hashing
    - [x] `class-validator` and `class-transformer` for DTO validation
    - [ ] `@nestjs/throttler` for rate limiting
    - [ ] `nodemailer` or similar for email sending
    - [x] `@nestjs/jwt` for JWT token generation and verification
    - [x] `@nestjs/config` for environment configuration

## 2. Backend Foundation

- [ ] Create core interfaces and types
  - [x] Define User entity interface matching Prisma schema
  - [x] Create authentication service interfaces
  - [x] Define request/response DTOs with validation decorators
  - [x] Create custom types for authentication flows
  - [ ] Define JWT payload interface for verification tokens

- [x] Implement UserService
  - [x] Create UserService class with CRUD operations

    ```typescript
    // src/user/services/user.service.ts
    import { Injectable } from '@nestjs/common';
    import { PrismaService } from '../../prisma/prisma.service';
    import { User } from '@prisma/client';

    @Injectable()
    export class UserService {
      constructor(private readonly prismaService: PrismaService) {}

      async findByEmail(email: string): Promise<User | null> {
        return this.prismaService.user.findUnique({
          where: { email },
        });
      }

      async create(userData: {
        fullName: string;
        email: string;
        passwordHash: string;
      }): Promise<User> {
        return this.prismaService.user.create({
          data: {
            ...userData,
            isVerified: false,
          },
        });
      }

      async markAsVerified(userId: string): Promise<User> {
        return this.prismaService.user.update({
          where: { id: userId },
          data: { isVerified: true },
        });
      }

      async findById(id: string): Promise<User | null> {
        return this.prismaService.user.findUnique({
          where: { id },
        });
      }
    }
    ```

  - [x] Set up UserModule with proper exports

    ```typescript
    // src/user/user.module.ts
    import { Module } from '@nestjs/common';
    import { UserService } from './services/user.service';
    import { PrismaModule } from '../prisma/prisma.module';

    @Module({
      imports: [PrismaModule],
      providers: [UserService],
      exports: [UserService],
    })
    export class UserModule {}
    ```

  - [x] Create user-related DTOs and interfaces

- [ ] Implement EmailService
  - [ ] Create EmailService class

    ```typescript
    // src/email/services/email.service.ts
    import { Injectable } from '@nestjs/common';
    import { ConfigService } from '@nestjs/config';
    import * as nodemailer from 'nodemailer';

    @Injectable()
    export class EmailService {
      private transporter: nodemailer.Transporter;

      constructor(private readonly configService: ConfigService) {
        this.transporter = nodemailer.createTransport({
          // Configure based on email provider
          service: this.configService.get<string>('EMAIL_SERVICE'),
          auth: {
            user: this.configService.get<string>('EMAIL_USER'),
            pass: this.configService.get<string>('EMAIL_SERVICE_API_KEY'),
          },
        });
      }

      async sendVerificationEmail(
        to: string,
        name: string,
        token: string,
      ): Promise<void> {
        const verificationUrl = `${this.configService.get<string>('APP_URL')}/api/auth/verify?token=${token}`;

        await this.transporter.sendMail({
          from: this.configService.get<string>('EMAIL_FROM_ADDRESS'),
          to,
          subject: 'Verify your email address',
          html: this.getVerificationEmailTemplate(name, verificationUrl),
        });
      }

      private getVerificationEmailTemplate(
        name: string,
        verificationUrl: string,
      ): string {
        return `
          <h1>Email Verification</h1>
          <p>Hello ${name},</p>
          <p>Thank you for registering. Please click the link below to verify your email address:</p>
          <p><a href="${verificationUrl}">Verify Email</a></p>
          <p>This link will expire in 24 hours.</p>
          <p>If you did not create an account, please ignore this email.</p>
        `;
      }
    }
    ```

  - [ ] Set up EmailModule with proper exports

    ```typescript
    // src/email/email.module.ts
    import { Module, Global } from '@nestjs/common';
    import { EmailService } from './services/email.service';
    import { ConfigModule } from '@nestjs/config';

    @Global()
    @Module({
      imports: [ConfigModule],
      providers: [EmailService],
      exports: [EmailService],
    })
    export class EmailModule {}
    ```

  - [ ] Create email templates
  - [ ] Add error handling for email delivery failures

- [ ] Implement TokenService
  - [ ] Create TokenService class

    ```typescript
    // src/token/services/token.service.ts
    import { Injectable } from '@nestjs/common';
    import { JwtService } from '@nestjs/jwt';
    import { ConfigService } from '@nestjs/config';

    export interface VerificationPayload {
      userId: string;
      email: string;
      type: 'email_verification';
    }

    @Injectable()
    export class TokenService {
      constructor(
        private readonly jwtService: JwtService,
        private readonly configService: ConfigService,
      ) {}

      generateVerificationToken(userId: string, email: string): string {
        const payload: VerificationPayload = {
          userId,
          email,
          type: 'email_verification',
        };

        return this.jwtService.sign(payload, {
          secret: this.configService.get<string>('JWT_SECRET'),
          expiresIn: this.configService.get<string>(
            'JWT_VERIFICATION_EXPIRY',
            '24h',
          ),
        });
      }

      verifyToken(token: string): VerificationPayload {
        try {
          return this.jwtService.verify<VerificationPayload>(token, {
            secret: this.configService.get<string>('JWT_SECRET'),
          });
        } catch (error) {
          throw new Error('Verification token is invalid or expired');
        }
      }
    }
    ```

  - [ ] Set up TokenModule with proper exports

    ```typescript
    // src/token/token.module.ts
    import { Module, Global } from '@nestjs/common';
    import { JwtModule } from '@nestjs/jwt';
    import { ConfigModule, ConfigService } from '@nestjs/config';
    import { TokenService } from './services/token.service';

    @Global()
    @Module({
      imports: [
        JwtModule.registerAsync({
          imports: [ConfigModule],
          inject: [ConfigService],
          useFactory: (configService: ConfigService) => ({
            secret: configService.get<string>('JWT_SECRET'),
            signOptions: {
              expiresIn: configService.get<string>(
                'JWT_VERIFICATION_EXPIRY',
                '24h',
              ),
            },
          }),
        }),
      ],
      providers: [TokenService],
      exports: [TokenService],
    })
    export class TokenModule {}
    ```

  - [ ] Create token-related interfaces and types

- [ ] Implement core utilities as functions
  - [x] Create password utilities

    ```typescript
    // src/utils/password.util.ts
    import * as bcrypt from 'bcrypt';

    const SALT_ROUNDS = 10;

    export async function hashPassword(password: string): Promise<string> {
      return bcrypt.hash(password, SALT_ROUNDS);
    }

    export async function verifyPassword(
      password: string,
      hash: string,
    ): Promise<boolean> {
      return bcrypt.compare(password, hash);
    }
    ```

  - [ ] Create validation utilities

    ```typescript
    // src/utils/validation.util.ts

    // Industry standard email regex pattern
    const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    export function isValidEmail(email: string): boolean {
      return EMAIL_REGEX.test(email);
    }
    ```

- [x] Set up authentication module
  - [x] Create auth.module.ts with required imports and providers

    ```typescript
    // src/auth/auth.module.ts
    import { Module } from '@nestjs/common';
    import { ConfigModule } from '@nestjs/config';
    import { UserModule } from '../user/user.module';
    import { EmailModule } from '../email/email.module';
    import { TokenModule } from '../token/token.module';
    import { AuthService } from './services/auth.service';
    import { AuthController } from './controllers/auth.controller';

    @Module({
      imports: [UserModule, EmailModule, TokenModule, ConfigModule],
      providers: [AuthService],
      controllers: [AuthController],
      exports: [AuthService],
    })
    export class AuthModule {}
    ```

  - [x] Set up dependency injection for auth services
  - [x] Configure module exports for use in other modules

- [x] Update app.module.ts

  ```typescript
  // src/app.module.ts
  import { Module } from '@nestjs/common';
  import { PrismaModule } from './prisma/prisma.module';
  import { SwaggerModule } from '@nestjs/swagger';
  import { EmailModule } from './email/email.module';
  import { TokenModule } from './token/token.module';
  import { AuthModule } from './auth/auth.module';
  import { UserModule } from './user/user.module';
  import { ConfigModule } from '@nestjs/config';

  @Module({
    imports: [
      ConfigModule.forRoot({
        isGlobal: true,
      }),
      PrismaModule,
      SwaggerModule,
      EmailModule,
      TokenModule,
      AuthModule,
      UserModule,
    ],
    providers: [],
  })
  export class AppModule {}
  ```

## 3. Feature-specific Backend Implementation

- [ ] Create data transfer objects (DTOs)
  - [x] SignupRequestDto with validation decorators

    ```typescript
    // src/auth/dto/signup-request.dto.ts
    import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
    import { ApiProperty } from '@nestjs/swagger';

    export class SignupRequestDto {
      @ApiProperty({
        description: 'Full name of the user',
        example: 'John Doe',
      })
      @IsNotEmpty()
      @IsString()
      fullName: string;

      @ApiProperty({
        description: 'Email address of the user',
        example: 'john.doe@example.com',
      })
      @IsNotEmpty()
      @IsEmail()
      email: string;

      @ApiProperty({
        description: 'Password for the account',
        example: 'StrongP@ss123',
      })
      @IsNotEmpty()
      @IsString()
      password: string;
    }
    ```

  - [x] SignupResponseDto for standardized responses
  - [ ] EmailVerificationDto for verification requests
  - [ ] Custom validation pipes for specific requirements

- [ ] Implement auth service
  - [ ] Create AuthService class with signup method

    ```typescript
    // src/auth/services/auth.service.ts
    import { Injectable } from '@nestjs/common';
    import { ConfigService } from '@nestjs/config';
    import { UserService } from '../../user/services/user.service';
    import { EmailService } from '../../email/services/email.service';
    import { TokenService } from '../../token/services/token.service';
    import { SignupRequestDto } from '../dto/signup-request.dto';
    import { SignupResponseDto } from '../dto/signup-response.dto';
    import { UserAlreadyExistsException } from '../exceptions/user-already-exists.exception';
    import { hashPassword } from '../../utils/password.util';

    @Injectable()
    export class AuthService {
      constructor(
        private readonly userService: UserService,
        private readonly emailService: EmailService,
        private readonly tokenService: TokenService,
        private readonly configService: ConfigService,
      ) {}

      async signup(
        signupRequestDto: SignupRequestDto,
      ): Promise<SignupResponseDto> {
        // Check if email already exists using UserService
        const existingUser = await this.userService.findByEmail(
          signupRequestDto.email,
        );

        if (existingUser) {
          throw new UserAlreadyExistsException();
        }

        // Hash password using utility function
        const passwordHash = await hashPassword(signupRequestDto.password);

        // Create user via UserService
        const user = await this.userService.create({
          fullName: signupRequestDto.fullName,
          email: signupRequestDto.email,
          passwordHash,
        });

        // Generate verification token using TokenService
        const verificationToken = this.tokenService.generateVerificationToken(
          user.id,
          user.email,
        );

        // Send verification email using EmailService
        await this.emailService.sendVerificationEmail(
          user.email,
          user.fullName,
          verificationToken,
        );

        return {
          success: true,
          message:
            'User registered successfully. Please check your email for verification.',
          userId: user.id,
        };
      }

      async verifyEmail(token: string): Promise<boolean> {
        // Verify JWT token using TokenService
        const payload = this.tokenService.verifyToken(token);

        // Update user verification status via UserService
        await this.userService.markAsVerified(payload.userId);

        return true;
      }

      async resendVerificationEmail(email: string): Promise<boolean> {
        const user = await this.userService.findByEmail(email);

        if (!user || user.isVerified) {
          return false;
        }

        // Generate new token using TokenService
        const verificationToken = this.tokenService.generateVerificationToken(
          user.id,
          user.email,
        );

        // Send email using EmailService
        await this.emailService.sendVerificationEmail(
          user.email,
          user.fullName,
          verificationToken,
        );

        return true;
      }
    }
    ```

  - [x] Add email uniqueness verification via UserService
  - [x] Use password utility functions for secure password hashing
  - [x] Add user record creation via UserService
  - [ ] Use TokenService for JWT verification token generation
  - [ ] Use EmailService for verification email sending

- [ ] Create auth controller
  - [x] Implement POST /api/auth/signup endpoint
  - [ ] Add GET /api/auth/verify endpoint
  - [ ] Create POST /api/auth/resend-verification endpoint
  - [ ] Set up proper HTTP status codes and response formats
  - [ ] Add Swagger documentation for each endpoint

- [ ] Implement email verification flow
  - [ ] Use TokenService for JWT verification token generation
  - [ ] Add verification endpoint handler
    ```typescript
    // Example implementation in AuthController
    @Get('verify')
    async verifyEmail(@Query('token') token: string): Promise<VerificationResponseDto> {
      // Verify JWT token and update user via AuthService
      await this.authService.verifyEmail(token);

      return {
        success: true,
        message: 'Email verified successfully.',
      };
    }
    ```
  - [ ] Implement account status update on successful verification via UserService
  - [ ] Add token expiration handling

- [ ] Create custom exceptions and filters
  - [x] Implement UserAlreadyExistsException
  - [ ] Create InvalidTokenException
  - [ ] Add ExpiredTokenException
  - [ ] Implement global exception filter for consistent error responses

## 4. Security and Performance

- [ ] Implement rate limiting
  - [ ] Configure ThrottlerModule in app.module.ts

    ```typescript
    // src/app.module.ts
    import { ThrottlerModule } from '@nestjs/throttler';

    @Module({
      imports: [
        // ... existing imports
        ThrottlerModule.forRoot([
          {
            ttl: 60000, // 1 minute
            limit: 5, // 5 requests per minute
          },
        ]),
      ],
    })
    export class AppModule {}
    ```

  - [ ] Create custom ThrottlerGuard for different endpoints
  - [ ] Implement IP-based tracking for rate limits
  - [ ] Add rate limit headers to responses

- [ ] Set up security headers and middleware
  - [ ] Configure Helmet for security headers
  - [ ] Implement CORS policies
  - [ ] Add request validation middleware
  - [ ] Set up input sanitization

- [ ] Configure logging and monitoring
  - [ ] Create custom logger service for auth events
  - [ ] Implement sensitive data masking in logs
  - [ ] Set up structured logging format
  - [ ] Add request tracking with correlation IDs

- [ ] Optimize database queries
  - [ ] Ensure proper indexes are created
  - [ ] Optimize Prisma queries for performance
  - [ ] Implement connection pooling configuration
  - [ ] Add query caching where appropriate

## 5. Testing

- [ ] Set up testing environment
  - [ ] Configure Jest for unit and integration tests
  - [ ] Set up test database with Prisma
  - [ ] Create test utilities and helpers
  - [ ] Implement test data factories

- [ ] Write unit tests
  - [x] Test UserService methods
  - [x] Test EmailService methods
  - [x] Test TokenService methods
  - [ ] Test utility functions in src/utils
    - [ ] Test password hashing and verification functions
    - [ ] Test validation utility functions
  - [ ] Validate email format validation logic
  - [ ] Verify DTO validation rules

- [ ] Create integration tests
  - [ ] Test signup flow end-to-end
  - [ ] Verify email verification process
  - [ ] Test rate limiting functionality
  - [ ] Validate error handling scenarios

- [ ] Implement E2E tests
  - [ ] Set up E2E test environment
  - [ ] Create test suite for signup endpoint
  - [ ] Test verification flow
  - [ ] Verify error responses match specifications

- [ ] Perform security testing
  - [ ] Test password storage security
  - [ ] Verify JWT token security
  - [ ] Test rate limiting effectiveness
  - [ ] Check input validation and sanitization
  - [ ] Test for common security vulnerabilities

## 6. Documentation

- [ ] Create API documentation
  - [ ] Update Swagger configuration with auth endpoints
  - [ ] Add detailed descriptions for each endpoint
  - [ ] Document request/response formats with examples
  - [ ] Add error code documentation

- [ ] Write code documentation
  - [ ] Add JSDoc comments to key functions and classes
  - [ ] Document complex business logic
  - [ ] Create README with setup instructions
  - [ ] Document environment variables

- [ ] Create architecture documentation
  - [ ] Document authentication flow
  - [ ] Create database schema diagrams
  - [ ] Document security measures
  - [ ] Add sequence diagrams for key processes
  - [ ] Document utility functions and their usage

## 7. Deployment and Operations

- [ ] Prepare for deployment
  - [ ] Create deployment scripts
  - [ ] Configure environment variables for production
  - [ ] Set up database migrations for deployment
  - [ ] Create rollback procedures

- [ ] Set up monitoring and alerting
  - [ ] Configure performance monitoring
  - [ ] Set up error tracking
  - [ ] Create alerts for critical issues
  - [ ] Implement health check endpoints

- [ ] Create operational procedures
  - [ ] Document incident response procedures
  - [ ] Create runbooks for common issues
  - [ ] Set up backup and restore procedures
  - [ ] Document scaling strategies

## 8. Implementation Timeline

### Week 1: Core Implementation

- Days 1-2: Project setup, database schema, and utility implementation
- Days 3-4: Core authentication service, EmailService, TokenService, and UserService implementation
- Day 5: Basic signup endpoint with validation

### Week 2: Security and Verification

- Days 1-2: Email verification flow with JWT
- Days 3-4: Security hardening and rate limiting
- Day 5: Testing and bug fixes

### Week 3: Testing and Documentation

- Days 1-2: Comprehensive testing
- Day 3: Documentation and Swagger setup
- Days 4-5: Final testing, review, and deployment preparation
