/* @refresh reload */

import { type RouteDefinition, Router } from "@solidjs/router";
import { render } from "solid-js/web";
import "@/index.css";
import NotFound from "@/pages/NotFound";
import SignIn from "@/pages/SignIn";
import { ThemeProvider } from "@/providers/ThemeProvider";
import DashboardLayout from "./pages/Dashboard";
import DashboardHome from "./pages/Dashboard/Home";
import ClassesPage from "./pages/Dashboard/Class";
import PublicLayout from "./components/PublicLayout";
import TrainerPage from "./pages/Dashboard/User/Trainer";
import TraineePage from "./pages/Dashboard/User/Trainee";
import { UserDetailsProvider } from "./providers/UserDetailsProvider";
import SettingsPage from "./pages/Dashboard/Settings";
import { Toaster } from "solid-toast";
import VerifyEmail from "./pages/VerifyEmail";
import Verify2FA from "./pages/Verify2FA";
import ResetPasswordPage from "./pages/ResetPassword";
import ForgotPasswordPage from "./pages/ForgotPassword";
import CoursesPage from "./pages/Dashboard/Course";
import GradesPage from "./pages/Dashboard/Grade";
import RoomsPage from "./pages/Dashboard/Room";
import ModulesPage from "./pages/Dashboard/Module";

const routes: RouteDefinition[] = [
  {
    path: "/",
    component: PublicLayout,
    children: [{ path: "/", component: SignIn }],
  },
  {
    path: "/reset-password",
    component: ResetPasswordPage,
  },
  {
    path: "/forgot-password",
    component: ForgotPasswordPage,
  },
  {
    path: "/verify-email",
    component: VerifyEmail,
  },
  {
    path: "/verify-2fa",
    component: Verify2FA,
  },
  {
    path: "/dashboard",
    component: DashboardLayout,
    children: [
      {
        path: "/",
        component: DashboardHome,
      },
      {
        path: "/settings",
        component: SettingsPage,
      },
      {
        path: "/user",
        children: [
          {
            path: "/trainers",
            component: TrainerPage,
          },
          {
            path: "/trainees",
            component: TraineePage,
          },
        ],
      },
      {
        path: "/classes",
        component: ClassesPage,
      },
      {
        path: "/courses",
        component: CoursesPage,
      },
      {
        path: "/grades",
        component: GradesPage,
      },
      {
        path: "/rooms",
        component: RoomsPage,
      },
      {
        path: "/modules",
        component: ModulesPage,
      },
    ],
  },
  { path: "**", component: NotFound },
];

render(
  () => (
    <ThemeProvider>
      <UserDetailsProvider>
        <Toaster position="bottom-right" gutter={8} />
        <div class="min-h-screen bg-base-300 font-sans antialiased text-base-content">
          <Router>{routes}</Router>
        </div>
      </UserDetailsProvider>
    </ThemeProvider>
  ),
  document.getElementById("root")!,
);
