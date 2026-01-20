import { createSignal } from "solid-js";
import { A, useNavigate, useSearchParams } from "@solidjs/router";
import { Mail, ArrowLeft } from "lucide-solid";
import { Toaster } from "solid-toast";
import toast from "solid-toast";
import { useApi } from "@/hooks/useApi";

const ResetPasswordPage = () => {
  const api = useApi();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = createSignal(false);
  const [password, setPassword] = createSignal("");
  const [searchParams, setSearchParams] = useSearchParams();

  const token = () => searchParams.token;

  if (!token()) {
    navigate("/");
    return null;
  }

  const handleResetPassword = async (e: Event) => {
    e.preventDefault();
    if (!password()) return toast.error("Please enter your email");

    setIsLoading(true);
    try {
      if (!token()) {
        navigate("/");
        return null;
      }

      const res = await api.resetPassword(
        token()?.toString() || "",
        password(),
      );

      toast.success("Password reset successful!");
      navigate("/");
    } catch (error: any) {
      toast.error(error.message || "Failed to reset password.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div class="min-h-screen bg-base-200 flex items-center justify-center p-4">
      <Toaster position="top-center" />

      <div class="card w-full max-w-md bg-base-100 shadow-xl overflow-hidden">

        <div class="card-body pt-4">
          <form onSubmit={handleResetPassword} class="flex flex-col gap-4">
            <div class="text-center mb-2">
              <h2 class="text-2xl font-bold">Reset Password</h2>
              <p class="text-base-content/60 text-sm">
                Create a new password for your account.
              </p>
            </div>

            <div class="form-control ">
              <label class="label">
                <span class="label-text font-medium">New Password</span>
              </label>
              <label class="input input-bordered flex items-center gap-2">
                <Mail size={16} class="opacity-70" />
                <input
                  type="password"
                  placeholder="Enter you new password"
                  class="grow"
                  value={password()}
                  onInput={(e) => setPassword(e.currentTarget.value)}
                />
              </label>
            </div>

            <button
              type="submit"
              class="btn btn-primary w-full mt-2"
              disabled={isLoading()}
            >
              {isLoading() ? (
                <span class="loading loading-spinner"></span>
              ) : (
                "Create new Password"
              )}
            </button>
          </form>

          <div class="divider my-4"></div>
          <div class="text-center">
            <A
              href="/login"
              class="link link-hover text-sm flex items-center justify-center gap-2 text-base-content/70 hover:text-primary transition-colors"
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

export default ResetPasswordPage;
