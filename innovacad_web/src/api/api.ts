import type { SignInData } from "@/types/auth";
import { Trainee, Trainer, User, type UserResponseData } from "@/types/user";

const headers = {
  "Content-Type": "application/json",
};

const baseUrl = "http://localhost:8080";

enum AppErrorType {
  NOT_FOUND,
  VALIDATION,
  CONFLICT,
  UNAUTHORIZED,
  FORBIDDEN,
  BAD_REQUEST,
  EXTERNAL,
  INTERNAL,
}

class AppError {
  type: AppErrorType;
  message: string;
  details?: Record<string, any>[];

  constructor(
    type: AppErrorType,
    message: string,
    details?: Record<string, any>[]
  ) {
    this.type = type;
    this.message = message;
    this.details = details;
  }

  toJson(): Record<string, any> {
    const val = {} as Record<string, any>;
    val["type"] = this.type.toString();
    val["message"] = this.message;

    if (this.details != null) {
      val["details"] = this.details!;
    }
    return val;
  }
}

class Result<T> {
  data?: T;
  error?: AppError;
  isError: boolean = false;

  constructor(data?: T, error?: AppError) {
    this.data = data;
    this.error = error;

    this.isError = !!error;
  }
}

function statusToErrorType(status: number): AppErrorType {
  switch (status) {
    case 404:
      return AppErrorType.NOT_FOUND;
    case 400:
      return AppErrorType.BAD_REQUEST;
    case 409:
      return AppErrorType.CONFLICT;
    case 401:
      return AppErrorType.UNAUTHORIZED;
    case 403:
      return AppErrorType.FORBIDDEN;
    case 502:
      return AppErrorType.EXTERNAL;
    case 500:
      return AppErrorType.INTERNAL;
  }

  return AppErrorType.INTERNAL;
}

class Failure<T> extends Result<T> {
  constructor(error: AppError) {
    super(undefined, error);
  }
}

class Success<T> extends Result<T> {
  constructor(data: T) {
    super(data, undefined);
  }
}

async function fetchApi<T>(
  path: string,
  method: string,
  body?: Object
): Promise<Result<T>> {
  try {
    const res = await fetch(`${baseUrl}${path}`, {
      headers,
      method,
      body: body ? JSON.stringify(body) : undefined,
    });

    const data = await res.json();

    if (!res.ok) {
      console.log(data);
      return new Failure(
        new AppError(
          statusToErrorType(res.status),
          data.error.message || "Unknown Error",
          data.error.details
        )
      );
    }

    return new Success(data as T);
  } catch (e) {
    return new Failure(
      new AppError(AppErrorType.INTERNAL, "Network or Parsing Error")
    );
  }
}

export const signIn = async (data: SignInData): Promise<User | undefined> => {
  if (data.email === undefined && data.username === undefined)
    throw new Error("Parâmetros inválidos.");

  const res = await fetchApi<UserResponseData>("/sign/in", "POST", {
    email: data.email,
    username: data.username,
    password: data.password,
  });

  if (res.isError || !res.data) {
    throw new Error(
      `[SIGN IN] > Failure while signing in user: ${JSON.stringify(res.error)}`
    );
  }

  const resData = res.data;

  let user: User;

  if (resData.trainer_id) {
    user = new Trainer(resData, resData.trainer_id);
  } else if (resData.trainee_id) {
    user = new Trainee(resData, resData.trainee_id);
  } else {
    user = new User(resData);
  }

  return user;
};

export const fetchTrainees = async () => {
  const res = await fetchApi<UserResponseData[]>("/trainees", "GET");

  if (res.isError || !res.data) {
    throw new Error(
      `[FETCH TRAINEES] > Failure while fetching trainees: ${JSON.stringify(
        res.error
      )} `
    );
  }

  const resData = res.data;

  console.log(`[DATA] >> ${JSON.stringify(resData)}`);

  return resData.map((item) => {
    return new Trainee(item, item.trainee_id || "");
  });
};

export const fetchTrainers = async () => {
  const res = await fetchApi<UserResponseData[]>("/trainers", "GET");

  if (res.isError || !res.data) {
    throw new Error(
      `[FETCH TRAINERS] > Failure while fetching trainers: ${JSON.stringify(
        res.error
      )} `
    );
  }

  const resData = res.data;

  console.log(`[DATA] >> ${JSON.stringify(resData)}`);

  return resData.map((item) => {
    return new Trainer(item, item.trainer_id || "");
  });
};
