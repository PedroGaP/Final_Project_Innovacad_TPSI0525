export enum AppErrorType {
  NOT_FOUND,
  VALIDATION,
  CONFLICT,
  UNAUTHORIZED,
  FORBIDDEN,
  BAD_REQUEST,
  EXTERNAL,
  INTERNAL,
}

export class AppError {
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

export class Result<T> {
  data?: T;
  error?: AppError;
  isError: boolean = false;

  constructor(data?: T, error?: AppError) {
    this.data = data;
    this.error = error;

    this.isError = !!error;
  }
}

export function statusToErrorType(status: number): AppErrorType {
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

export class Failure<T> extends Result<T> {
  constructor(error: AppError) {
    super(undefined, error);
  }
}

export class Success<T> extends Result<T> {
  constructor(data: T) {
    super(data, undefined);
  }
}
