export type AppErrorType =
  | "notFound"
  | "validation"
  | "conflict"
  | "unauthorized"
  | "forbidden"
  | "badRequest"
  | "external"
  | "internal"
  | "network"
  | "unknown";

export interface ApiResponse<T = any> {
  is_error: boolean;
  code: string;
  message: string;
  data: T;
}

export class AppError {
  constructor(
    public type: AppErrorType,
    public message: string,
    public details?: any,
  ) {}
}
