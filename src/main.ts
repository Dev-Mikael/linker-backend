import "reflect-metadata";
import { Logger } from "@nestjs/common";

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // CORS — allow your frontend to talk to this backend
  app.enableCors({
    origin: [
      'https://linker.modumichael.tech',
      'http://localhost:3000',
    ],
    credentials: true,
  });

  app.setGlobalPrefix('api');

  // Health check endpoint required by App Runner
  // Registered on the raw HTTP adapter so it bypasses
  // NestJS guards, interceptors and the global prefix pipe
  const httpAdapter = app.getHttpAdapter();
  httpAdapter.get('/api/health', (req: any, res: any) => {
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
    });
  });

  // 0.0.0.0 is required — without it the server only listens
  // on localhost inside the container and App Runner can't reach it
  await app.listen(process.env.PORT || 3001, '0.0.0.0');
  console.log(`Backend running on http://localhost:${process.env.PORT || 3001}/api`);
}

bootstrap();

