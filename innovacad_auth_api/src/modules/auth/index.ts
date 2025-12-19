import { betterAuth } from "better-auth";
import { bearer, jwt, openAPI } from "better-auth/plugins";
import { API } from "@/src/utils/env";
import { createPool } from "mysql2/promise";

const auth = betterAuth({
  secret: API.JWT.SECRET,
  session: {
    cookieCache: {
      enabled: true,
      strategy: "jwt",
    },
    additionalFields: {
      iss: {
        type: "string",
        defaultValue: API.JWT.ISSUER,
      },
      aud: {
        type: "string",
        defaultValue: API.JWT.AUDIENCE,
      },
    },
  },
  plugins: [openAPI(), bearer()],
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    microsoft: {
      clientId: API.MICROSOFT.CLIENT_ID as string,
      clientSecret: API.MICROSOFT.CLIENT_SECRET as string,
    },
  },
  database: createPool({
    host: API.MYSQL.HOSTNAME,
    user: API.MYSQL.USERNAME,
    database: API.MYSQL.DATABASE,
    password: API.MYSQL.PASSWORD,
  }),
  experimental: { joins: true },
});

export default auth;
