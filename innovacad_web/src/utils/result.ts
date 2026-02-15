import { AppError } from "../types/api-types";

export class Result<T> {
  public readonly data?: T;
  public readonly error?: AppError;

  private constructor(data?: T, error?: AppError) {
    this.data = data;
    this.error = error;
  }

  public get isSuccess(): boolean {
    return !this.error;
  }

  public get isFailure(): boolean {
    return !!this.error;
  }

  public static success<T>(data: T): Result<T> {
    return new Result<T>(data, undefined);
  }
  public static failure<T>(error: AppError): Result<T> {
    return new Result<T>(undefined, error);
  }
}
