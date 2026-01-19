import { betterAuth, google } from "better-auth";
import {
  admin,
  bearer,
  customSession,
  openAPI,
  username,
} from "better-auth/plugins";
import { createPool } from "mysql2/promise";
import { API } from "@/src/utils/env";
import nodemailer from "nodemailer";

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
    customSession(async ({ user, session }) => {
      const currUser = user as typeof user & { role: string };

      if (currUser.role === "trainer") {
        const [rows] = await pool.execute(
          "SELECT trainer_id, birthday_date, specialization FROM trainers WHERE user_id = ?",
          [currUser.id],
        );
        const trainerData = (rows as any[])[0];

        return {
          user: {
            ...currUser,
            ...trainerData,
          },
          session,
        };
      }

      if (currUser.role === "trainee") {
        const [rows] = await pool.execute(
          "SELECT trainee_id, birthday_date FROM trainees WHERE user_id = ?",
          [currUser.id],
        );
        console.log(rows);
        const traineedata = (rows as any[])[0];

        return {
          user: {
            ...currUser,
            ...traineedata,
          },
          session,
        };
      }

      return { user, session };
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

        await transporter.sendMail({
          from: "pedroga.personal@gmail.com",
          to: user.email,
          subject: "Hello from TypeScript!",
          html: `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verifique o seu Email</title>
  <style>
    /* Reset básico para garantir que fica igual em todo o lado */
    body { margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4; }
    table { border-collapse: collapse; }
    
    /* Estilos responsivos para telemóvel */
    @media screen and (max-width: 600px) {
      .container { width: 100% !important; }
      .content { padding: 20px !important; }
    }
  </style>
</head>
<body style="margin: 0; padding: 0; background-color: #f4f4f4;">

  <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center" style="padding: 40px 0;">
        
        <table class="container" role="presentation" width="600" border="0" cellspacing="0" cellpadding="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); overflow: hidden;">
          
          <tr>
            <td style="background-color: #004d99; padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 1px;">INNOVACAD</h1>
            </td>
          </tr>

          <tr>
            <td class="content" style="padding: 40px 30px; text-align: center;">
              <h2 style="color: #333333; margin-top: 0; font-size: 22px;">Verifique a sua conta</h2>
              <p style="color: #666666; font-size: 16px; line-height: 1.5; margin-bottom: 30px;">
                Obrigado por se registar! Para começar a usar a plataforma, por favor valide o seu endereço de email clicando no botão abaixo.
              </p>

              <table role="presentation" border="0" cellspacing="0" cellpadding="0" style="margin: 0 auto;">
                <tr>
                  <td align="center" style="border-radius: 4px;" bgcolor="#004d99">
                    <a href="http://localhost:10000/api/auth/verify-email?token=${token}&callbackURL=http://localhost:5000/dashboard" 
                       target="_blank" 
                       style="font-size: 16px; font-family: sans-serif; font-weight: bold; color: #ffffff; text-decoration: none; padding: 12px 24px; border-radius: 4px; border: 1px solid #004d99; display: inline-block;">
                       Verificar Email
                    </a>
                  </td>
                </tr>
              </table>

              <div style="margin-top: 40px; border-top: 1px solid #eeeeee; padding-top: 20px;">
                <p style="color: #999999; font-size: 14px; margin-bottom: 10px;">Ou utilize o código manualmente:</p>
                <div style="background-color: #f8f9fa; padding: 15px; border-radius: 4px; border: 1px dashed #cccccc; display: inline-block;">
                  <strong style="font-size: 20px; color: #333333; letter-spacing: 2px;">${token}</strong>
                </div>
              </div>

            </td>
          </tr>

          <tr>
            <td style="background-color: #eeeeee; padding: 20px; text-align: center;">
              <p style="color: #999999; font-size: 12px; margin: 0;">
                Se não criou esta conta, pode ignorar este email com segurança.<br>
                &copy; 2026 Innovacad - Projeto ATEC
              </p>
            </td>
          </tr>
        </table>

      </td>
    </tr>
  </table>

</body>
</html>`,
        });
        console.log("Email sent successfully!");
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
