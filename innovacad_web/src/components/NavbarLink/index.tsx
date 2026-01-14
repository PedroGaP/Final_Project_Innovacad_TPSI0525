import { createMemo } from "solid-js";
import { Icon, type IconName, type IconSize } from "../Icon";
import { useLocation, useNavigate } from "@solidjs/router";

export interface NavProps {
  icon: IconName;
  size: IconSize;
  path: string;
  collapsed?: boolean;
  title: string;
}

export const NavbarLink = (props: NavProps) => {
  const navigate = useNavigate();
  const location = useLocation();

  const isActive = createMemo(() => {
    const current = location.pathname.replace("/dashboard/", "");
    return current === props.path;
  });

  return (
    <li>
      <button
        class="tooltip tooltip-right flex items-center transition-all duration-300"
        data-tip={props.collapsed ? props.title : ""}
        classList={{
          active: isActive(),
          "justify-start gap-4 px-4": !props.collapsed,
          "justify-center px-0": props.collapsed,
        }}
        onclick={() => navigate(`/dashboard/${props.path}`)}
      >
        <div class="shrink-0">
          <Icon
            name={props.icon}
            size={props.size}
            color={isActive() ? "#0091ff" : undefined}
          />
        </div>

        <span
          class="font-medium transition-all duration-300 origin-left whitespace-nowrap"
          classList={{
            "opacity-0 w-0 overflow-hidden invisible": props.collapsed,
            "opacity-100 w-auto": !props.collapsed,
          }}
        >
          {props.title}
        </span>
      </button>
    </li>
  );
};
