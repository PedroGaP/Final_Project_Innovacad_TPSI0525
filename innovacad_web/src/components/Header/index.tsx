import { BsMoonStarsFill, BsSunFill } from "solid-icons/bs";
import { FiMenu } from "solid-icons/fi";
import { useTheme } from "@/providers/ThemeProvider";
import { useNavigate } from "@solidjs/router";
import { useI18n } from "@/hooks/useL18N";
import ChangeLanguage from "../ChangeLanguage";
import { For } from "solid-js";
export default function Header() {
  const { theme, toggleTheme } = useTheme();
  const { t } = useI18n();
  const navigate = useNavigate();

  const items = () => [
    {
      name: t("header.dashboard"),
      onClick: () => navigate("dashboard"),
    },
    {
      name: t("entity.courses"),
      onClick: () => navigate("courses"),
    },
    {
      name: t("entity.trainers"),
      onClick: () => navigate("trainers"),
    },
    {
      name: t("entity.trainees"),
      onClick: () => navigate("trainees"),
    },
    {
      name: t("entity.classes"),
      onClick: () => navigate("classes"),
    },
    {
      name: t("entity.schedules"),
      onClick: () => navigate("schedules"),
    },
    {
      name: t("entity.rooms"),
      onClick: () => navigate("rooms"),
    },
  ];

  return (
    <header class="sticky top-0 z-50 w-full border-b border-base-200 bg-base-100/80 backdrop-blur-lg">
      <div class="navbar mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
        <div class="navbar-start">
          <div class="dropdown">
            <label tabIndex={0} class="btn btn-ghost btn-circle lg:hidden">
              <FiMenu size={30} />
            </label>
            <ul
              tabIndex={0}
              class="menu menu-sm dropdown-content mt-3 z-1 p-2 shadow-xl bg-base-100 rounded-box w-52 border border-base-200"
            >
              <For each={items()}>
                {(item) => (
                  <li>
                    <button
                      onClick={item.onClick}
                      class="btn btn-ghost rounded-lg"
                    >
                      {item.name}
                    </button>
                  </li>
                )}
              </For>
            </ul>
          </div>
          <button
            class="btn btn-ghost text-xl font-black tracking-tight text-primary"
            onClick={() => navigate("/")}
          >
            TRAINING<span class="text-base-content">SERVER</span>
          </button>
        </div>

        <div class="navbar-center hidden lg:flex">
          <ul class="menu menu-horizontal px-1 font-medium gap-1">
            <For each={items()}>
              {(item) => (
                <li>
                  <button
                    onClick={item.onClick}
                    class="btn btn-ghost rounded-lg"
                  >
                    {item.name}
                  </button>
                </li>
              )}
            </For>
          </ul>
        </div>

        <div class="navbar-end gap-3">
          <ChangeLanguage />
          <label class="btn btn-ghost btn-circle swap swap-rotate">
            <input
              type="checkbox"
              onChange={() => toggleTheme()}
              checked={theme() === "dark"}
            />

            <div class="swap-on">
              <BsSunFill size={20} />
            </div>

            <div class="swap-off">
              <BsMoonStarsFill size={20} />
            </div>
          </label>
        </div>
      </div>
    </header>
  );
}
