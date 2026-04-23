import { NestFactory } from '@nestjs/core';
import { WorkerModule } from './worker.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Worker');
  logger.log('Starting the worker...');

  const app = await NestFactory.createApplicationContext(WorkerModule);

  // Enable NestJS shutdown hooks (triggers onModuleDestroy, worker.close(), etc.)
  app.enableShutdownHooks();

  const shutdown = async (signal: string) => {
    logger.log(`Received ${signal}. Gracefully shutting down worker...`);
    await app.close();
    logger.log('Worker shut down gracefully.');
    process.exit(0);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

bootstrap().catch((err) => {
  console.error('Failed to bootstrap the worker:', err);
  process.exit(1);
});
