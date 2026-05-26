# CalcMaster Backend API

A production-ready NestJS backend powering the CalcMaster world calculator and converter app.

## Overview

The backend provides:
- **Authentication** — email/password with JWT, Google OAuth, Apple Sign-In, MFA (TOTP)
- **AI Chat** — multi-provider AI assistant (Anthropic, OpenAI, Gemini) with conversation history
- **Subscriptions** — monthly / annual / lifetime premium tiers (Apple, Google, Stripe)
- **Analytics** — event tracking, DAU, retention cohorts
- **Affiliates** — click and conversion tracking
- **Push Notifications** — Firebase Cloud Messaging
- **Admin Dashboard** — user stats, subscription metrics, health checks

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | NestJS 11 |
| Language | TypeScript 5 |
| Database | PostgreSQL 15 (TypeORM 1.x) |
| Auth | JWT + Passport, bcryptjs, speakeasy (TOTP) |
| AI | Anthropic Claude, OpenAI GPT-4o, Google Gemini |
| Push | Firebase Admin SDK |
| Docs | Swagger / OpenAPI |
| Container | Docker (multi-stage, non-root) |

## Quick Start

```bash
# Install dependencies
npm install

# Copy and configure environment
cp .env.example .env
# Edit .env with your values

# Development (watch mode)
npm run start:dev

# Production
npm run build && npm run start:prod
```

## Environment Variables

See `.env.example` for the full list. Required for basic operation:

| Variable | Description |
|---|---|
| `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` | PostgreSQL connection |
| `JWT_SECRET` | Long random secret for JWT signing |
| `PORT` | HTTP port (default: 3000) |

Optional (enables premium features):

| Variable | Description |
|---|---|
| `OPENAI_API_KEY` | OpenAI GPT-4o |
| `ANTHROPIC_API_KEY` | Anthropic Claude |
| `GEMINI_API_KEY` | Google Gemini |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Google OAuth |
| `FIREBASE_PROJECT_ID` / `FIREBASE_PRIVATE_KEY` / `FIREBASE_CLIENT_EMAIL` | Push notifications |

## API Documentation

Swagger UI is available at `http://localhost:3000/api/docs` when running in development.

## Docker

```bash
# Build and run with docker-compose
docker-compose up -d

# Backend only
docker build -t calcmaster-backend .
docker run -p 3000:3000 --env-file .env calcmaster-backend
```

## Testing

```bash
# Unit tests
npm run test

# Unit tests with coverage
npm run test:cov

# E2E tests
npm run test:e2e
```

## API Endpoints

| Module | Base Path | Description |
|---|---|---|
| Auth | `/api/v1/auth` | Register, login, OAuth, MFA, refresh |
| Users | `/api/v1/users` | Profile, settings, FCM token |
| AI | `/api/v1/ai` | Chat, conversations, recommendations |
| Subscriptions | `/api/v1/subscriptions` | Create, cancel, verify receipt |
| Analytics | `/api/v1/analytics` | Event tracking, DAU, retention |
| Affiliates | `/api/v1/affiliates` | Click and conversion tracking |
| Notifications | `/api/v1/notifications` | Push preferences |
| Admin | `/api/v1/admin` | Dashboard, health check |
| Health | `/health` | Public health check |

## Security

- Helmet headers on all responses
- Rate limiting (100 req/min global; 5/min on register, 10/min on login)
- JWT access tokens (15m) + refresh tokens (7d, hashed in DB)
- MFA via TOTP (speakeasy + QR code)
- Input validation via class-validator
- CORS restricted to configured origins

## License

UNLICENSED — proprietary to American Group LLC.
