import { A, useNavigate } from "@solidjs/router";
import { TbLogin } from "solid-icons/tb";
import { createStore } from "solid-js/store";
import GoogleLogo from "@/assets/google.svg";
import type { SignInData } from "@/types/auth";
import type { User } from "@/types/user";
import debounce from "@/utils/debounce";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { useApi } from "@/hooks/useApi";

const SignIn = () => {
  const api = useApi();
  const { setUser } = useUserDetails();
  const [signInStore, setSignInStore] = createStore<SignInData>({
    password: "",
    username: undefined,
    email: undefined,
  });
  const navigate = useNavigate();

  const handleSocialLogin = async () => {
    try {
      const res = await api.signInSocial();
    } catch (error) {
      console.log(error);
    }
  };

  const handleEmailSignIn = async () => {
    const user: User | undefined = await api.signIn({
      email: signInStore.email,
      password: signInStore.password,
    });

    setUser(user!);

    console.log(`[USER] > ${JSON.stringify(user)}`);

    if (user?.twoFactorRedirect) {
      console.log("Sent to the 2FA verification page!");
      navigate("/verify-2fa");
      return;
    }

    if (!user?.verified) {
      console.log("Sent to the email verification page!");
      navigate("/verify-email");
      return;
    }

    console.log("Sent to the dashboard page!");
    navigate("/dashboard");
  };

  const handleInput = debounce((key: any, value: any) => {
    setSignInStore(key, value);
  }, 100);

  return (
    <div class="min-h-screen flex items-center justify-center bg-base-300 px-4">
      <div class="card w-full max-w-sm bg-base-100 shadow-2xl overflow-hidden">
        {/* Card Header (Internal) */}
        <div class="bg-primary p-6 text-primary-content">
          <h2 class="card-title text-2xl font-bold flex items-center gap-2">
            <TbLogin />
            Sign In
          </h2>
          <p class="text-primary-content/80 text-sm mt-1">
            Access into your account
          </p>
        </div>

        <div class="card-body gap-1 p-6">
          {/* Email */}
          <div class="form-control">
            <label class="label">
              <span class="label-text font-medium">Email</span>
            </label>
            <input
              type="email"
              placeholder="name@example.com"
              class="input input-bordered focus:input-primary transition-all"
              onInput={(e) => handleInput("email", e.target.value)}
            />
          </div>

          {/* Password */}
          <div class="form-control mt-2">
            <label class="label">
              <span class="label-text font-medium">Password</span>
            </label>
            <input
              type="password"
              placeholder="••••••••"
              class="input input-bordered focus:input-primary transition-all"
              onInput={(e) => handleInput("password", e.target.value)}
            />
            <A
              href={`/forgot-password`}
              class="label-text-alt link link-hover text-primary"
            >
              Forgot Password?
            </A>
          </div>

          {/* Card Actions (Internal Footer) */}
          <div class="card-actions flex-col mt-6 gap-3">
            <button
              class="btn btn-primary btn-block shadow-lg"
              onClick={handleEmailSignIn}
            >
              Login
            </button>

            <div class="divider text-xs uppercase opacity-50 font-bold">Or</div>

            <button
              class="btn btn-outline btn-block border-base-300 hover:bg-base-200  uppercase"
              onClick={handleSocialLogin}
            >
              <img src={GoogleLogo} alt="Google" class="w-5 h-5 mr-2" />
              Sign In with Google
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SignIn;
