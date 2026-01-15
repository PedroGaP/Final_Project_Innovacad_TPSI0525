import { NavbarLink, type NavProps } from "@/components/NavbarLink";
import { Icon } from "@/components/Icon";
import { createMemo, createSignal, For, Show } from "solid-js";
import { useTheme } from "@/providers/ThemeProvider";
import { useLocation } from "@solidjs/router";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import capitalize from "@/utils/capitalize";
import toast from "solid-toast";

const DashboardLayout = (props: any) => {
  const { user, logout } = useUserDetails();
  const { theme, toggleTheme } = useTheme();
  const [isCollapsed, setIsCollapsed] = createSignal(false);
  const location = useLocation();

  const currentPathArray = createMemo((): string[] => {
    const path = location.pathname.replace("/dashboard/", "");
    if (!path || path === "/dashboard") return [];

    return path.split("/").filter(Boolean);
  });

  const NavItems: NavProps[] = [
    {
      icon: "LayoutDashboard",
      size: 22,
      title: "Overview",
      path: "",
    },
    {
      icon: "Users",
      size: 22,
      path: "user",
      title: "Users",
      children: [
        {
          icon: "BriefcaseBusiness",
          size: 16,
          path: "user/trainers",
          title: "Trainers",
        },
        {
          icon: "Backpack",
          size: 16,
          path: "user/trainees",
          title: "Trainees",
        },
      ],
    },
  ];

  toast("aaa");

  return (
    <>
      <ProtectedRoute>
        <div class="drawer lg:drawer-open">
          <input id="dashboard-drawer" type="checkbox" class="drawer-toggle" />

          <div class="drawer-content flex flex-col bg-base-200 h-screen overflow-hidden">
            {/* NAVBAR */}
            <header class="navbar bg-base-100 border-b border-base-300 h-16 min-h-16 px-4 sticky top-0 z-10 gap-2 flex-none">
              <div class="flex-none">
                <label
                  for="dashboard-drawer"
                  class="btn btn-square btn-ghost lg:hidden"
                >
                  <Icon name="Menu" size={24} />
                </label>
                <button
                  onClick={() => setIsCollapsed(!isCollapsed())}
                  class="btn btn-square btn-ghost hidden lg:flex transition-transform active:scale-95"
                >
                  <Icon
                    name={isCollapsed() ? "PanelLeftClose" : "PanelLeftOpen"}
                    size={22}
                  />
                </button>
              </div>

              <div class="flex-1 px-2">
                <div class="text-sm breadcrumbs opacity-60">
                  <ul>
                    <li>Dashboard</li>
                    <For each={currentPathArray()}>
                      {(segment) => (
                        <li class="font-bold opacity-100 text-base-content uppercase">
                          {segment}
                        </li>
                      )}
                    </For>
                  </ul>
                </div>
              </div>

              <div class="navbar-end gap-3">
                <label class="btn btn-ghost btn-circle swap swap-rotate">
                  <input
                    type="checkbox"
                    onChange={() => toggleTheme()}
                    checked={theme() === "dark"}
                  />
                  <div class="swap-on">
                    <Icon name="Sun" size={20} />
                  </div>
                  <div class="swap-off">
                    <Icon name="Moon" size={20} />
                  </div>
                </label>
              </div>
              <div class="flex-none flex items-center gap-2">
                <button class="btn btn-ghost btn-circle">
                  <div class="indicator">
                    <Icon name="Bell" size={20} />
                    <span class="badge badge-xs badge-primary indicator-item">
                      +9
                    </span>
                  </div>
                </button>
                <div class="dropdown dropdown-end">
                  <label
                    tabindex="0"
                    class="btn btn-ghost flex items-center gap-2 px-2"
                  >
                    <Show when={!!user()}>
                      <div class="avatar">
                        <div class="w-9 rounded-full">
                          <Show
                            when={!!user()?.image}
                            fallback={
                              <img
                                src={
                                  "https://ui-avatars.com/api/?name=" +
                                  user()!.name
                                }
                                alt="User avatar"
                              />
                            }
                          >
                            <img src={user()!.image} alt="avatar" />
                          </Show>
                        </div>
                      </div>
                    </Show>
                    <div class="hidden md:flex flex-col items-start leading-tight">
                      <Show when={!!user()}>
                        <span class="text-sm font-semibold">
                          {user()!.name}
                        </span>
                        <span class="text-xs opacity-60">
                          {!!user()?.role
                            ? capitalize(user()!.role!)
                            : "No Role"}
                        </span>
                      </Show>
                    </div>
                    <Icon name="ChevronDown" size={16} />
                  </label>
                  <ul
                    tabindex="0"
                    class="dropdown-content z-1 menu p-2 shadow bg-base-100 rounded-box w-52 mt-3"
                  >
                    <li>
                      <a>
                        <Icon name="User" size={16} />
                        Profile
                      </a>
                    </li>
                    <li>
                      <a>
                        <Icon name="Settings" size={16} />
                        Settings
                      </a>
                    </li>
                    <li class="divider my-1"></li>
                    <li>
                      <a class="text-error" onclick={() => logout()}>
                        <Icon name={"LogOut"} size={16} />
                        Logout
                      </a>
                    </li>
                  </ul>
                </div>
              </div>
            </header>
            <main class="flex-1 overflow-hidden">
              <div class="w-full h-full">{props.children}</div>
            </main>
          </div>

          {/* SIDEBAR */}
          <div class="drawer-side z-30">
            <label for="dashboard-drawer" class="drawer-overlay"></label>
            <aside
              class="bg-base-100 border-r border-base-300 flex flex-col h-full transition-all duration-300 ease-in-out z-999"
              classList={{
                "w-64": !isCollapsed(),
                "w-20": isCollapsed(),
              }}
            >
              <div class="h-16 flex items-center px-6 border-b border-base-300 shrink-0">
                <div class="flex items-center gap-3">
                  <Icon
                    name="GraduationCap"
                    size={30}
                    class="text-primary shrink-0"
                  />
                  {!isCollapsed() && (
                    <span class="font-black text-xl uppercase tracking-tighter whitespace-nowrap">
                      INNOVACAD
                    </span>
                  )}
                </div>
              </div>
              <ul class="p-4 w-full text-base flex-1 overflow-y-auto overflow-x-visible gap-1">
                <For each={NavItems}>
                  {(item) => <NavbarLink {...item} collapsed={isCollapsed()} />}
                </For>
              </ul>
            </aside>
          </div>
        </div>
      </ProtectedRoute>
    </>
  );
};

export default DashboardLayout;
