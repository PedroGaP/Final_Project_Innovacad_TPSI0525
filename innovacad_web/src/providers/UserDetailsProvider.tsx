import {
  createContext,
  createSignal,
  useContext,
  createEffect,
} from "solid-js";
import Cookies from "js-cookie";
import { Trainee, Trainer, User, type UserResponseData } from "@/types/user";
import type { UserDetailsContextType } from "@/types/user_context";
import type { JSX } from "solid-js/jsx-runtime";

const UserDetailsContext = createContext<UserDetailsContextType>();

const hydrateUser = (
  data: UserResponseData | null,
): User | Trainee | Trainer | null => {
  if (!data) return null;

  let instance: User | Trainee | Trainer;

  if (data.trainee_id) {
    instance = new Trainee(data, data.trainee_id, data.birthday_date);
  } else if (
    data.trainer_id ||
    data.role === "trainer" ||
    data.role === "coordinator"
  ) {
    instance = new Trainer(
      data,
      data.trainer_id || data.id || "unknown_trainer_id",
      data.birthday_date,
    );
  } else {
    instance = new User(data);
  }

  Object.assign(instance, data);

  return instance;
};

export const UserDetailsProvider = (props: { children: JSX.Element }) => {
  const saved = Cookies.get("user_session");
  const initialData = saved ? JSON.parse(saved) : null;

  const [user, setUser] = createSignal<User | Trainee | Trainer | null>(
    hydrateUser(initialData),
  );

  createEffect(() => {
    const currentUser = user();
    if (currentUser) {
      Cookies.set("user_session", JSON.stringify(currentUser), { expires: 7 });
    } else {
      Cookies.remove("user_session");
    }
  });

  const logout = () => {
    setUser(null);
    const allCookies = Cookies.get();

    Object.keys(allCookies).forEach((cookieName) => {
      Cookies.remove(cookieName);
      Cookies.remove(cookieName, { path: "/" });
    });

    window.location.href = "/";
  };

  return (
    <UserDetailsContext.Provider value={{ user, setUser, logout }}>
      {props.children}
    </UserDetailsContext.Provider>
  );
};

export const useUserDetails = () => {
  const context = useContext(UserDetailsContext);
  if (!context) {
    throw new Error(
      "useUserDetails deve ser usado dentro de um UserDetailsProvider",
    );
  }
  return context;
};
