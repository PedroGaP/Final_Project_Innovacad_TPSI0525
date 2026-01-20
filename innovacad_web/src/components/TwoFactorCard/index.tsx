import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { createEffect, createSignal } from "solid-js";
import { Icon } from "../Icon";
import toast from "solid-toast";

const TwoFactorCard = () => {
  const { user } = useUserDetails();
  const { enable2FA, disable2FA, is2FAEnabled } = useApi();
  
  const [is2FA, setIs2FA] = createSignal<boolean>(false);
  const [password, setPassword] = createSignal<string>("");
  const [isLoading, setIsLoading] = createSignal<boolean>(false);

  createEffect(async () => {
    const userId = user()?.id;
    if (!userId) return;

    try {
      const status = await is2FAEnabled(userId);
      setIs2FA(status);
    } catch (e) {
      console.error("Failed to fetch 2FA status", e);
    }
  });

  const handle2FA = async () => {
    if (password() === "") {
      toast.error("Please enter your password first.");
      return;
    }

    setIsLoading(true);

    try {
      if (is2FA()) {
        await disable2FA(password());
        setIs2FA(false);
        toast.success("2FA Disabled!");
      } else {
        await enable2FA(password());
        setIs2FA(true);
        toast.success("2FA Enabled!");
      }
      setPassword(""); 
    } catch (error) {
      console.log(password())
      toast.error("Operation failed. Check your password.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div class="flex flex-col rounded-lg border border-base-300 bg-base-200 transition-all duration-200">
      <div class="flex items-center justify-between p-4">
        <div class="flex items-center gap-4">
          <div class={`w-10 h-10 rounded-lg flex items-center justify-center shadow-sm ${is2FA() ? 'bg-primary text-primary-content' : 'bg-white text-primary'}`}>
            <Icon name="Shield" size={30} />
          </div>

          <div class="flex flex-col">
            <span class="font-bold text-sm">Two-Factor Authentication</span>
            <span class="text-xs opacity-60">
              {is2FA() ? "Your account is secure." : "Secure your account with 2FA."}
            </span>
          </div>
        </div>

        <input
          type="checkbox"
          class="toggle toggle-primary cursor-default"
          checked={is2FA()}
          disabled
        />
      </div>

      <div class="border-t border-base-300 bg-base-100/50 p-4 rounded-b-lg animate-in slide-in-from-top-2">
        <div class="flex flex-col gap-3">
          <div class="text-sm">
            <span class="opacity-70">Please enter your password to </span>
            <span class={`font-bold ${is2FA() ? 'text-error' : 'text-primary'}`}>
              {is2FA() ? 'disable' : 'enable'}
            </span>
            <span class="opacity-70"> 2FA.</span>
          </div>

          <div class="join w-full shadow-sm">
            <div class="relative w-full">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-base-content/50">
                <Icon name="Lock" size={16} />
              </div>
              <input
                type="password"
                placeholder="Current Password"
                class="input input-bordered join-item w-full pl-10 focus:outline-offset-0"
                value={password()} 
                disabled={isLoading()}
                onInput={(e) => setPassword(e.target.value)}
              />
            </div>

            <button
              class={`btn join-item border-none w-24 ${is2FA() ? 'btn-error text-white' : 'btn-primary'}`}
              onClick={handle2FA}
              disabled={isLoading()}
            >
              {isLoading() ? (
                <span class="loading loading-spinner loading-xs"></span>
              ) : (
                is2FA() ? 'Disable' : 'Enable'
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TwoFactorCard;