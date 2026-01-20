import AccountSettingsPage from "./Account";
import { Menu } from "lucide-solid";

const SettingsPage = () => {
  return (
    <div class="drawer lg:drawer-open font-sans text-base-content h-full">
      <input id="my-drawer-3" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col h-full overflow-hidden bg-base-200">
        {/* Navbar Mobile */}
        <div class="w-full navbar bg-base-100 lg:hidden border-b border-base-300">
          <div class="flex-none">
            <label for="my-drawer-3" class="btn btn-square btn-ghost">
              <Menu />
            </label>
          </div>
          <div class="flex-1 px-2 mx-2 font-bold">Settings</div>
        </div>

        {/* Settings Menu */}
        <div class="flex flex-1 overflow-hidden">
          {/* Sidebar Menu Settings */}
          <div class="w-64 border-r border-base-300 hidden md:flex flex-col pt-6 pb-4 overflow-y-auto bg-base-100">
            <div class="px-6 mb-6 flex justify-between items-center">
              <h2 class="text-xl font-bold">Settings</h2>
            </div>
            <ul class="menu w-full p-0 [&_li>*]:rounded-none [&_li>*]:px-6 [&_li>*]:py-3 font-medium">
              <li class="menu-title px-6 opacity-60 font-medium mt-2">
                Apps Settings
              </li>
              <li>
                <a class="text-primary border-r-4 border-primary bg-primary/10 hover:bg-primary/20">
                  Account
                </a>
              </li>
            </ul>
          </div>

          <main class="flex-1 overflow-y-auto bg-base-100 flex flex-col [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
            <AccountSettingsPage />
          </main>
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
