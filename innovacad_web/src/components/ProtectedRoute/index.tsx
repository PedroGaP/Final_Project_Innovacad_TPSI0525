import { useNavigate } from "@solidjs/router";
import { Show, createEffect, onMount, createSignal, type JSX } from "solid-js";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useApi } from "@/hooks/useApi";

interface ProtectedRouteProps {
  children: JSX.Element;
  role?: string;
}

export const ProtectedRoute = (props: ProtectedRouteProps) => {
  // 1. Destructure setUser so we can update the state after fetching
  const { user, setUser } = useUserDetails();
  const api = useApi();
  const navigate = useNavigate();

  // 2. Add a loading signal, default to true
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

      // 3. CRITICAL: Update the user provider with the fetched data
      // If your API returns the user object directly in 'res' or 'res.data':
      if (res) {
        setUser(res); // Ensure your Provider exposes this setter
      }
    } catch (error) {
      console.error("Failed to validate session:", error);
    } finally {
      // 4. Once finished (success or fail), stop loading to allow checks to run
      setIsLoading(false);
    }
  });

  createEffect(() => {
    // 5. BLOCK redirects while loading
    if (isLoading()) return;

    const currentUser = user();

    // Now this only runs AFTER the session check is done
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

  // 6. Show a loader or nothing while checking session
  return (
    <Show
      when={!isLoading()}
      fallback={<div class="p-4">Loading session...</div>}
    >
      <Show when={isAuthorized()}>{props.children}</Show>
    </Show>
  );
};
