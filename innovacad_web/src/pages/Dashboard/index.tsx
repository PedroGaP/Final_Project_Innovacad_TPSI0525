import { NavbarLink, type NavProps } from "@/components/NavbarLink";
import { Icon } from "@/components/Icon";
import { createMemo, createSignal, For } from "solid-js";
import { useTheme } from "@/providers/ThemeProvider";
import { useLocation } from "@solidjs/router";

const DashboardLayout = (props: any) => {
  const { theme, toggleTheme } = useTheme();
  const [isCollapsed, setIsCollapsed] = createSignal(false);
  const location = useLocation();

  const currentPath = createMemo(() => {
    return location.pathname.replace("/dashboard/", "").toUpperCase();
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
      path: "users",
      title: "Users",
    },
  ];

  return (
    <div class="drawer lg:drawer-open">
      <input id="dashboard-drawer" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col bg-base-200 min-h-screen">
        {/* NAVBAR */}
        <header class="navbar bg-base-100 border-b border-base-300 h-16 min-h-16 px-4 sticky top-0 z-10 gap-2">
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
            <div
              class="text-sm p-0 opacity-60"
              classList={{
                breadcrumbs: currentPath().length > 0,
              }}
            >
              <ul>
                <li>Dashboard</li>
                <li class="font-bold opacity-100 text-base-content">
                  {currentPath()}
                </li>
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
            {/* Notifications */}
            <button class="btn btn-ghost btn-circle">
              <div class="indicator">
                <Icon name="Bell" size={20} />
                <span class="badge badge-xs badge-primary indicator-item">
                  +9
                </span>
              </div>
            </button>

            {/* User Dropdown */}
            <div class="dropdown dropdown-end">
              <label
                tabindex="0"
                class="btn btn-ghost flex items-center gap-2 px-2"
              >
                <div class="avatar">
                  <div class="w-9 rounded-full">
                    <img
                      src="https://ui-avatars.com/api/?name=Admin"
                      alt="User avatar"
                    />
                  </div>
                </div>

                <div class="hidden md:flex flex-col items-start leading-tight">
                  <span class="text-sm font-semibold">Admin</span>
                  <span class="text-xs opacity-60">Administrator</span>
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
                  <a class="text-error">
                    <Icon name={"LogOut"} size={16} />
                    Logout
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </header>

        <main class="p-6 md:p-10 grow">
          <div class="max-w-7xl mx-auto w-full">{props.children}</div>
        </main>
      </div>

      {/* SIDEBAR */}
      <div class="drawer-side z-30">
        <label for="dashboard-drawer" class="drawer-overlay"></label>

        <aside
          class="bg-base-100 border-r border-base-300 flex flex-col h-full transition-all duration-300 ease-in-out"
          classList={{
            "w-64": !isCollapsed(),
            "w-20": isCollapsed(),
          }}
        >
          {/* Sidebar Header */}
          <div class="h-16 flex items-center px-6 border-b border-base-300 overflow-hidden">
            <div class="flex items-center gap-3 min-w-max mx-auto">
              <Icon name="GraduationCap" size={30} class="shrink-0" />
              <span
                class="font-black text-xl uppercase tracking-tighter transition-all duration-300 origin-left"
                classList={{
                  "opacity-0 scale-0 w-0": isCollapsed(),
                  "opacity-100 scale-100 w-auto": !isCollapsed(),
                }}
              >
                INNOVACAD
              </span>
            </div>
          </div>

          {/* Navigation */}
          <ul class="menu p-4 w-full gap-2 text-base overflow-x-hidden">
            <For each={NavItems}>
              {(item) => (
                <NavbarLink
                  icon={item.icon}
                  size={item.size}
                  title={item.title}
                  path={item.path}
                  collapsed={isCollapsed()}
                />
              )}
            </For>
          </ul>

          {/*
          <div class="mt-auto p-4 border-t border-base-300 overflow-hidden">
            <button
              class="btn btn-ghost w-full hover:bg-error/10 hover:text-error transition-all duration-300"
              classList={{
                "justify-center gap-0 px-0": isCollapsed(),
              }}
            >
              <Icon name="LogOut" size={20} class="text-error shrink-0" />

              <span
                class="transition-all duration-300 origin-left whitespace-nowrap"
                classList={{
                  "opacity-0 w-0 h-0 overflow-hidden": isCollapsed(),
                  "opacity-100 w-auto ml-1": !isCollapsed(),
                }}
              >
                Logout
              </span>
            </button>
          </div>*/}
        </aside>
      </div>
    </div>
  );
};

export default DashboardLayout;
