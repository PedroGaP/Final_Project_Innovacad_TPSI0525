import { createMemo, createSignal, For, Show } from "solid-js";
import { Icon, type IconName, type IconSize } from "../Icon";
import { useLocation, useNavigate } from "@solidjs/router";

export interface NavProps {
  icon: IconName;
  size: IconSize;
  path: string;
  collapsed?: boolean;
  title: string;
  children?: Omit<NavProps, "collapsed">[];
  role?: string;
}

export const NavbarLink = (props: NavProps) => {
  const navigate = useNavigate();
  const location = useLocation();
  const [isOpen, setIsOpen] = createSignal(
    props.children?.some((child: any) =>
      location.pathname.includes(child.path),
    ) ?? false,
  );

  const isActive = createMemo(() => {
    const current = location.pathname.replace("/dashboard/", "");
    if (
      current === props.path ||
      (props.path === "" && current === "/dashboard")
    )
      return true;
    return props.children?.some((child: any) =>
      location.pathname.includes(child.path),
    );
  });

  const handleClick = () => {
    if (props.children && props.children.length > 0) {
      setIsOpen(!isOpen());
    } else {
      navigate(`/dashboard/${props.path}`);
    }
  };

  return (
    <li class="block w-full py-1">
      <div
        class={props.collapsed ? "tooltip tooltip-right w-full" : "w-full"}
        data-tip={props.title}
      >
        <button
          type="button"
          class="flex items-center transition-all duration-300 w-full py-3 rounded-lg hover:bg-base-200"
          classList={{
            "bg-primary/10 text-primary": isActive() && !props.children,
            "justify-start gap-4 px-4": !props.collapsed,
            "justify-center px-0": props.collapsed,
          }}
          onclick={handleClick}
        >
          <div class="shrink-0">
            <Icon
              name={props.icon}
              size={props.size}
              class={isActive() ? "text-primary" : "text-base-content/70"}
            />
          </div>

          <Show when={!props.collapsed}>
            <span class="font-medium flex-1 text-left whitespace-nowrap overflow-hidden">
              {props.title}
            </span>

            <Show when={props.children && props.children.length > 0}>
              <Icon
                name="ChevronDown"
                size={16}
                class="transition-transform duration-300"
                style={{
                  transform: isOpen() ? "rotate(180deg)" : "rotate(0deg)",
                }}
              />
            </Show>
          </Show>
        </button>
      </div>

      {/* Submenu with height transition */}
      <Show
        when={
          props.children &&
          props.children.length > 0 &&
          !props.collapsed &&
          isOpen()
        }
      >
        <ul class="mt-1 ml-6 border-l-2 border-base-300 flex flex-col gap-1 overflow-visible">
          <For each={props.children}>
            {(child) => (
              <li>
                <button
                  class="text-sm py-2 px-4 w-full text-left rounded-md transition-colors hover:bg-base-200"
                  classList={{
                    "text-primary font-bold": location.pathname.includes(
                      child.path,
                    ),
                    "text-base-content/60": !location.pathname.includes(
                      child.path,
                    ),
                  }}
                  onclick={() => navigate(`/dashboard/${child.path}`)}
                >
                  {child.title}
                </button>
              </li>
            )}
          </For>
        </ul>
      </Show>
    </li>
  );
};
