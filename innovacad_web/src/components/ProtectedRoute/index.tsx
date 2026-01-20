import { useNavigate } from "@solidjs/router";
import { Show, createEffect, onMount, createSignal, type JSX } from "solid-js";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useApi } from "@/hooks/useApi";

interface ProtectedRouteProps {
  children: JSX.Element;
  role?: string;
}

export const ProtectedRoute = (props: ProtectedRouteProps) => {
  const { user, setUser } = useUserDetails();
  const api = useApi();
  const navigate = useNavigate();

  const [isLoading, setIsLoading] = createSignal(true);

  const isAuthorized = () => {
    const currentUser = user();
    if (!currentUser) return false;
    if (props.role && currentUser.role !== props.role) return false;
    return true;
  };

  onMount(async () => {
    try {
      console.log("Checking session...");
      const res = await api.getSession();

      if (res) {
        setUser(res);
      }
    } catch (error) {
      console.error("Failed to validate session:", error);
    } finally {
      setIsLoading(false);
    }
  });

  createEffect(() => {
    if (isLoading()) return;

    const currentUser = user();

    if (!currentUser) {
      navigate("/", { replace: true });
      return;
    }

    if (props.role && currentUser.role !== props.role) {
      console.warn(
        `Access denied: User role '${currentUser.role}' does not match required '${props.role}'`,
      );
      navigate("/", { replace: true });
    }
  });

  return (
    <Show
      when={!isLoading()}
      fallback={<div class="p-4">Loading session...</div>}
    >
      <Show when={isAuthorized()}>{props.children}</Show>
    </Show>
  );
};
