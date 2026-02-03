import { betterAuth } from "better-auth";
import {
  admin,
  bearer,
  customSession,
  openAPI,
  twoFactor,
  username,
  UserWithTwoFactor,
} from "better-auth/plugins";
import { createPool, RowDataPacket } from "mysql2/promise";
import { API } from "@/src/utils/env";
import { sendTwoFactorEmail } from "../email";
import nodemailer from "nodemailer";

const pool = createPool({
  host: API.MYSQL.HOSTNAME,
  user: API.MYSQL.USERNAME,
  database: API.MYSQL.DATABASE,
  password: API.MYSQL.PASSWORD,
});

async function getUserExtras(userId: string, role: string) {
  try {
    // --- TRAINER / COORDINATOR ---
    if (role === "trainer" || role === "coordinator") {
      const [trainerRows] = await pool.execute<RowDataPacket[]>(
        "SELECT trainer_id, birthday_date, is_coordinator FROM trainers WHERE user_id = ?",
        [userId],
      );

      const trainerData = trainerRows[0];
      if (!trainerData) return { trainer_id: null };

      // Conversão explícita para string para evitar problemas de Buffer/Binary
      const trainerId = String(trainerData.trainer_id);

      const [skillsRows] = await pool.execute<RowDataPacket[]>(
        "SELECT module_id, competence_level FROM trainer_skills WHERE trainer_id = ?",
        [trainerId],
      );

      const [coordinatorRows] = await pool.execute<RowDataPacket[]>(
        "SELECT class_id FROM trainers_classes_coordinator WHERE trainer_id = ?",
        [trainerId],
      );

      const coordinatedClassIds = coordinatorRows.map((row) => row.class_id);

      const extras = {
        trainer_id: trainerId, // Garante snake_case
        birthday_date: trainerData.birthday_date,
        is_coordinator:
          trainerData.is_coordinator === 1 || coordinatedClassIds.length > 0,
        coordinated_class_ids: coordinatedClassIds,
        skills: skillsRows || [],
      };

      console.log(`[Auth] User ${userId} extras:`, extras); // DEBUG LOG
      return extras;
    }

    // --- TRAINEE ---
    if (role === "trainee") {
      const [traineeRows] = await pool.execute<RowDataPacket[]>(
        "SELECT trainee_id, birthday_date, class_id FROM trainees WHERE user_id = ?",
        [userId],
      );

      const traineeData = traineeRows[0];
      if (!traineeData) return { trainee_id: null };

      return {
        trainee_id: String(traineeData.trainee_id),
        birthday_date: traineeData.birthday_date,
        class_id: traineeData.class_id,
      };
    }

    return {};
  } catch (error) {
    console.error("Erro ao buscar user extras:", error);
    return {};
  }
}

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
    cookieCache: { enabled: true, strategy: "jwt" },
    additionalFields: {
      iss: { type: "string", defaultValue: API.JWT.ISSUER },
      aud: { type: "string", defaultValue: API.JWT.AUDIENCE },
    },
  },
  advanced: { useSecureCookies: false },
  plugins: [
    openAPI(),
    bearer(),
    admin(),
    username(),
    twoFactor({
      skipVerificationOnEnable: true,
      otpOptions: {
        async sendOTP({ user, otp }) {
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
      const currUser = user as typeof user & {
        role: string;
        trainer_id?: string | undefined;
        trainee_id?: string | undefined;
      };
      const extraData = await getUserExtras(currUser.id, currUser.role);

      // O Better Auth faz o merge, mas garantimos que o trainer_id vai no topo
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
    sendResetPassword: async ({ user, url }) => {
      /* ... logica mantida ... */
    },
  },
  emailVerification: {
    sendVerificationEmail: async ({ user, url, token }) => {
      /* ... logica mantida ... */
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
        type: ["trainee", "admin", "trainer", "coordinator"],
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
