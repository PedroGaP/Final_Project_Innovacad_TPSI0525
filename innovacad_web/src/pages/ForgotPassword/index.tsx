import { useApi } from "@/hooks/useApi";
import { A } from "@solidjs/router";
import { Mail, ArrowLeft } from "lucide-solid";
import { createSignal } from "solid-js";
import toast from "solid-toast";

const ForgotPasswordPage = () => {
  const [email, setEmail] = createSignal("");
  const api = useApi();

  return (
    <div class="min-h-screen bg-base-200 flex items-center justify-center p-4">
      <div class="card w-full max-w-sm bg-base-100 shadow-xl">
        <div class="card-body items-center text-center p-8">
          <div class="w-20 h-20 bg-primary/10 rounded-full flex items-center justify-center mb-4 text-primary animate-in zoom-in duration-300">
            <Mail size={40} />
          </div>

          <h2 class="card-title text-2xl font-bold mb-2">Enter your Email</h2>

          <p class="text-base-content/70 mb-6 text-sm">
            We'll send a verification link to your email. <br />
            Please click on the link in that email to reset your password.
          </p>

          <div class="form-control w-full">
            <label class="input input-bordered flex items-center gap-2">
              <Mail size={16} class="opacity-70" />
              <input
                type="email"
                placeholder="Enter your email"
                class="grow"
                value={email()}
                onInput={(e) => setEmail(e.currentTarget.value)}
                required
              />
            </label>
          </div>
          <br />

          <button
            class="btn btn-primary w-full gap-2 shadow-lg"
            onclick={async () => {
              if (!email()) {
                toast.error("Please enter your email!");
                return;
              }
              await api.requestPasswordReset(email());
            }}
          >
            Send
          </button>

          <div class="divider my-4 text-xs text-base-content/30">OR</div>

          <div class="mt-2">
            <A
              href="/"
              class="link link-hover text-sm flex items-center justify-center gap-2 text-base-content/60 hover:text-primary transition-colors"
            >
              <ArrowLeft size={16} />
              Back to Login
            </A>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ForgotPasswordPage;
