import { betterAuth } from "better-auth";
import { admin, bearer, openAPI, username } from "better-auth/plugins";
import { createPool } from "mysql2/promise";
import { API } from "@/src/utils/env";

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
	database: createPool({
		host: API.MYSQL.HOSTNAME,
		user: API.MYSQL.USERNAME,
		database: API.MYSQL.DATABASE,
		password: API.MYSQL.PASSWORD,
	}),
	experimental: { joins: true },
});

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

export default auth;
