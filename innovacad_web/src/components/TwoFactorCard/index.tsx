import { useApi } from "@/hooks/useApi";
// import type { Trainee, Trainer, User } from "@/types/user";
import { onMount, createEffect, createSignal } from "solid-js";

// type TUser = Accessor<User | Trainer | Trainee | null>;

const TwoFactorCard = (user: any) => {
  const { enable2FA, disable2FA } = useApi();
  const [twoFactorStatus, setTwoFactorStatus] = createSignal<boolean>(false);

  onMount(() => {
    const currentUser = user();
    console.log(currentUser);
    if (!currentUser) return;
    setTwoFactorStatus(currentUser.twoFactorEnabled!);
  });

  createEffect(async () => {
    const current2FAStatus = twoFactorStatus();

    if (current2FAStatus) await enable2FA();
    else await disable2FA();
  });

  return (
<div class="flex flex-col rounded-lg border border-base-300 bg-base-200 transition-all duration-200">
    {/* Top Row: Matches your 'Connect' style exactly */}
    <div class="flex items-center justify-between p-4">
      <div class="flex items-center gap-4">
        {/* Icon Box */}
        <div class="w-10 h-10 bg-base-100 rounded-lg flex items-center justify-center shadow-sm text-primary">
          {/* Shield Icon SVG */}
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="w-6 h-6"
          >
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
          </svg>
        </div>

        {/* Text Column */}
        <div class="flex flex-col">
          <span class="font-bold text-sm">Two-Factor Authentication</span>
          <span class="text-xs opacity-60">
            Secure your account with 2FA
          </span>
        </div>
      </div>

      {/* Action: Toggle Switch */}
      <input
        type="checkbox"
        class="toggle toggle-primary"
        checked={twoFactorStatus()}
        onChange={async (e) =>
          setTwoFactorStatus((e.target as HTMLInputElement).checked)
        }
      />
    </div>
  </div>
  );
};

export default TwoFactorCard;
