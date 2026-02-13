import {
  createSignal,
  onCleanup,
  onMount,
  Show,
} from "solid-js";
import { Mail, ArrowLeft } from "lucide-solid";
import { useNavigate } from "@solidjs/router";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useI18n } from "@/hooks/useL18N";

const Verify2FA = () => {
  const { user } = useUserDetails();
  const { send2FA, verify2FA } = useApi();
  const navigate = useNavigate();
  const { t } = useI18n();

  console.log(user());

  if (user()?.email !== undefined) {
    navigate("/dashboard/");
    return;
  }

  const [code, setCode] = createSignal("");
  const [seconds, setSeconds] = createSignal<number>(0);
  const [loading, setLoading] = createSignal(false);
  let timerInterval: any;

  const countdown = () => {
    setSeconds(30);

    if (timerInterval) clearInterval(timerInterval);

    timerInterval = setInterval(() => {
      setSeconds((prev) => {
        if (prev <= 1) {
          clearInterval(timerInterval);
          return 0;
        }

        return prev - 1;
      });
    }, 1000);
  };

  const handleFocus = () => {
    console.log("Windows is focused!");
  };

  onCleanup(() => {
    if (timerInterval) clearInterval(timerInterval);
    window.removeEventListener("focus", handleFocus);
    document.removeEventListener("visibilitychange", handleFocus);
  });

  onMount(async () => {
    window.addEventListener("focus", handleFocus);
    document.addEventListener("visibilitychange", handleFocus);
  });

  const handleResend = async () => {
    if (seconds() > 0) return;

    countdown();
    try {
      const res = await send2FA();

      if (!res) {
        toast.error(t("auth.verify_2fa.toast_send_fail"));
        return;
      }
      toast.success(t("auth.verify_2fa.toast_sent"));
    } catch (e) {
      console.error(e);
      toast.error(t("auth.verify_2fa.toast_send_fail"));
    }
  };

  const handlePaste = (e: ClipboardEvent) => {
    e.preventDefault();
    const pasteData = e.clipboardData?.getData("text");
    console.log(pasteData);
    setCode(pasteData ?? "");
  };

  const handleVerify = async (e: Event) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await verify2FA(code());

      if (!res) {
        toast.error(t("auth.verify_2fa.toast_verify_fail"));
        return;
      }

      toast.success(t("auth.verify_2fa.toast_verify_success"));
    } catch (e) {
      toast.error(t("auth.verify_2fa.toast_verify_fail"));
    } finally {
      setLoading(false);
      countdown();
    }
  };

  return (
    <div class="hero min-h-screen bg-base-200">
      <div class="hero-content text-center">
        <div class="card w-full max-w-md shadow-2xl bg-base-100 p-12 items-center text-center">
          <div class="bg-primary/10 p-4 rounded-2xl mb-6">
            <Mail size={40} class="text-primary" />
          </div>

          <h1 class="text-3xl font-bold mb-2">{t("auth.verify_2fa.title")}</h1>
          <p class="text-base-content/70 mb-8">
            {t("auth.verify_2fa.desc")}
          </p>

          <form onSubmit={handleVerify} class="w-full">
            <div class="flex justify-between gap-2 mb-8" onPaste={handlePaste}>
              <input
                class="input input-primary w-full"
                placeholder={t("auth.verify_2fa.paste_placeholder")}
                value={code()}
                onInput={(e) => {
                  e.preventDefault();
                  setCode(e.currentTarget.value);
                }}
              ></input>
            </div>

            <button
              type="submit"
              class="btn btn-primary w-full text-lg mb-6"
              disabled={code().length < 1 || loading()}
            >
              {loading() ? (
                <span class="loading loading-spinner"></span>
              ) : (
                t("auth.verify_2fa.verify_btn")
              )}
            </button>
          </form>

          <div class="flex flex-col gap-4 items-center">
            <p class="text-sm">
              {t("auth.verify_2fa.did_not_receive")}{" "}
              <button
                class="link link-primary font-bold no-underline hover:underline"
                onclick={() => handleResend()}
              >
                <Show
                  when={seconds() == 0}
                  fallback={t("auth.verify_2fa.wait_msg", { seconds: seconds() })}
                >
                  {t("auth.verify_2fa.resend_btn")}
                </Show>
              </button>
            </p>

            <button class="btn btn-ghost btn-sm gap-2">
              <ArrowLeft size={16} />
              {t("auth.verify_2fa.back_to_login")}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Verify2FA;
