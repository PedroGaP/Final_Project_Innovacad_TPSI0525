export type UserResponseData = {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
  username: string | undefined;
  token: string | undefined;
  role: string | undefined;
  trainer_id?: string | undefined;
  trainee_id?: string | undefined;
  image?: string | undefined;
  birthday_date?: number | undefined;
};

class User {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
  image: string | undefined;
  username: string | undefined;
  token: string | undefined;
  role: string | undefined;

  constructor(data: UserResponseData) {
    this.id = data.id;
    this.email = data.email;
    this.name = data.name;
    this.username = data.username;
    this.token = data.token;
    this.role = data.role;
    this.image = data.image;
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
    birthdayDate?: number | undefined
  ) {
    super(data);
    this.traineeId = traineeId || data.trainee_id;
    this.birthdayDate = birthdayDate || data.birthday_date;
  }
}

class Trainer extends User {
  trainerId: string | undefined;
  birthdayDate: number | undefined;

  constructor(
    data: UserResponseData,
    trainerId: string,
    birthdayDate?: number | undefined
  ) {
    super(data);
    this.trainerId = trainerId || data.trainer_id;
    this.birthdayDate = birthdayDate || data.birthday_date;
  }
}

export { User, Trainer, Trainee };
