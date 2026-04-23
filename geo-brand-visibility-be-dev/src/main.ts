import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { BadRequestException, ValidationPipe } from '@nestjs/common';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { TokenService } from './token/token.service';
import { Reflector } from '@nestjs/core';
import { isProduction } from './utils/environment.util';
import { UserRepository } from 'src/user/user.repository';
import { LoggingInterceptor } from './shared/interceptors/logging.interceptor';
import { createAppLogger } from './shared/logger/app-logger.factory';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: createAppLogger(),
    rawBody: true,
  });

  const corsOptions = isProduction()
    ? {
        origin: process.env.ALLOWED_ORIGINS
          ? process.env.ALLOWED_ORIGINS.split(',').map((origin) =>
              origin.trim(),
            )
          : [],
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
      }
    : {
        origin: true,
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
      };

  app.enableCors(corsOptions);

  app.setGlobalPrefix('api', {
    exclude: ['/health', '/'],
  });

  app.useGlobalInterceptors(new LoggingInterceptor());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      exceptionFactory: (errors) => {
        console.log('Validation Errors:', JSON.stringify(errors, null, 2));
        return new BadRequestException(errors);
      },
    }),
  );

  const reflector = app.get(Reflector);
  const tokenService = app.get(TokenService);
  const userRepository = app.get(UserRepository);
  app.useGlobalGuards(
    new JwtAuthGuard(tokenService, reflector, userRepository),
  );

  const config = new DocumentBuilder()
    .setTitle('GEO Brand Visibility Platform API')
    .setDescription(
      'API for managing brand visibility projects and monitoring. All endpoints require JWT Bearer token authentication.',
    )
    .setVersion('1.0.1')
    .addTag('Authentication', 'Authentication endpoints')
    .addTag('projects', 'Project management endpoints')
    .addTag('brands', 'Brand management endpoints')
    .addTag('prompts', 'Prompt management endpoints')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .build();

  const documentFactory = () => SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, documentFactory, {
    swaggerOptions: {
      persistAuthorization: true,
      displayRequestDuration: true,
      filter: true,
      tryItOutEnabled: true,
    },
  });

  await app.listen(process.env.PORT || 3000, '0.0.0.0');
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap the app:', err);
});
