const ENV = process.env;

export const API = {
  PORT: ENV.API_PORT ?? "3000",
  GOOGLE: {
    CLIENT_ID: ENV.GOOGLE_CLIENT_ID ?? "your_client_id",
    CLIENT_SECRET: ENV.GOOGLE_CLIENT_SECRET ?? "your_client_secret",
    GMAIL_SECRET: ENV.GOOGLE_GMAIL_SECRET ?? "your_client_secret",
  },
  FACEBOOK: {
    CLIENT_ID: ENV.FACEBOOK_CLIENT_ID ?? "your_client_id",
    CLIENT_SECRET: ENV.FACEBOOK_CLIENT_SECRET ?? "your_client_secret",
  },
  MYSQL: {
    HOSTNAME: ENV.MYSQL_HOSTNAME ?? "your_hostname",
    USERNAME: ENV.MYSQL_USERNAME ?? "your_username",
    DATABASE: ENV.MYSQL_DATABASE ?? "your_database",
    PASSWORD: ENV.MYSQL_PASSWORD ?? "your_password",
  },
  JWT: {
    ISSUER: ENV.JWT_ISSUER ?? "your_jwt_issuer",
    AUDIENCE: ENV.JWT_AUDIENCE ?? "your_jwt_audience",
    SECRET: ENV.JWT_SECRET ?? "your_jwt_secret",
  },
  ADMIN: {
    EMAIL: ENV.DEFAULT_ADMIN_EMAIL ?? "admin@email.com",
    PASSWORD: ENV.DEFAULT_ADMIN_PASSWORD ?? "admin12345",
    NAME: ENV.DEFAULT_ADMIN_NAME ?? "Default Admin",
    USERNAME: ENV.DEFAULT_ADMIN_USERNAME ?? "admin",
  },
};
