import { BsMoonStarsFill, BsSunFill } from "solid-icons/bs";
import { FiMenu } from "solid-icons/fi";
import { useTheme } from "@/providers/ThemeProvider";
export default function Header() {
  const { theme, toggleTheme } = useTheme();

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
              <li>
                <a href="hom.html">Homepage</a>
              </li>
              <li>
                <a href="port.html">Portfolio</a>
              </li>
              <li>
                <a href="about.html">About</a>
              </li>
            </ul>
          </div>
          <a
            href="server.html"
            class="btn btn-ghost text-xl font-black tracking-tight text-primary"
          >
            TRAINING<span class="text-base-content">SERVER</span>
          </a>
        </div>

        <div class="navbar-center hidden lg:flex">
          <ul class="menu menu-horizontal px-1 font-medium gap-1">
            <li>
              <a href="sol.html" class="rounded-lg">
                Solutions
              </a>
            </li>
            <li>
              <details>
                <summary class="rounded-lg">Resources</summary>
                <ul class="p-2 bg-base-100 rounded-lg shadow-lg border border-base-200 min-w-37.5">
                  <li>
                    <a href="doc.html">Documentation</a>
                  </li>
                  <li>
                    <a href="comm.html">Community herf="#"</a>
                  </li>
                </ul>
              </details>
            </li>
            <li>
              <a href="princing.html" class=" rounded-lg">
                Pricing
              </a>
            </li>
          </ul>
        </div>

        <div class="navbar-end gap-3">
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
