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
import EnrollmentsPage from "./pages/Dashboard/Enrollment";
import AvailabilitiesPage from "./pages/Dashboard/Availability";
import Calendar from "./pages/Dashboard/Calendar";
import Courses from "./pages/Courses";
import { TransProvider } from "@mbarzda/solid-i18next";
import { createEffect } from "solid-js";
import i18next from "i18next";
import englishTranslation from "./locale/englishTranslation";
import portugueseTranslation from "./locale/portugueseTranslation";

const routes: RouteDefinition[] = [
  {
    path: "/",
    component: PublicLayout,
    children: [{ path: "/", component: SignIn }],
  },
  {
    path: "/courses",
    component: Courses,
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
      {
        path: "/calendar",
        component: Calendar,
      },
      {
        path: "/enrollments",
        component: EnrollmentsPage,
      },
      {
        path: "/availabilities",
        component: AvailabilitiesPage,
      },
    ],
  },
  { path: "**", component: NotFound },
];

createEffect(() => {
  i18next.init({
    lng: "en-EN",
    fallbackLng: "en-EN",
    interpolation: {
      escapeValue: false,
    },
    resources: {
      "en-EN": {
        translation: englishTranslation,
      },
      "pt-PT": {
        translation: portugueseTranslation,
      },
    },
  });
});

render(
  () => (
    <TransProvider lng="en">
      <ThemeProvider>
        <UserDetailsProvider>
          <Toaster position="bottom-right" gutter={8} />
          <div class="min-h-screen bg-base-300 font-sans antialiased text-base-content">
            <Router>{routes}</Router>
          </div>
        </UserDetailsProvider>
      </ThemeProvider>
    </TransProvider>
  ),
  document.getElementById("root")!,
);
