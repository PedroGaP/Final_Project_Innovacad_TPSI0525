import { createSignal, Show } from "solid-js";
import { Portal } from "solid-js/web";

interface CopyToClipboardProps {
  val: string;
  children: any;
}

export default function CopyToClipboard(props: CopyToClipboardProps) {
  const [isCopied, setIsCopied] = createSignal(false);
  const [pos, setPos] = createSignal<{ x: number; y: number } | null>(null);
  let ref: HTMLDivElement | undefined;

  const copy = (e: MouseEvent) => {
    e.stopPropagation();
    navigator.clipboard.writeText(props.val);

    setIsCopied(true);

    if (ref) updatePos();

    setTimeout(() => {
      setIsCopied(false);
    }, 1500);
  };

  const updatePos = () => {
    if (!ref) return;
    const rect = ref.getBoundingClientRect();
    setPos({
      x: rect.left + rect.width / 2, // Center horizontally
      y: rect.top - 8, // Position slightly above the element
    });
  };

  const show = () => updatePos();
  const hide = () => setPos(null);

  return (
    <>
      <div
        ref={ref}
        class="cursor-pointer inline-block"
        onClick={copy}
        onMouseEnter={show}
        onMouseLeave={hide}
      >
        {props.children}
      </div>

      {/* Portal Tooltip */}
      <Show when={pos()}>
        <Portal>
          <div
            class="fixed z-9999 px-3 py-1.5 text-xs font-semibold rounded shadow-md pointer-events-none transform -translate-x-1/2 -translate-y-full animate-in fade-in zoom-in-95 duration-100"
            style={{
              top: `${pos()?.y}px`,
              left: `${pos()?.x}px`,
            }}
            classList={{
              // Gray for normal, Green (Success) for copied
              "bg-neutral text-neutral-content": !isCopied(),
              "bg-success text-success-content": isCopied(),
            }}
          >
            {isCopied() ? "Copied!" : "Copy to clipboard"}

            {/* Tiny triangle arrow pointing down */}
            <div
              class="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent"
              classList={{
                "border-t-neutral": !isCopied(),
                "border-t-success": isCopied(),
              }}
            ></div>
          </div>
        </Portal>
      </Show>
    </>
  );
}
