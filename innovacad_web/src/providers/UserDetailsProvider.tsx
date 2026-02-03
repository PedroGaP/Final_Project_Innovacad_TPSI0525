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

  // 1. Verificar se é Trainee
  if (data.trainee_id || data.role === "trainee") {
    // Fallback seguro se o ID não vier
    const tId = data.trainee_id || data.id || "unknown_trainee";
    instance = new Trainee(data, tId, data.birthday_date);
  }
  // 2. Verificar se é Trainer OU Coordinator (ambos usam classe Trainer)
  else if (
    data.trainer_id ||
    data.role === "trainer" ||
    data.role === "coordinator"
  ) {
    // Fallback seguro se o ID não vier
    const tId = data.trainer_id || data.id || "unknown_trainer";
    instance = new Trainer(data, tId, data.birthday_date);

    // Forçar a flag de coordenador se o role o disser
    if (data.role === "coordinator") {
      (instance as Trainer).is_coordinator = true;
    }
  }
  // 3. Utilizador genérico (Admin, etc)
  else {
    instance = new User(data);
  }

  // Copiar todas as propriedades do JSON para a instância para garantir que nada se perde
  Object.assign(instance, data);

  return instance;
};

export const UserDetailsProvider = (props: { children: JSX.Element }) => {
  const saved = Cookies.get("user_session");
  let initialData = null;

  try {
    initialData = saved ? JSON.parse(saved) : null;
  } catch (e) {
    console.error("Erro ao ler cookie user_session", e);
  }

  const [user, setUser] = createSignal<User | Trainee | Trainer | null>(
    hydrateUser(initialData),
  );

  createEffect(() => {
    const currentUser = user();
    if (currentUser) {
      // Usamos JSON.stringify que vai chamar o .toJson() das classes se existir,
      // ou serializar as propriedades públicas.
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
