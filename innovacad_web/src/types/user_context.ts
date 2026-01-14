import { User, Trainee, Trainer } from "@/types/user";
import type { Accessor, Setter } from "solid-js";

export interface UserDetailsContextType {
  user: Accessor<User | Trainee | Trainer | null>;
  setUser: Setter<User | Trainee | Trainer | null>;
  logout: () => void;
}
