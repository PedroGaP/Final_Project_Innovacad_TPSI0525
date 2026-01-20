export type UserResponseData = {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
  username: string | undefined;
  token: string | undefined;
  role: string | undefined;
  trainer_id?: string | undefined;
  trainee_id?: string | undefined;
  specialization?: string | undefined;
  image?: string | undefined;
  birthday_date?: number | undefined;
  emailVerified: boolean | undefined;
  session_token: string | undefined;
  twoFactorRedirect: boolean | undefined;
};

class User {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
  image: string | undefined;
  username: string | undefined;
  token: string | undefined;
  role: string | undefined;
  verified: boolean | undefined;
  session_token: string | undefined;
  twoFactorRedirect: boolean | undefined;

  constructor(data: UserResponseData) {
    this.id = data.id;
    this.email = data.email;
    this.name = data.name;
    this.username = data.username;
    this.token = data.token;
    this.role = data.role;
    this.image = data.image;
    this.verified = data.emailVerified;
    this.session_token = data.session_token;
    this.twoFactorRedirect = data.twoFactorRedirect;
  }

  toJson(): string {
    return JSON.stringify(this);
  }
}

class Trainee extends User {
  traineeId: string | undefined;
  birthdayDate: number | undefined;

  constructor(
    data: UserResponseData,
    traineeId: string,
    birthdayDate?: number | undefined,
  ) {
    super(data);
    this.traineeId = traineeId || data.trainee_id;
    this.birthdayDate = birthdayDate || data.birthday_date;
  }
}

class Trainer extends User {
  trainerId: string | undefined;
  birthdayDate: number | undefined;
  specialization: string | undefined;

  constructor(
    data: UserResponseData,
    trainerId: string,
    birthdayDate?: number | undefined,
    specialization?: string | undefined,
  ) {
    super(data);
    this.trainerId = trainerId || data.trainer_id;
    this.birthdayDate = birthdayDate || data.birthday_date;
    this.specialization = specialization || data.specialization;
  }
}

class Account {
  id: string | undefined;
  providerId: string | undefined;
  DateTime: string | undefined;
  updatedAt: string | undefined;
  accountId: string | undefined;
  userId: string | undefined;
  scopes: string[] | undefined;
}

class LinkSocialData {
  url: string | undefined;
  redirect: boolean | undefined;
  status: boolean | undefined;
}

export { User, Trainer, Trainee, LinkSocialData, Account };
