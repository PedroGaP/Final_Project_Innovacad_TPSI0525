import { useUserDetails } from "@/providers/UserDetailsProvider";
import { Upload } from "lucide-solid";
import { createResource, Show } from "solid-js";
import GoogleLogo from "@/assets/google.svg";
import SocialAuthCard from "@/components/SocialAuthCard";
import TwoFactorCard from "@/components/TwoFactorCard";
import FacebookLogo from "@/assets/facebook.svg";
import { useApi } from "@/hooks/useApi";

const AccountSettingsPage = () => {
  const { user } = useUserDetails();
  const { listAccounts } = useApi();
  const [accounts, { refetch }] = createResource(async () => listAccounts());

  const formatDateForInput = (epoch: number | undefined | null) => {
    if (!epoch) return "";

    const d = new Date(0);
    d.setUTCSeconds(epoch);

    return d.toISOString().split("T")[0];
  };

  const getUserBirthday = () => {
    const currentUser = user();
    if (!currentUser) return "";

    if ("birthdayDate" in currentUser) {
      return formatDateForInput((currentUser as any).birthdayDate);
    }

    return "";
  };

  return (
    <>

      <div class="w-full flex-1 min-h-full border-base-300 bg-base-100">
        <div class="flex justify-between items-center p-6 border-b border-base-200">
          <div>
            <h3 class="text-lg font-bold">Personal Info</h3>
            <p class="text-sm opacity-60">Update your personal details</p>
          </div>
          <div class="flex gap-3">
            <button class="btn btn-sm btn-ghost opacity-70 hover:opacity-100">
              Cancel
            </button>
            <button class="btn btn-sm btn-accent text-white px-6 shadow-md">
              Save
            </button>
          </div>
        </div>

        <div class="p-6 space-y-6">
          <div class="form-control">
            <label class="label pt-0">
              <span class="label-text opacity-70 font-medium">Your photo</span>
            </label>
            <div class="flex items-center gap-6">
              <div class="avatar">
                <div class="w-16 h-16 rounded-full ring ring-base-200 ring-offset-2 ring-offset-base-100">
                  <Show
                    when={!!user()?.image}
                    fallback={
                      <img
                        src={"https://ui-avatars.com/api/?name=" + user()!.name}
                        alt="User avatar"
                      />
                    }
                  >
                    <img src={user()!.image} alt="avatar" />
                  </Show>
                </div>
              </div>
              <div class="flex flex-col gap-1">
                <div class="flex items-center gap-3">
                  <button class="btn btn-sm btn-outline border-base-300 hover:border-base-content hover:bg-base-200 hover:text-base-content normal-case font-normal">
                    <Upload size={14} class="mr-1" /> Upload Image
                  </button>
                  <span class="text-xs opacity-50">JPG or PNG. 1MB max</span>
                </div>
              </div>
            </div>
          </div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">Full name</span>
            </label>
            <input
              type="text"
              value={user()!.name}
              class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
            />
          </div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">Username</span>
            </label>
            <input
              type="text"
              value={user()!.username}
              class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
              disabled
            />
          </div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">Email</span>
            </label>
            <input
              type="email"
              value={user()!.email}
              class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
              disabled
            />
          </div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">
                Date of birth
              </span>
            </label>
            <input
              type="date"
              value={getUserBirthday()}
              class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary"
            />
          </div>

          <div class="divider pt-2"></div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">
                Linked Accounts
              </span>
            </label>

            <div class="flex flex-col gap-4">
              <SocialAuthCard
                logo={GoogleLogo}
                logo_alt="Google Logo"
                title="Google"
                is_linked={
                  accounts()?.find((a) => a.providerId == "google") != null
                }
                provider="google"
              />
              <SocialAuthCard
                logo={FacebookLogo}
                logo_alt="Facebook Logo"
                title="Facebook"
                is_linked={
                  accounts()?.find((a) => a.providerId == "facebook") != null
                }
                provider="facebook"
              />
            </div>
            <div class="divider pt-2"></div>
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  Security Settings
                </span>
              </label>
              <TwoFactorCard />
            </div>
          </div>
                      

        </div>
      </div>
    </>
  );
};

export default AccountSettingsPage;
