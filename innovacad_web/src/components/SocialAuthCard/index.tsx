import { Check } from "lucide-solid";
import { Show } from "solid-js";

interface Props {
  logo: string;
  logo_alt: string;
  title: string;
  is_linked: boolean;
}

export default function SocialAuthCard(props: Props) {
  return (
    <>
      <div class="flex items-center justify-between p-4 rounded-lg border border-base-300 bg-base-200 hover:bg-base-200/80 transition-colors">
        <div class="flex items-center gap-4">
          <div class="w-10 h-10 bg-white rounded-lg p-2 flex items-center justify-center shadow-sm">
            <img
              src={props.logo}
              alt={props.logo_alt}
              class="w-full h-full object-contain"
            />
          </div>
          <div class="flex flex-col">
            <span class="font-bold text-sm">{props.title}</span>
            <span class="text-xs opacity-60">
              Connect your {props.title} account
            </span>
          </div>
        </div>
        <Show
          when={props.is_linked}
          fallback={
            <button class="btn btn-sm btn-neutral min-w-25">Connect</button>
          }
        >
          <div class="rounded-box bg-accent p-1.5 ">
            <Check color="white" />
          </div>
        </Show>
      </div>
    </>
  );
}
