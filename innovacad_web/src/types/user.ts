export type UserResponseData = {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
  username: string | undefined;
  token: string | undefined;
  role: string | undefined;
  trainer_id?: string | undefined;
  trainee_id?: string | undefined;
};

class User {
  id: string | undefined;
  email: string | undefined;
  name: string | undefined;
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
  }

  toJson(): string {
    return JSON.stringify(this);
  }
}

class Trainee extends User {
  traineeId: string | undefined;

  constructor(data: UserResponseData, traineeId: string) {
    super(data);
    this.traineeId = traineeId || data.trainee_id;
  }
}

class Trainer extends User {
  trainerId: string | undefined;

  constructor(data: UserResponseData, trainerId: string) {
    super(data);
    this.trainerId = trainerId || data.trainer_id;
  }
}

export { User, Trainer, Trainee };
