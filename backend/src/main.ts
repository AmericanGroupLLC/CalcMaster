import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security headers
  app.use(helmet());

  // CORS — defaults to production origins; override via CORS_ORIGINS env var
  const allowedOrigins = (
    process.env.CORS_ORIGINS ||
    'https://safecodeg.com,https://www.safecodeg.com'
  ).split(',');

  app.enableCors({
    origin: allowedOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // Global validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.setGlobalPrefix('api/v1');

  // Swagger (disabled in production unless SWAGGER_ENABLED=true)
  if (process.env.NODE_ENV !== 'production' || process.env.SWAGGER_ENABLED === 'true') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('CalcMaster API')
      .setDescription('Backend API for CalcMaster — AI-powered world calculator')
      .setVersion('1.0.0')
      .addBearerAuth()
      .addTag('auth', 'Authentication & authorization')
      .addTag('users', 'User profile & settings')
      .addTag('ai', 'AI chat, recommendations, insights, search')
      .addTag('subscriptions', 'Premium subscription management')
      .addTag('analytics', 'Event tracking & reporting')
      .addTag('affiliates', 'Affiliate click & conversion tracking')
      .addTag('notifications', 'Push notification management')
      .addTag('admin', 'Admin dashboard & system health')
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = process.env.PORT || 3000;
  const apiBase = process.env.API_BASE_URL || 'https://api.safecodeg.com';
  await app.listen(port);
  console.log(`CalcMaster API running on port ${port}`);
  if (process.env.NODE_ENV !== 'production' || process.env.SWAGGER_ENABLED === 'true') {
    console.log(`Swagger docs: ${apiBase}/api/docs`);
  }
}
bootstrap();
