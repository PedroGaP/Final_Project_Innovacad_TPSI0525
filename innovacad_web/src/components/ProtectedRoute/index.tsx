import { useNavigate } from "@solidjs/router";
import { Show, createEffect, type JSX } from "solid-js";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useApi } from "@/hooks/useApi";

interface ProtectedRouteProps {
  children: JSX.Element;
}

export const ProtectedRoute = (props: ProtectedRouteProps) => {
  const { user } = useUserDetails();
  const { getSession } = useApi();
  const navigate = useNavigate();

  createEffect(async () => {
    const session = await getSession();
    console.log(session);
  });

  return <Show when={user()}>{props.children}</Show>;
};
