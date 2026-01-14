import { icons, type LucideProps } from "lucide-solid";
import { splitProps } from "solid-js";
import { Dynamic } from "solid-js/web";

export type IconName = Extract<keyof typeof icons, string>;

export type IconSize = string | number | undefined;

export type IconColor = string | undefined;

export interface IconProps extends LucideProps {
  name: IconName;
  size?: IconSize;
  color?: IconColor;
}

export const Icon = (props: IconProps) => {
  const [local, others] = splitProps(props, ["name", "size"]);

  return (
    <Dynamic
      component={icons[local.name]}
      size={props.size}
      color={props.color}
      {...others}
    />
  );
};
