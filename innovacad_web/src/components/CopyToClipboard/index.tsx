import { createSignal } from "solid-js";

export default function CopyToClipboard(props: any) {
  const [tooltipText, setTooltipText] =
    createSignal<string>("Copy to clipboard");

  const copy = () => {
    setTooltipText("Copied!");
    setTimeout(() => {
      setTooltipText("Copy to clipboard");
    }, 1000);

    console.log(props.val);
    navigator.clipboard.writeText(props.val);
  };

  return (
    <div
      class="cursor-pointer tooltip tooltip-bottom"
      data-tip={tooltipText()}
      onclick={copy}
      classList={{
        "tooltip-success tooltip-open": tooltipText() === "Copied!",
      }}
    >
      {props.children}
    </div>
  );
}
