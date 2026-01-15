import {
  AppError,
  AppErrorType,
  Failure,
  statusToErrorType,
  Success,
  type Result,
} from "@/api/api";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { SignInData } from "@/types/auth";
import { Trainee, Trainer, User, type UserResponseData } from "@/types/user";
import { useNavigate } from "@solidjs/router";
import toast from "solid-toast";

const headers = {
  "Content-Type": "application/json",
  Access: "a",
};

//const baseUrl = "http://localhost:8080";
const baseUrl = "";

export const useApi = () => {
  const { user, logout } = useUserDetails();
  const navigate = useNavigate();

  const fetchApi = async <T>(
    path: string,
    method: string,
    body?: Object
  ): Promise<Result<T>> => {
    try {
      //toast("Your session expired. You'll be redirected to sign in page.");

      if (path != "/sign/in") {
        console.log(path);
        if (!user() || !user()?.token) {
          return new Failure(
            new AppError(AppErrorType.FORBIDDEN, "No token was provided.")
          );
        }
      }

      const reqHeaders: HeadersInit = {
        ...headers,
        ...(user()?.token ? { Authorization: `Bearer ${user()!.token}` } : {}),
      };

      const res = await fetch(`${baseUrl}${path}`, {
        headers: reqHeaders,
        method,
        body: body ? JSON.stringify(body) : undefined,
      });

      let data;

      try {
        data = await res.json();
      } catch (err) {
        data = {
          error: { message: "Unknown error or JSON does not have a response." },
        };
      }

      if (!res.ok) {
        if (res.status == 400) {
          // show error
          console.log(data);
          toast("Your session expired. You'll be redirected to sign in page.");
          logout();
          navigate("/");
        }

        console.log(data);

        return new Failure(
          new AppError(
            statusToErrorType(res.status),
            data?.error?.message || "Unknown error",
            data?.error?.details
          )
        );
      }

      return new Success(data as T);
    } catch (e) {
      console.log(e);
      return new Failure(
        new AppError(AppErrorType.INTERNAL, "Network or parsing error.")
      );
    }
  };

  const signIn = async (data: SignInData): Promise<User | undefined> => {
    console.log(data);

    if ("email" in data && "username" in data)
      throw new Error("Invalid parameters");

    const res = await fetchApi<UserResponseData>("/sign/in", "POST", {
      email: data.email,
      username: data.username,
      password: data.password,
    });

    if (res.isError || !res.data) {
      throw new Error(`SignIn Failed: ${res.error?.message}`);
    }

    const resData = res.data;
    if (resData.trainer_id) return new Trainer(resData, resData.trainer_id);
    if (resData.trainee_id) return new Trainee(resData, resData.trainee_id);

    toast.success("Login successful. You'll be redirected to dashboard", {
      duration: 2000,
    });

    return new User(resData);
  };

  const fetchTrainees = async () => {
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

  const fetchTrainers = async () => {
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

  // Return the functions to the component
  return {
    signIn,
    fetchTrainees,
    fetchTrainers,
  };
};
