import { Show, createResource } from "solid-js";
import {
  X,
  Clock,
  User,
  MapPin,
  FileText,
  Info,
  BookCheck,
} from "lucide-solid";
import { useApi } from "@/hooks/useApi";

interface ScheduleInfoModalProps {
  isOpen: boolean;
  onClose: () => void;
  data: {
    id: string;
    title: string;
    moduleName: string;
    trainerName: string;
    trainerEmail: string;
    className: string;
    roomName: string;
    start: string;
    end: string;
    totalDuration: number;
    currentDuration: number;
  };
}

const ScheduleInfoModal = (props: ScheduleInfoModalProps) => {
  const { fetchSummaryGrid } = useApi();

  const [summary] = createResource(
    () => (props.isOpen ? props.data.id : null),
    async (id) => {
      try {
        const res = await fetchSummaryGrid(id);
        return res;
      } catch (e) {
        return null;
      }
    },
  );

  const formatTime = (dateStr: string) => {
    return new Date(dateStr).toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString();
  };

  return (
    <Show when={props.isOpen}>
      <div class="modal modal-open">
        <div class="modal-box max-w-lg border border-base-300 shadow-2xl">
          <div class="flex justify-between items-start mb-6">
            <div>
              <h3 class="font-bold text-xl text-primary">Summary</h3>
              <p class="text-sm opacity-60 font-mono">{props.data.className}</p>
            </div>
            <button
              class="btn btn-sm btn-circle btn-ghost"
              onClick={props.onClose}
            >
              <X size={20} />
            </button>
          </div>

          <div class="grid grid-cols-1 gap-4">
            <div class="flex items-center gap-3 bg-base-200/50 p-3 rounded-lg">
              <User class="text-primary" size={18} />
              <div>
                <p class="text-xs opacity-50 uppercase font-bold">Trainer</p>
                <p class="text-sm">
                  {props.data.trainerName}{" "}
                  <span class="text-sm text-accent">
                    ({props.data.trainerEmail ?? "N/A"})
                  </span>
                </p>
              </div>
            </div>

            <div class="flex items-center gap-3 bg-base-200/50 p-3 rounded-lg">
              <BookCheck class="text-primary" size={18} />
              <div>
                <p class="text-xs opacity-50 uppercase font-bold">Module</p>
                <p class="text-sm">{props.data.moduleName}</p>
              </div>
            </div>

            <div class="flex items-center gap-3 bg-base-200/50 p-3 rounded-lg">
              <MapPin class="text-primary" size={18} />
              <div>
                <p class="text-xs opacity-50 uppercase font-bold">Location</p>
                <p class="text-sm">{props.data.roomName}</p>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="flex items-center gap-3 bg-base-200/50 p-3 rounded-lg">
                <Clock class="text-primary" size={18} />
                <div>
                  <p class="text-xs opacity-50 uppercase font-bold">Schedule</p>
                  <p class="text-sm">
                    {formatTime(props.data.start)} -{" "}
                    {formatTime(props.data.end)}
                  </p>
                </div>
              </div>
              <div class="flex items-center gap-3 bg-base-200/50 p-3 rounded-lg">
                <Info class="text-primary" size={18} />
                <div>
                  <p class="text-xs opacity-50 uppercase font-bold">Date</p>
                  <p class="text-sm">{formatDate(props.data.start)}</p>
                </div>
              </div>
            </div>

            <div class="p-3 border border-base-300 rounded-lg">
              <div class="flex justify-between text-xs mb-2">
                <span class="font-bold uppercase opacity-50">
                  Module Progress
                </span>
                <span>
                  {props.data.currentDuration}h / {props.data.totalDuration}h
                </span>
              </div>
              <progress
                class="progress progress-primary w-full"
                value={props.data.currentDuration}
                max={props.data.totalDuration}
              ></progress>
            </div>

            <div class="collapse collapse-arrow bg-base-200">
              <input type="checkbox" />
              <div class="collapse-title text-sm font-bold flex items-center gap-2">
                <FileText size={16} /> Session Summary
              </div>
              <div class="collapse-content">
                <Show
                  when={summary()}
                  fallback={
                    <p class="text-xs opacity-50 italic">
                      No summary has been registered for this session yet.
                    </p>
                  }
                >
                  <div class="text-sm whitespace-pre-wrap py-2 border-t border-base-300">
                    {summary()?.contents || "Contents not specified."}
                  </div>
                </Show>
              </div>
            </div>
          </div>

          <div class="modal-action">
            <button class="btn btn-primary btn-block" onClick={props.onClose}>
              Close
            </button>
          </div>
        </div>
      </div>
    </Show>
  );
};

export default ScheduleInfoModal;
