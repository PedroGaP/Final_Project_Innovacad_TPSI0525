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

const routes: RouteDefinition[] = [
  {
    path: "/",
    component: PublicLayout,
    children: [{ path: "/", component: SignIn }],
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
        path: "/user",
        //component: UsersPage,
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
    ],
  },
  { path: "**", component: NotFound },
];

render(
  () => (
    <ThemeProvider>
      <UserDetailsProvider>
        <div class="min-h-screen bg-base-300 font-sans antialiased text-base-content">
          <Router>{routes}</Router>
        </div>
      </UserDetailsProvider>
    </ThemeProvider>
  ),
  document.getElementById("root")!
);
