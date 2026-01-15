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

// Função auxiliar para transformar JSON em Classe
const hydrateUser = (
  data: UserResponseData | null
): User | Trainee | Trainer | null => {
  if (!data) return null;
  if (data.trainer_id) return new Trainer(data, data.trainer_id);
  if (data.trainee_id)
    return new Trainee(data, data.trainee_id, data.birthday_date);
  return new User(data);
};

export const UserDetailsProvider = (props: { children: JSX.Element }) => {
  // 1. Ler do cookie e re-hidratar imediatamente
  const saved = Cookies.get("user_session");
  const initialData = saved ? JSON.parse(saved) : null;

  const [user, setUser] = createSignal<User | Trainee | Trainer | null>(
    hydrateUser(initialData)
  );

  // 2. Persistência automática
  createEffect(() => {
    const currentUser = user();
    if (currentUser) {
      // Guardamos o estado "bruto" (JSON) no cookie
      Cookies.set("user_session", JSON.stringify(currentUser), { expires: 7 });
    } else {
      Cookies.remove("user_session");
    }
  });

  const logout = () => {
    setUser(null);
    window.location.href = "/";
  };

  return (
    // Agora o valor 'user' (que é a função Accessor) bate com o tipo esperado
    <UserDetailsContext.Provider value={{ user, setUser, logout }}>
      {props.children}
    </UserDetailsContext.Provider>
  );
};

// Hook utilitário para facilitar o acesso
export const useUserDetails = () => {
  const context = useContext(UserDetailsContext);
  if (!context) {
    throw new Error(
      "useUserDetails deve ser usado dentro de um UserDetailsProvider"
    );
  }
  return context;
};
