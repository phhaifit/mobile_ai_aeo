import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { Request, Response } from 'express';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const httpContext = context.switchToHttp();
    const request = httpContext.getRequest<Request>();
    const response = httpContext.getResponse<Response>();

    const { method, originalUrl, body } = request as Request & {
      body: Record<string, unknown>;
    };
    const startTime = Date.now();

    this.logger.log(`Request: ${method} ${originalUrl}`);

    return next.handle().pipe(
      tap((resBody: unknown) => {
        const duration = Date.now() - startTime;
        const statusCode = response.statusCode;

        this.logger.log(
          `Response: ${method} ${originalUrl} ${statusCode} - ${duration}ms`,
        );

        if (statusCode >= 400) {
          if (
            body &&
            typeof body === 'object' &&
            Object.keys(body).length > 0
          ) {
            this.logger.warn(
              `Request Body: ${JSON.stringify(this.sanitize(body as Record<string, unknown>), null, 2)}`,
            );
          }
          if (resBody) {
            this.logger.warn(
              `Response Body: ${JSON.stringify(this.sanitize(resBody as Record<string, unknown>), null, 2)}`,
            );
          }
        }
      }),
      catchError((err: unknown) => {
        const duration = Date.now() - startTime;
        const error = err as { status?: number; message?: string };
        const statusCode = error.status || 500;

        this.logger.error(
          `Response Error: ${method} ${originalUrl} ${statusCode} - ${duration}ms`,
        );

        if (body && typeof body === 'object' && Object.keys(body).length > 0) {
          this.logger.error(
            `Request Body (Error): ${JSON.stringify(this.sanitize(body as Record<string, unknown>), null, 2)}`,
          );
        }

        this.logger.error(`Error Details: ${error.message || String(err)}`);

        return throwError(() => err);
      }),
    );
  }

  private sanitize(data: unknown): unknown {
    if (!data || typeof data !== 'object') return data;

    const sensitiveFields = [
      'password',
      'token',
      'access_token',
      'refresh_token',
    ];

    if (Array.isArray(data)) {
      return data.map((item) => this.sanitize(item));
    }

    const sanitized: Record<string, unknown> = {
      ...(data as Record<string, unknown>),
    };

    for (const key in sanitized) {
      if (sensitiveFields.includes(key.toLowerCase())) {
        sanitized[key] = '***';
      } else {
        const value = sanitized[key];
        if (typeof value === 'string' && value.length > 1000) {
          sanitized[key] = value.substring(0, 1000) + '... [truncated]';
        } else if (typeof value === 'object' && value !== null) {
          sanitized[key] = this.sanitize(value);
        }
      }
    }

    return sanitized;
  }
}
