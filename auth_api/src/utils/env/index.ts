const ENV = process.env;

export const API = {
  PORT: ENV.API_PORT ?? "3000",
  MICROSOFT: {
    CLIENT_ID: ENV.MICROSOFT_CLIENT_ID ?? "your_client_id",
    CLIENT_SECRET: ENV.MICROSOFT_CLIENT_SECRET ?? "your_client_secret",
  },
  MYSQL: {
    HOSTNAME: ENV.MYSQL_HOSTNAME ?? "your_hostname",
    USERNAME: ENV.MYSQL_USERNAME ?? "your_username",
    DATABASE: ENV.MYSQL_DATABASE ?? "your_database",
    PASSWORD: ENV.MYSQL_PASSWORD ?? "your_password",
  },
};
