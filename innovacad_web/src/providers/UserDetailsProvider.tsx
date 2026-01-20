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
  if (data.trainer_id) return new Trainer(data, data.trainer_id);
  if (data.trainee_id)
    return new Trainee(data, data.trainee_id, data.birthday_date);
  return new User(data);
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
