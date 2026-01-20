import { useApi } from "@/hooks/useApi";
// import type { Trainee, Trainer, User } from "@/types/user";
import { onMount, createEffect, createSignal } from "solid-js";

// type TUser = Accessor<User | Trainer | Trainee | null>;

const TwoFactorCard = (user: any) => {
  const { enable2FA, disable2FA, send2FA, verify2FA } = useApi();
  const [twoFactorStatus, setTwoFactorStatus] = createSignal<boolean>(false);

  onMount(() => {
    const currentUser = user();
    if (!currentUser) return;
    setTwoFactorStatus(currentUser.twoFactorEnabled!);
  });

  createEffect(async () => {
    const current2FAStatus = twoFactorStatus();

    if (current2FAStatus) await enable2FA();
    else await disable2FA();
  });

  return (
    <div class="flex flex-col gap-4">
      <div>
        <span>2FA Status:</span>
        <input
          type="checkbox"
          class="toggle toggle-primary"
          checked={twoFactorStatus()}
          onChange={async (e: Event) =>
            setTwoFactorStatus((e.target as HTMLInputElement).checked)
          }
        />
      </div>
      {twoFactorStatus() && (
        <div>
          <span>Code:</span>
          <input
            type="text"
            class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary"
          />
          <button />
        </div>
      )}
    </div>
  );
};

export default TwoFactorCard;
