/* @refresh reload */

import { type RouteDefinition, Router } from "@solidjs/router";
import { render } from "solid-js/web";
import "@/index.css";
import NotFound from "@/pages/NotFound";
import SignIn from "@/pages/SignIn";
import { ThemeProvider } from "@/providers/ThemeProvider";
import DashboardLayout from "./pages/Dashboard";
import DashboardHome from "./pages/Dashboard/Home";
import UsersPage from "./pages/Dashboard/User";
import ClassesPage from "./pages/Dashboard/Class";
import PublicLayout from "./components/PublicLayout";

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
        path: "/users",
        component: UsersPage,
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
      <div class="min-h-screen bg-base-300 font-sans antialiased text-base-content">
        <Router>{routes}</Router>
      </div>
    </ThemeProvider>
  ),
  document.getElementById("root")!
);
