import { User } from "better-auth";
import { twoFactorPage } from "./html/two_factor";
import { verifyEmailPage } from "./html/verify_email";
import type { Transporter } from "nodemailer";
import { UserWithTwoFactor } from "better-auth/plugins";

interface ISendEmailData {
  toEmail: string;
  subject: string;
  transporter: Transporter;
}

interface ISendVerificationEmailData extends ISendEmailData {
  url: string;
  token: string;
  user: User;
}

interface ISendTwoFactorEmailData extends ISendEmailData {
  otp: string;
  user: UserWithTwoFactor;
}

const fromEmail = "pedroga.personal@gmail.com";

export const sendVerificationEmail = async (
  data: ISendVerificationEmailData,
) => {
  const toEmail = data.user.email;

  try {
    await data.transporter.sendMail({
      from: fromEmail,
      to: data.toEmail,
      subject: data.subject,
      html: verifyEmailPage(data.token, data.url),
    });
  } catch (error) {
    console.error(
      `Something went wrong sending an email for ${toEmail}`,
      error,
    );
  }
};

export const sendTwoFactorEmail = async (data: ISendTwoFactorEmailData) => {
  const toEmail = data.user.email;

  try {
    await data.transporter.sendMail({
      from: fromEmail,
      to: data.toEmail,
      subject: data.subject,
      html: twoFactorPage(data.otp),
    });
  } catch (error) {
    console.error(
      `Something went wrong sending an email for ${toEmail}`,
      error,
    );
  }
};
