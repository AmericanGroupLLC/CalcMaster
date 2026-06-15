export default () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  apiBaseUrl: process.env.API_BASE_URL || 'https://api.safecodeg.com',
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT ?? '5432', 10),
    username: process.env.DB_USERNAME || 'calcmaster',
    password: process.env.DB_PASSWORD || 'calcmaster_dev',
    name: process.env.DB_NAME || 'calcmaster',
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'CHANGE_ME_IN_PRODUCTION',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES || '7d',
  },
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID || '',
    clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
    callbackUrl:
      process.env.GOOGLE_CALLBACK_URL ||
      `${process.env.API_BASE_URL || 'https://api.safecodeg.com'}/api/v1/auth/google/callback`,
  },
  apple: {
    clientId: process.env.APPLE_CLIENT_ID || 'com.americangroupllc.calcmaster',
    teamId: process.env.APPLE_TEAM_ID || '',
    keyId: process.env.APPLE_KEY_ID || '',
    privateKey: process.env.APPLE_PRIVATE_KEY || '',
    callbackUrl:
      process.env.APPLE_CALLBACK_URL ||
      `${process.env.API_BASE_URL || 'https://api.safecodeg.com'}/api/v1/auth/apple/callback`,
  },
  ai: {
    openaiKey: process.env.OPENAI_API_KEY || '',
    anthropicKey: process.env.ANTHROPIC_API_KEY || '',
    geminiKey: process.env.GEMINI_API_KEY || '',
    defaultProvider: process.env.AI_DEFAULT_PROVIDER || 'anthropic',
    defaultModel: process.env.AI_DEFAULT_MODEL || 'claude-sonnet-4-6',
  },
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
  },
  cors: {
    origins: (
      process.env.CORS_ORIGINS ||
      'https://www.safecodeg.com,https://www.www.safecodeg.com'
    ).split(','),
  },
});
