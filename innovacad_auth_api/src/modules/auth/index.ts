import { betterAuth, google } from "better-auth";
import {
  admin,
  bearer,
  customSession,
  openAPI,
  twoFactor,
  username,
} from "better-auth/plugins";
import { createPool } from "mysql2/promise";
import { API } from "@/src/utils/env";
import nodemailer from "nodemailer";
import { sendVerificationEmail, sendTwoFactorEmail } from "@/src/modules/email";

async function getUserExtras(userId: string, role: string) {
  if (role === "trainer") {
    const [rows] = await pool.execute(
      "SELECT trainer_id, birthday_date, specialization FROM trainers WHERE user_id = ?",
      [userId],
    );
    return (rows as any[])[0] || {};
  }

  if (role === "trainee") {
    const [rows] = await pool.execute(
      "SELECT trainee_id, birthday_date FROM trainees WHERE user_id = ?",
      [userId],
    );
    return (rows as any[])[0] || {};
  }

  return {};
}

const pool = createPool({
  host: API.MYSQL.HOSTNAME,
  user: API.MYSQL.USERNAME,
  database: API.MYSQL.DATABASE,
  password: API.MYSQL.PASSWORD,
});

export const auth = betterAuth({
  secret: API.JWT.SECRET,

  trustedOrigins: [
    "https://localhost:10000",
    "https://localhost:8080",
    "https://localhost:5000",
    "http://localhost:10000",
    "http://localhost:8080",
    "http://localhost:5000",
  ],
  session: {
    expiresIn: 900,
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
  advanced: {
    useSecureCookies: false,
  },
  plugins: [
    openAPI(),
    bearer(),
    admin(),
    username(),
    twoFactor({
      skipVerificationOnEnable: true,
      otpOptions: {
        async sendOTP({ user, otp }, ctx) {
          try {
            const transporter = nodemailer.createTransport({
              service: "gmail",
              
              auth: {
                user: "peterdroidyt@gmail.com",
                pass: API.GOOGLE.GMAIL_SECRET,
              },
            });

            await sendTwoFactorEmail({
              user: user,
              toEmail: user.email,
              otp: otp,
              subject: "Verification Code from Innovacad",
              transporter: transporter,
            });
            console.log("Email sent successfully!");
          } catch (error) {
            console.error("Error sending email:", error);
          }
        },
      },
    }),
    customSession(async ({ user, session }) => {
      const currUser = user as typeof user & { role: string };
      const extraData = await getUserExtras(currUser.id, currUser.role);

      return {
        user: {
          ...currUser,
          ...extraData,
        },
        session,
      };
    }),
  ],
  account: {
    accountLinking: {
      enabled: true,
      trustedProviders: ["google", "facebook"],
      allowDifferentEmails: true,
    },
  },
  emailAndPassword: {
    enabled: true,
    disableSignUp: false,
  },
  emailVerification: {
    sendVerificationEmail: async ({ user, url, token }) => {
      try {
        const transporter = nodemailer.createTransport({
          service: "gmail",
          auth: {
            user: "peterdroidyt@gmail.com",
            pass: API.GOOGLE.GMAIL_SECRET,
          },
        });

        await sendVerificationEmail({
          user: user,
          toEmail: user.email,
          url: "http://localhost:5000/dashboard",
          token: token,
          subject: "Hello from TypeScript !",
          transporter: transporter,
        });
      } catch (error) {
        console.error("Error sending email:", error);
      }
    },
    sendOnSignIn: true,
  },
  socialProviders: {
    google: {
      prompt: "select_account consent",
      clientId: API.GOOGLE.CLIENT_ID as string,
      clientSecret: API.GOOGLE.CLIENT_SECRET as string,
      disableSignUp: false,
      enabled: true,
    },
    facebook: {
      clientId: API.FACEBOOK.CLIENT_ID as string,
      clientSecret: API.FACEBOOK.CLIENT_SECRET as string,
      disableSignUp: false,
      enabled: true,
    },
  },
  user: {
    additionalFields: {
      role: {
        type: ["trainee", "admin", "trainer"],
        defaultValue: "trainee",
        required: true,
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
    [API.ADMIN.USERNAME, API.ADMIN.EMAIL],
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
