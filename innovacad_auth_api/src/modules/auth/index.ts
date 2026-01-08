import { betterAuth } from "better-auth";
import { admin, bearer, openAPI, username } from "better-auth/plugins";
import { createPool } from "mysql2/promise";
import { API } from "@/src/utils/env";

const pool = createPool({
  host: API.MYSQL.HOSTNAME,
  user: API.MYSQL.USERNAME,
  database: API.MYSQL.DATABASE,
  password: API.MYSQL.PASSWORD,
});

export const auth = betterAuth({
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
  plugins: [openAPI(), bearer(), admin(), username()],
  account: {
    accountLinking: {
      enabled: true,
      trustedProviders: ["microsoft"],
    },
  },
  emailAndPassword: {
    enabled: true,
    disableSignUp: true,
  },
  socialProviders: {
    microsoft: {
      clientId: API.MICROSOFT.CLIENT_ID as string,
      clientSecret: API.MICROSOFT.CLIENT_SECRET as string,
      disableSignUp: true,
      disableImplicitSignUp: true,
    },
  },
  user: {
    additionalFields: {
      role: {
        type: ["user", "admin", "trainer"],
        required: true,
        defaultValue: "user",
        input: false,
      },
    },
  },
  database: pool,
  experimental: { joins: true },
});

export const seedAdmin = async () => {
  const [rows] = await pool.execute(
    "SELECT id FROM user WHERE username = ? OR email = ? LIMIT 1",
    [API.ADMIN.USERNAME, API.ADMIN.EMAIL]
  );

  if ((rows as object[]).length > 0) return;

  await auth.api.createUser({
    body: {
      email: API.ADMIN.EMAIL,
      password: API.ADMIN.PASSWORD,
      name: API.ADMIN.NAME,
      role: "admin",
      data: {
        username: API.ADMIN.USERNAME,
      },
    },
  });
};
