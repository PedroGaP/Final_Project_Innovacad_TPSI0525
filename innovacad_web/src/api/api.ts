import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useNavigate } from "@solidjs/router";
import Cookies from "js-cookie";
import toast from "solid-toast";

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
    details?: Record<string, any>[],
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

const headers = {
  "Content-Type": "application/json",
};

const baseUrl = "http://localhost:8080";
const SESSION_COOKIE_KEY = "better-auth.session_data";

export const API_ENDPOINTS = {
  AUTH: {
    SIGN_IN: "/sign/in",
    SIGN_UP: "/sign/up",
    SEND_VERIFY: "/sign/send/verify",
    VERIFY: "/sign/verify",
    VALIDITY: "/sign/validity",
    SESSION: "/sign/session",
    LINK_SOCIAL: "/sign/link-social",
  },
} as const;

const requiresAuth = (path: string): boolean => {
  return (
    path !== API_ENDPOINTS.AUTH.SIGN_IN &&
    path !== API_ENDPOINTS.AUTH.SIGN_UP &&
    !path.includes(API_ENDPOINTS.AUTH.VERIFY) &&
    !path.includes(API_ENDPOINTS.AUTH.SEND_VERIFY) &&
    !path.includes(API_ENDPOINTS.AUTH.SESSION)
  );
};

const handleAuthFailure = (status: number, message: string) => {
  const { logout } = useUserDetails();
  const navigate = useNavigate();

  if (status === 401 || status === 403) {
    logout();
    Cookies.remove(SESSION_COOKIE_KEY);
    toast.error("Your session has expired. Please sign in again.");
    navigate("/");
  } else {
    toast.error(message);
  }
};

export const fetchApi = async <T>(
  path: string,
  method: string,
  body?: Object,
  skipAuth?: boolean,
): Promise<Result<T>> => {
  try {
    const { user } = useUserDetails();

    if (!skipAuth && requiresAuth(path)) {
      if (!user() || !user()?.token) {
        handleAuthFailure(403, "No authentication token provided");
        return new Failure(
          new AppError(AppErrorType.FORBIDDEN, "No token was provided."),
        );
      }
    }

    const reqHeaders: HeadersInit = {
      ...headers,
      ...(user()?.token && !skipAuth
        ? { Authorization: `Bearer ${user()!.token}` }
        : {}),
    };

    const res = await fetch(`${baseUrl}${path}`, {
      headers: reqHeaders,
      method,
      credentials: "include",
      body: body ? JSON.stringify(body) : undefined,
    });

    let data;

    try {
      data = await res.json();
    } catch {
      data = {
        error: { message: "Invalid JSON response or empty response body." },
      };
    }

    if (res.status === 401 || res.status === 403) {
      handleAuthFailure(res.status, data?.error?.message || "Unauthorized");
      return new Failure(
        new AppError(
          statusToErrorType(res.status),
          data?.error?.message || "Unauthorized",
        ),
      );
    }

    if (!res.ok) {
      return new Failure(
        new AppError(
          statusToErrorType(res.status),
          data?.error?.message || "Unknown error",
          data?.error?.details,
        ),
      );
    }

    return new Success(data as T);
  } catch (e) {
    console.error("[API ERROR]", e);
    return new Failure(
      new AppError(AppErrorType.INTERNAL, "Network or parsing error."),
    );
  }
};
