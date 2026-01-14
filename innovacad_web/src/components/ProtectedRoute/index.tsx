import { useNavigate } from "@solidjs/router";
import { Show, createEffect, type JSX } from "solid-js";
import { useUserDetails } from "@/providers/UserDetailsProvider";

interface ProtectedRouteProps {
  children: JSX.Element;
}

export const ProtectedRoute = (props: ProtectedRouteProps) => {
  const { user } = useUserDetails();
  const navigate = useNavigate();

  createEffect(() => {
    if (!user()) {
      navigate("/", { replace: true });
    }
  });

  return <Show when={user()}>{props.children}</Show>;
};
