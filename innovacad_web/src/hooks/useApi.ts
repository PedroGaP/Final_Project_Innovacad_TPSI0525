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
import { Class, type ClassResponseData } from "@/types/class";
import { Course, type CourseResponseData } from "@/types/course";
import { Enrollment, type EnrollmentResponseData } from "@/types/enrollment";
import {
  Grade,
  type GradeResponseData,
  type GradeTypeEnum,
} from "@/types/grade";
import { Module, type ModuleResponseData } from "@/types/module";
import { Room, type RoomResponseData } from "@/types/room";
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
    SIGN_IN_SOCIAL: "/sign/social/in",
    SEND_2FA: "/sign/send-otp",
    VERIFY_2FA: "/sign/verify-otp",
    IS_2FA_ENABLED: "/sign/is-otp-enabled",
    ENABLE_2FA: "/sign/enable-otp",
    DISABLE_2FA: "/sign/disable-otp",
    RESET_PASSWORD: "/sign/reset-password",
    REQUEST_RESET_PASSWORD: "/sign/request-password-reset",
  },
  USERS: {
    TRAINEES: "/trainees",
    TRAINERS: "/trainers",
  },
  ENTITY: {
    CLASS: "/classes",
    COURSE: "/courses",
    GRADE: "/grades",
    ROOM: "/rooms",
    MODULE: "/modules",
    ENROLLMENT: "/enrollments",
  },
} as const;

const baseUrl = "http://localhost:8080";
//const baseUrl = "http://192.168.1.113:8080";
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
      !path.includes(API_ENDPOINTS.AUTH.SESSION) &&
      !path.includes(API_ENDPOINTS.AUTH.SIGN_IN_SOCIAL) &&
      !path.includes(API_ENDPOINTS.AUTH.SEND_2FA) &&
      !path.includes(API_ENDPOINTS.AUTH.VERIFY_2FA) &&
      !path.includes(API_ENDPOINTS.AUTH.RESET_PASSWORD) &&
      !path.includes(API_ENDPOINTS.AUTH.REQUEST_RESET_PASSWORD)
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
    console.log("Raw twoFactorRedirect:", userData.twoFactorRedirect);
    console.log(
      "Type of twoFactorRedirect:",
      typeof userData.twoFactorRedirect,
    );

    if (userData.twoFactorRedirect === true) {
      console.log("NAVIGATING TO VERIFY 2FA PAGE");
      toast.custom("Please verify your 2FA to access the dashboard", {
        duration: 3000,
      });
      navigate("/verify-2fa");
      return user;
    }

    if (userData.emailVerified === false) {
      console.log("NAVIGATING TO VERIFY PAGE");
      toast.custom("Please verify your email to access the dashboard", {
        duration: 3000,
      });
      navigate("/verify-email");
      return user;
    }

    console.log("NAVIGATING TO DASHBOARD");
    toast.success("Login successful. You'll be redirected to dashboard", {
      duration: 2000,
    });
    navigate("/dashboard");

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
   * Create a new trainee
   */
  const createTrainee = async (data: {
    name: string;
    email: string;
    username: string;
    password: string;
    birthdayDate: string;
  }): Promise<Trainee> => {
    const res = await fetchApi<UserResponseData>(
      API_ENDPOINTS.USERS.TRAINEES,
      "POST",
      {
        name: data.name,
        email: data.email,
        username: data.username,
        password: data.password,
        birthdayDate: data.birthdayDate,
      },
    );

    if (res.isError || !res.data) {
      throw new Error(`Create trainee failed: ${res.error?.message}`);
    }

    return new Trainee(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
    );
  };

  /**
   * Update an existing trainee
   */
  const updateTrainee = async (
    traineeId: string,
    data: {
      name?: string;
      email?: string;
      username?: string;
      birthdayDate?: string;
    },
  ): Promise<Trainee> => {
    const updateData: Record<string, any> = {};

    if (data.name !== undefined) updateData.name = data.name;
    if (data.birthdayDate !== undefined)
      updateData.birthdayDate = data.birthdayDate;

    const res = await fetchApi<UserResponseData>(
      `${API_ENDPOINTS.USERS.TRAINEES}/${traineeId}`,
      "PUT",
      updateData,
    );

    if (res.isError || !res.data) {
      throw new Error(`Update trainee failed: ${res.error?.message}`);
    }

    return new Trainee(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
    );
  };

  /**
   * Delete a trainee
   */
  const deleteTrainee = async (traineeId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.USERS.TRAINEES}/${traineeId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete trainee failed: ${res.error?.message}`);
    }
  };

  /**
   * Create a new trainer
   */
  const createTrainer = async (data: {
    name: string;
    email: string;
    username: string;
    password: string;
    birthdayDate: string;
    specialization: string;
  }): Promise<Trainer> => {
    const res = await fetchApi<UserResponseData>(
      API_ENDPOINTS.USERS.TRAINERS,
      "POST",
      {
        name: data.name,
        email: data.email,
        username: data.username,
        password: data.password,
        birthdayDate: data.birthdayDate,
        specialization: data.specialization,
      },
    );

    if (res.isError || !res.data) {
      throw new Error(`Create trainer failed: ${res.error?.message}`);
    }

    return new Trainer(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
    );
  };

  /**
   * Update an existing trainer
   */
  const updateTrainer = async (
    trainerId: string,
    data: {
      name?: string;
      birthdayDate?: string;
      specialization?: string;
    },
  ): Promise<Trainer> => {
    const updateData: Record<string, any> = {};

    if (data.name !== undefined) updateData.name = data.name;
    if (data.birthdayDate !== undefined)
      updateData.birthdayDate = data.birthdayDate;
    if (data.specialization !== undefined)
      updateData.specialization = data.specialization;

    const res = await fetchApi<UserResponseData>(
      `${API_ENDPOINTS.USERS.TRAINERS}/${trainerId}`,
      "PUT",
      updateData,
    );

    if (res.isError || !res.data) {
      throw new Error(`Update trainer failed: ${res.error?.message}`);
    }

    return new Trainer(
      res.data,
      res.data.trainee_id || "",
      res.data.birthday_date,
      res.data.specialization,
    );
  };

  /**
   * Delete a trainer
   */
  const deleteTrainer = async (trainerId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.USERS.TRAINERS}/${trainerId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete trainer failed: ${res.error?.message}`);
    }
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
    const res = await fetchApi<UserResponseData>(
      `${API_ENDPOINTS.AUTH.SESSION}`,
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

  const sendEmail = async (data: {
    to: string;
    subject: string;
    body: string;
  }) => {
    try {
      const res = await fetchApi<any>(`/email/send`, "POST", { ...data });

      if (res.isError || !res.data) {
        console.log(res.error);
        throw new Error("[Send Email] > Failed to send email.");
      }

      return res.data;
    } catch (e: any) {
      throw new Error("[Send Email] > Failed to send email.\n" + e.toString());
    }
  };

  const signInSocial = async () => {
    const formattedCallback = `${baseWebUrl}/dashboard`;

    const res = await fetchApi<LinkSocialData>(
      API_ENDPOINTS.AUTH.SIGN_IN_SOCIAL,
      "POST",
      {
        provider: "google",
        callback: formattedCallback,
        token: user()?.session_token,
      },
    );

    if (res.isError || !res.data) {
      throw new Error(`Social login failed: ${res.error?.message}`);
    }

    if (res.data.url) {
      window.open(res.data.url, "_blank")?.focus();
    }

    return res.data;
  };

  const is2FAEnabled = async (userId: String) => {
    const res = await fetchApi<boolean>(
      `${API_ENDPOINTS.AUTH.IS_2FA_ENABLED}?user_id=${userId}`,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Failed to get 2FA status: ${res.error?.message}`);
    }

    return res.data;
  };

  const enable2FA = async (password: String) => {
    const res = await fetchApi<boolean>(
      `${API_ENDPOINTS.AUTH.ENABLE_2FA}?password=${password}`,
      "POST",
    );

    if (res.isError || !res.data) {
      throw new Error(`Failed to enable OTP: ${res.error?.message}`);
    }

    return res.data;
  };

  const disable2FA = async (password: String) => {
    const res = await fetchApi<boolean>(
      `${API_ENDPOINTS.AUTH.DISABLE_2FA}?password=${password}`,
      "POST",
    );

    if (res.isError || !res.data) {
      throw new Error(`Failed to disable OTP: ${res.error?.message}`);
    }

    return res.data;
  };

  const send2FA = async () => {
    const res = await fetchApi(API_ENDPOINTS.AUTH.SEND_2FA, "POST");

    if (res.isError || !res.data) {
      throw new Error(`Failed to send OTP: ${res.error?.message}`);
    }

    return res.data;
  };

  const verify2FA = async (code: string) => {
    const res = await fetchApi(
      `${API_ENDPOINTS.AUTH.VERIFY_2FA}?otp=${code}`,
      "POST",
    );

    if (res.isError || !res.data) {
      throw new Error(`Failed to verify OTP: ${res.error?.message}`);
    }

    const userData = res.data as UserResponseData;
    const user = mapToUserType(userData);
    setUser(user);

    if (userData.emailVerified === false) {
      console.log("NAVIGATING TO VERIFY PAGE");
      toast.custom("Please verify your email to access the dashboard", {
        duration: 3000,
      });
      navigate("/verify-email");
      return user;
    }

    console.log("NAVIGATING TO DASHBOARD");

    toast.success("Login successful. You'll be redirected to dashboard", {
      duration: 2000,
    });
    navigate("/dashboard");

    return user;
  };

  const requestPasswordReset = async (email: string) => {
    const res = await fetchApi(
      `${API_ENDPOINTS.AUTH.REQUEST_RESET_PASSWORD}`,
      "POST",
      {
        email,
        redirectTo: `${baseWebUrl}/reset-password`,
      },
    );

    if (res.isError || !res.data) {
      console.log(res.error);
      throw new Error(
        `Failed to request password reset: ${res.error?.message}`,
      );
    }

    toast.success("Password reset email sent! Check your inbox.", {
      duration: 2000,
    });
  };

  const resetPassword = async (token: string, newPassword: string) => {
    const res = await fetchApi(`${API_ENDPOINTS.AUTH.RESET_PASSWORD}`, "POST", {
      token,
      newPassword,
    });

    if (res.isError || !res.data) {
      throw new Error(
        `Failed to request password reset: ${res.error?.message}`,
      );
    }

    return res.data;
  };

  /**
   * Fetch all classes
   */
  const fetchClasses = async (): Promise<Class[]> => {
    const res = await fetchApi<ClassResponseData[]>(
      API_ENDPOINTS.ENTITY.CLASS,
      "GET",
    );

    if (res.isError || !res.data) {
      throw new Error(`Fetch classes failed: ${res.error?.message}`);
    }

    return res.data.map((item) => new Class(item));
  };

  /**
   * Create a new class
   */
  const createClass = async (data: {
    course_id: string | undefined;
    location: string | undefined;
    identifier: string | undefined;
    status: string | undefined;
    start_date_timestamp: string | undefined;
    end_date_timestamp: string | undefined;
  }): Promise<Class> => {
    const res = await fetchApi<ClassResponseData>(
      API_ENDPOINTS.ENTITY.CLASS,
      "POST",
      data,
    );

    if (res.isError || !res.data) {
      throw new Error(`Create class failed: ${res.error?.message}`);
    }

    return new Class(res.data);
  };

  /*
   * Delete an existing class
   */
  const deleteClass = async (classId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.CLASS}/${classId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete class failed: ${res.error?.message}`);
    }
  };

  /*
   * Update an existing class
   */
  const updateClass = async (
    classId: string,
    data: {
      course_id?: string | undefined;
      location?: string | undefined;
      identifier?: string | undefined;
      status?: string | undefined;
      start_date_timestamp?: string | undefined;
      end_date_timestamp?: string | undefined;
    },
  ): Promise<Class> => {
    const updateData: Record<string, any> = {};

    if (data.course_id !== undefined) updateData.course_id = data.course_id;
    if (data.location !== undefined) updateData.location = data.location;
    if (data.identifier !== undefined) updateData.identifier = data.identifier;
    if (data.status !== undefined) updateData.status = data.status;
    if (data.start_date_timestamp !== undefined)
      updateData.start_date_timestamp = data.start_date_timestamp;
    if (data.end_date_timestamp !== undefined)
      updateData.end_date_timestamp = data.end_date_timestamp;

    const res = await fetchApi<ClassResponseData>(
      `${API_ENDPOINTS.ENTITY.CLASS}/${classId}`,
      "PUT",
      updateData,
    );

    if (res.isError || !res.data) {
      throw new Error(`Update class failed: ${res.error?.message}`);
    }

    return new Class(res.data);
  };

  /**
   * Fetch all courses
   */
  const fetchCourses = async (): Promise<Course[]> => {
    const res = await fetchApi<CourseResponseData[]>(
      API_ENDPOINTS.ENTITY.COURSE,
      "GET",
    );
    if (res.isError || !res.data) {
      throw new Error(`Fetch courses failed: ${res.error?.message}`);
    }
    const courses = res.data.map((item) => new Course(item));
    console.log(courses);
    return courses;
  };

  /**
   * Create a new course
   */
  const createCourse = async (data: {
    identifier: string | undefined;
    name: string | undefined;
  }): Promise<Course> => {
    const res = await fetchApi<CourseResponseData>(
      API_ENDPOINTS.ENTITY.COURSE,
      "POST",
      data,
    );
    if (res.isError || !res.data) {
      throw new Error(`Create course failed: ${res.error?.message}`);
    }
    return new Course(res.data);
  };

  /**
   * Update an existing course
   */
  const updateCourse = async (
    courseId: string,
    data: {
      identifier?: string | undefined;
      name?: string | undefined;
    },
  ): Promise<Course> => {
    const updateData: Record<string, any> = {};

    if (data.identifier !== undefined) updateData.identifier = data.identifier;
    if (data.name !== undefined) updateData.name = data.name;

    const res = await fetchApi<CourseResponseData>(
      `${API_ENDPOINTS.ENTITY.COURSE}/${courseId}`,
      "PUT",
      updateData,
    );
    if (res.isError || !res.data) {
      throw new Error(`Update course failed: ${res.error?.message}`);
    }
    return new Course(res.data);
  };

  /**
   * Delete an existing course
   */
  const deleteCourse = async (courseId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.COURSE}/${courseId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete course failed: ${res.error?.message}`);
    }
  };

  /**
   * Fetch all grades
   */
  const fetchGrades = async (): Promise<Grade[]> => {
    const res = await fetchApi<GradeResponseData[]>(
      `${API_ENDPOINTS.ENTITY.GRADE}`,
      "GET",
    );
    if (res.isError || !res.data) {
      throw new Error(`Fetch grades failed: ${res.error?.message}`);
    }
    const grades = res.data.map((item) => new Grade(item));
    console.log(grades);
    return grades;
  };

  /**
   * Create a new grade
   */
  const createGrade = async (data: {
    class_module_id: string | undefined;
    trainee_id: string | undefined;
    grade: string | undefined;
    grade_type: string | undefined;
  }): Promise<Grade> => {
    const res = await fetchApi<GradeResponseData>(
      `${API_ENDPOINTS.ENTITY.GRADE}`,
      "POST",
      data,
    );
    if (res.isError || !res.data) {
      throw new Error(`Create grade failed: ${res.error?.message}`);
    }
    return new Grade(res.data);
  };

  /**
   * Update an existing grade
   */
  const updateGrade = async (
    gradeId: string,
    data: {
      class_module_id?: string;
      trainee_id?: string;
      grade?: string;
      grade_type?: string;
    },
  ): Promise<Grade> => {
    const updateData: Record<string, any> = {};

    if (data.class_module_id !== undefined)
      updateData.class_module_id = data.class_module_id;
    if (data.trainee_id !== undefined) updateData.trainee_id = data.trainee_id;
    if (data.grade !== undefined) updateData.grade = data.grade;
    if (data.grade_type !== undefined) updateData.grade_type = data.grade_type;

    const res = await fetchApi<GradeResponseData>(
      `${API_ENDPOINTS.ENTITY.GRADE}/${gradeId}`,
      "PUT",
      updateData,
    );
    if (res.isError || !res.data) {
      throw new Error(`Update grade failed: ${res.error?.message}`);
    }
    return new Grade(res.data);
  };

  /**
   * Delete an existing grade
   */
  const deleteGrade = async (gradeId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.GRADE}/${gradeId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete grade failed: ${res.error?.message}`);
    }
  };

  /**
   * Fetch all rooms
   */
  const fetchRooms = async (): Promise<Room[]> => {
    const res = await fetchApi<RoomResponseData[]>(
      `${API_ENDPOINTS.ENTITY.ROOM}`,
      "GET",
    );
    if (res.isError || !res.data) {
      throw new Error(`Fetch rooms failed: ${res.error?.message}`);
    }
    const rooms = res.data.map((item) => new Room(item));
    console.log(rooms);
    return rooms;
  };

  /**
   * Create a new room
   */
  const createRoom = async (data: {
    room_name: string | undefined;
    capacity: number | undefined;
    has_computers: boolean | undefined;
    has_projector: boolean | undefined;
    has_whiteboard: boolean | undefined;
    has_smartboard: boolean | undefined;
  }): Promise<Room> => {
    const res = await fetchApi<RoomResponseData>(
      `${API_ENDPOINTS.ENTITY.ROOM}`,
      "POST",
      data,
    );
    if (res.isError || !res.data) {
      throw new Error(`Create room failed: ${res.error?.message}`);
    }
    return new Room(res.data);
  };

  /**
   * Update an existing grade
   */
  const updateRoom = async (
    roomId: string,
    data: {
      room_name?: string;
      capacity?: number;
      has_computers?: boolean;
      has_projector?: boolean;
      has_whiteboard?: boolean;
      has_smartboard?: boolean;
    },
  ): Promise<Room> => {
    const updateData: Record<string, any> = {};

    if (data.room_name !== undefined) updateData.room_name = data.room_name;

    if (data.capacity !== undefined) updateData.capacity = data.capacity;

    if (data.has_computers !== undefined)
      updateData.has_computers = data.has_computers;

    if (data.has_projector !== undefined)
      updateData.has_projector = data.has_projector;

    if (data.has_whiteboard !== undefined)
      updateData.has_whiteboard = data.has_whiteboard;

    if (data.has_smartboard !== undefined)
      updateData.has_smartboard = data.has_smartboard;

    const res = await fetchApi<RoomResponseData>(
      `${API_ENDPOINTS.ENTITY.ROOM}/${roomId}`,
      "PUT",
      updateData,
    );
    if (res.isError || !res.data) {
      throw new Error(`Update room failed: ${res.error?.message}`);
    }
    return new Room(res.data);
  };

  /**
   * Delete an existing grade
   */
  const deleteRoom = async (roomId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.ROOM}/${roomId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete room failed: ${res.error?.message}`);
    }
  };

  /**
   * Fetch all modules
   */
  const fetchModules = async (): Promise<Module[]> => {
    const res = await fetchApi<ModuleResponseData[]>(
      `${API_ENDPOINTS.ENTITY.MODULE}`,
      "GET",
    );
    if (res.isError || !res.data) {
      throw new Error(`Fetch modules failed: ${res.error?.message}`);
    }
    const rooms = res.data.map((item) => new Module(item));
    console.log(rooms);
    return rooms;
  };

  /**
   * Create a new module
   */
  const createModule = async (data: {
    name: string | undefined;
    duration: number | undefined;
    has_computers: boolean | undefined;
    has_projector: boolean | undefined;
    has_whiteboard: boolean | undefined;
    has_smartboard: boolean | undefined;
  }): Promise<Module> => {
    const res = await fetchApi<ModuleResponseData>(
      `${API_ENDPOINTS.ENTITY.MODULE}`,
      "POST",
      data,
    );
    if (res.isError || !res.data) {
      throw new Error(`Create module failed: ${res.error?.message}`);
    }
    return new Module(res.data);
  };

  /**
   * Update an existing module
   */
  const updateModule = async (
    moduleId: string,
    data: {
      name?: string;
      duration?: number;
      has_computers?: boolean;
      has_projector?: boolean;
      has_whiteboard?: boolean;
      has_smartboard?: boolean;
    },
  ): Promise<Module> => {
    const updateData: Record<string, any> = {};

    if (data.name !== undefined) updateData.name = data.name;

    if (data.duration !== undefined) updateData.duration = data.duration;

    if (data.has_computers !== undefined)
      updateData.has_computers = data.has_computers;

    if (data.has_projector !== undefined)
      updateData.has_projector = data.has_projector;

    if (data.has_whiteboard !== undefined)
      updateData.has_whiteboard = data.has_whiteboard;

    if (data.has_smartboard !== undefined)
      updateData.has_smartboard = data.has_smartboard;

    const res = await fetchApi<ModuleResponseData>(
      `${API_ENDPOINTS.ENTITY.MODULE}/${moduleId}`,
      "PUT",
      updateData,
    );
    if (res.isError || !res.data) {
      throw new Error(`Update module failed: ${res.error?.message}`);
    }
    return new Module(res.data);
  };

  /**
   * Delete an existing module
   */
  const deleteModule = async (moduleId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.MODULE}/${moduleId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete module failed: ${res.error?.message}`);
    }
  };

  /**
   * Fetch all enrollments
   */
  const fetchEnrollments = async (): Promise<Enrollment[]> => {
    const res = await fetchApi<EnrollmentResponseData[]>(
      `${API_ENDPOINTS.ENTITY.ENROLLMENT}`,
      "GET",
    );
    if (res.isError || !res.data) {
      throw new Error(`Fetch enrollment failed: ${res.error?.message}`);
    }
    const rooms = res.data.map((item) => new Enrollment(item));
    console.log(rooms);
    return rooms;
  };

  /**
   * Create a new enrollment
   */
  const createEnrollment = async (data: {
    class_id: string | undefined;
    trainee_id: string | undefined;
    final_grade: string | undefined;
  }): Promise<Enrollment> => {
    const res = await fetchApi<EnrollmentResponseData>(
      `${API_ENDPOINTS.ENTITY.ENROLLMENT}`,
      "POST",
      data,
    );
    if (res.isError || !res.data) {
      throw new Error(`Create enrollment failed: ${res.error?.message}`);
    }
    return new Enrollment(res.data);
  };

  /**
   * Update an existing enrollment
   */
  const updateEnrollment = async (
    enrollmentId: string,
    data: {
      class_id?: string;
      trainee_id?: string;
      final_grade?: string;
    },
  ): Promise<Enrollment> => {
    const updateData: Record<string, any> = {};

    if (data.class_id !== undefined) updateData.class_id = data.class_id;

    if (data.trainee_id !== undefined) updateData.trainee_id = data.trainee_id;

    if (data.final_grade !== undefined)
      updateData.final_grade = data.final_grade;

    const res = await fetchApi<EnrollmentResponseData>(
      `${API_ENDPOINTS.ENTITY.ENROLLMENT}/${enrollmentId}`,
      "PUT",
      updateData,
    );
    if (res.isError || !res.data) {
      throw new Error(`Update enrollment failed: ${res.error?.message}`);
    }
    return new Enrollment(res.data);
  };

  /**
   * Delete an existing enrollment
   */
  const deleteEnrollment = async (enrollmentId: string): Promise<void> => {
    const res = await fetchApi<void>(
      `${API_ENDPOINTS.ENTITY.ENROLLMENT}/${enrollmentId}`,
      "DELETE",
    );

    if (res.isError) {
      throw new Error(`Delete enrollment failed: ${res.error?.message}`);
    }
  };

  return {
    // Sign In/Up
    signIn,
    signUp,
    send2FA,
    verify2FA,
    requestPasswordReset,
    resetPassword,

    // Email Verification
    sendVerificationEmail,
    verifyEmail,
    checkUserEmailValidity,
    sendEmail,

    // User
    getSession,
    logoutUser,
    linkSocial,
    listAccounts,
    signInSocial,
    is2FAEnabled,
    enable2FA,
    disable2FA,

    // Trainees
    fetchTrainees,
    createTrainee,
    updateTrainee,
    deleteTrainee,

    // Trainers
    fetchTrainers,
    createTrainer,
    updateTrainer,
    deleteTrainer,

    // Classes
    fetchClasses,
    createClass,
    updateClass,
    deleteClass,

    // Courses
    fetchCourses,
    createCourse,
    updateCourse,
    deleteCourse,

    // Grades
    fetchGrades,
    createGrade,
    updateGrade,
    deleteGrade,

    // Rooms
    fetchRooms,
    createRoom,
    updateRoom,
    deleteRoom,

    // Modules
    fetchModules,
    createModule,
    updateModule,
    deleteModule,

    // Enrollments
    fetchEnrollments,
    createEnrollment,
    updateEnrollment,
    deleteEnrollment,
  };
};
