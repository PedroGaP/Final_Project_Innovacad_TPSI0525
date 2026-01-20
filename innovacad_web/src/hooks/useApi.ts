import {
  AppError,
  AppErrorType,
  Failure,
  statusToErrorType,
  Success,
  type Result,
} from "@/api/api";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { SendVerificationData, SignInData } from "@/types/auth";
import {
  Account,
  LinkSocialData,
  Trainee,
  Trainer,
  User,
  type UserResponseData,
} from "@/types/user";
import { useNavigate } from "@solidjs/router";
import Cookies from "js-cookie";
import toast from "solid-toast";

const headers = {
  "Content-Type": "application/json",
};

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
  USERS: {
    TRAINEES: "/trainees",
    TRAINERS: "/trainers",
  },
} as const;

const baseUrl = "http://localhost:8080";
const baseWebUrl = "http://localhost:5000";
const SESSION_COOKIE_KEY = "better-auth.session_data";

export interface SignInResponse {
  user: UserResponseData;
  requiresEmailVerification: boolean;
}

export const useApi = () => {
  const { user, logout, setUser } = useUserDetails();
  const navigate = useNavigate();

  /**
   * Centralized error handler for auth failures
   */
  const handleAuthFailure = (status: number, message: string) => {
    if (status === 401 || status === 403) {
      logout();
      Cookies.remove(SESSION_COOKIE_KEY);
      toast.error("Your session has expired. Please sign in again.");
      navigate("/");
    } else {
      toast.error(message);
    }
  };

  /**
   * Check if request requires authentication
   */
  const requiresAuth = (path: string): boolean => {
    return (
      path !== API_ENDPOINTS.AUTH.SIGN_IN &&
      path !== API_ENDPOINTS.AUTH.SIGN_UP &&
      !path.includes(API_ENDPOINTS.AUTH.VERIFY) &&
      !path.includes(API_ENDPOINTS.AUTH.SEND_VERIFY) &&
      !path.includes(API_ENDPOINTS.AUTH.SESSION)
    );
  };

  /**
   * Core API fetch method with error handling
   */
  const fetchApi = async <T>(
    path: string,
    method: string,
    body?: Object,
    skipAuth?: boolean,
  ): Promise<Result<T>> => {
    try {
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

  /**
   * Map response data to appropriate User type
   */
  const mapToUserType = (data: UserResponseData): User => {
    console.log(data);

    if (!data) throw new Error("The user data is undefined");

    if ("trainer_id" in data) {
      return new Trainer(data, data.trainer_id!, data.birthday_date);
    }
    if ("trainee_id" in data) {
      return new Trainee(data, data.trainee_id!, data.birthday_date);
    }
    return new User(data);
  };

  /**
   * Sign in user with email or username
   * Returns user data and whether email verification is required
   */
  const signIn = async (
    data: SignInData,
  ): Promise<User | Trainer | Trainee | undefined> => {
    if ("email" in data && "username" in data) {
      throw new Error("Provide either email or username, not both");
    }

    const res = await fetchApi<UserResponseData>(
      API_ENDPOINTS.AUTH.SIGN_IN,
      "POST",
      {
        email: data.email,
        username: data.username,
        password: data.password,
      },
      true,
    );

    if (res.isError || !res.data) {
      throw new Error(`SignIn Failed: ${res.error?.message}`);
    }

    const userData = res.data;
    const user = mapToUserType(userData);
    setUser(user);

    console.log("Raw emailVerified:", userData.emailVerified);
    console.log("Type of emailVerified:", typeof userData.emailVerified);
    console.log(
      "Boolean check - !userData.emailVerified:",
      !userData.emailVerified,
    );

    // If email NOT verified (emailVerified === 0 or false), redirect to verification page
    if (userData.emailVerified === false) {
      console.log("NAVIGATING TO VERIFY PAGE");
      toast.custom("Please verify your email to access the dashboard", {
        duration: 3000,
      });
      await navigate("/verify-email");
      return user;
    }

    console.log("NAVIGATING TO DASHBOARD");
    // Email verified, proceed to dashboard
    toast.success("Login successful. You'll be redirected to dashboard", {
      duration: 2000,
    });
    await navigate("/dashboard");

    return user;
  };

  /**
   * Sign up new user - Admin only feature
   */
  const signUp = async (data: any): Promise<User> => {
    const res = await fetchApi<UserResponseData>(
      API_ENDPOINTS.AUTH.SIGN_UP,
      "POST",
      data,
      true,
    );

    if (res.isError || !res.data) {
      throw new Error(`SignUp Failed: ${res.error?.message}`);
    }

    const user = mapToUserType(res.data);
    setUser(user);

    toast.success("User created successfully!", {
      duration: 2000,
    });

    return user;
  };

  /**
   * Fetch all trainees
   */
  const fetchTrainees = async (): Promise<Trainee[]> => {
    const res = await fetchApi<UserResponseData[]>(
      API_ENDPOINTS.USERS.TRAINEES,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Fetch trainees failed: ${res.error?.message}`);
    }

    return res.data.map(
      (item) => new Trainee(item, item.trainee_id || "", item.birthday_date),
    );
  };

  /**
   * Fetch all trainers
   */
  const fetchTrainers = async (): Promise<Trainer[]> => {
    const res = await fetchApi<UserResponseData[]>(
      API_ENDPOINTS.USERS.TRAINERS,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Fetch trainers failed: ${res.error?.message}`);
    }

    return res.data.map(
      (item) => new Trainer(item, item.trainer_id || "", item.birthday_date),
    );
  };

  /**
   * Send verification email to unverified user
   * Called when user tries to login with unverified email
   */
  const sendVerificationEmail = async (
    email: string,
    token: string,
  ): Promise<SendVerificationData> => {
    const res = await fetchApi<SendVerificationData>(
      API_ENDPOINTS.AUTH.SEND_VERIFY,
      "POST",
      { token, email },
      true,
    );

    if (res.isError || !res.data) {
      throw new Error(`Send verification email failed: ${res.error?.message}`);
    }

    toast.success("Verification email sent! Check your inbox.", {
      duration: 2000,
    });

    return res.data;
  };

  /**
   * Verify email with token from email link
   * One-time verification when user clicks email link
   */
  const verifyEmail = async (verifyToken: string): Promise<boolean> => {
    const callback = `${baseUrl}/verify-email?status=verified`;

    const res = await fetchApi<{ status: boolean }>(
      API_ENDPOINTS.AUTH.VERIFY,
      "POST",
      {
        verifyToken,
        callback,
      },
      true,
    );

    if (res.isError || !res.data) {
      throw new Error(`Email verification failed: ${res.error?.message}`);
    }

    if (res.data.status) {
      toast.success("Email verified! You can now login.", {
        duration: 2000,
      });
      navigate("/");
    } else {
      toast.error("Email verification failed. Token may be expired.");
    }

    return res.data.status;
  };

  /**
   * Check if user's email is verified
   */
  const checkUserEmailValidity = async (userId: string): Promise<boolean> => {
    const res = await fetchApi<boolean>(API_ENDPOINTS.AUTH.VALIDITY, "POST", {
      userId,
    });

    if (res.isError || !res.data) {
      throw new Error(`Email validity check failed: ${res.error?.message}`);
    }

    return res.data;
  };

  /**
   * Get current user session from cookie
   */
  const getSession = async (): Promise<User | null> => {
    const sessionToken = Cookies.get(SESSION_COOKIE_KEY);

    if (!sessionToken || sessionToken.length < 1) {
      return null;
    }

    const res = await fetchApi<UserResponseData>(
      `${API_ENDPOINTS.AUTH.SESSION}?session-token=${sessionToken}`,
      "GET",
      undefined,
      true,
    );

    if (res.isError || !res.data) {
      logout();
      Cookies.remove(SESSION_COOKIE_KEY);
      return null;
    }

    const user = mapToUserType(res.data);
    setUser(user);

    return user;
  };

  /**
   * Logout user and clear session
   */
  const logoutUser = async (): Promise<void> => {
    logout();
    Cookies.remove(SESSION_COOKIE_KEY);
    navigate("/");
    toast.success("Logged out successfully");
  };

  /**
   * Link social account to user
   */
  const linkSocial = async (
    provider: string,
    callback: string,
  ): Promise<LinkSocialData> => {
    const formattedCallback = `${baseWebUrl}${callback}`;

    const res = await fetchApi<LinkSocialData>(
      API_ENDPOINTS.AUTH.LINK_SOCIAL,
      "POST",
      {
        provider,
        callback: formattedCallback,
        token: user()?.session_token,
      },
    );

    if (res.isError || !res.data) {
      throw new Error(`Social linking failed: ${res.error?.message}`);
    }

    if (res.data.url) {
      window.open(res.data.url, "_blank")?.focus();
    }

    return res.data;
  };

  const listAccounts = async () => {
    const res = await fetchApi<Account[]>( 
      `/sign/accounts?session-token=${user()!.session_token}`,
      "GET",
    );

    if (res.isError || !res.data) {
      console.log(res.error);
      throw new Error("[List Accounts] > Failed to list accounts.");
    }

    return res.data;
  };

  return {
    signIn,
    signUp,
    fetchTrainees,
    fetchTrainers,
    sendVerificationEmail,
    verifyEmail,
    checkUserEmailValidity,
    getSession,
    logoutUser,
    linkSocial,
    listAccounts,
  };
};
