import CopyToClipboard from "@/components/CopyToClipboard";
import { Icon } from "@/components/Icon";
import { API_ENDPOINTS, useApi } from "@/hooks/useApi";
import type { StudentAttendance, SummaryGridResponse } from "@/types/summary";
import { createEffect, createSignal, For, Show } from "solid-js";
import toast from "solid-toast";

interface SummaryModalProps {
  isOpen: boolean;
  onClose: () => void;
  scheduleId: string;
  title: string;
  moduleName?: string;
  roomName?: string;
  dateStr?: string;
  timeStr?: string;
  className?: string;
  totalDuration?: number;
  currentDuration?: number;
}

const SummaryModal = (props: SummaryModalProps) => {
  const { fetchSummaryGrid, saveSummary } = useApi();
  const [loading, setLoading] = createSignal(false);
  const [saving, setSaving] = createSignal(false);

  const [contents, setContents] = createSignal("");
  const [students, setStudents] = createSignal<StudentAttendance[]>([]);

  createEffect(() => {
    if (props.isOpen && props.scheduleId) {
      loadData();
    }
  });

  const loadData = async () => {
    setLoading(true);
    try {
      const data: SummaryGridResponse = await fetchSummaryGrid(
        props.scheduleId,
      );
      setContents(data.contents || "");
      setStudents(data.students || []);
    } catch (e) {
      toast.error("Failed to load summary data");
      props.onClose();
    } finally {
      setLoading(false);
    }
  };

  const toggleAttendance = (traineeId: string) => {
    setStudents((prev) =>
      prev.map((s) =>
        s.trainee_id === traineeId ? { ...s, is_absent: !s.is_absent } : s,
      ),
    );
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await saveSummary({
        schedule_id: props.scheduleId,
        contents: contents(),
        attendances: students().map((s) => ({
          trainee_id: s.trainee_id,
          is_absent: s.is_absent,
        })),
      });
      toast.success("Summary saved successfully!");
      props.onClose();
    } catch (e: any) {
      toast.error(e.message || "Failed to save summary");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div class={`modal ${props.isOpen ? "modal-open" : ""}`}>
      <div class="modal-box w-11/12 max-w-6xl h-[95vh] flex flex-col p-0 bg-base-100 shadow-2xl">
        {/* Header */}
        <div class="flex items-center justify-between p-4 border-b border-base-300 bg-base-200/50">
          <div class="flex items-center gap-3">
            <div class="p-2 bg-primary/10 rounded-lg text-primary">
              <Icon name="BookOpen" size={24} />
            </div>
            <div>
              <h3 class="font-bold text-lg leading-tight">Class Summary</h3>
              <p class="text-xs opacity-60 font-mono">
                <span class="text-primary text-sm font-bold">
                  {props.className}
                </span>{" "}
                <CopyToClipboard val={props.scheduleId}>
                  ({props.scheduleId})
                </CopyToClipboard>
              </p>
            </div>
          </div>
          <button
            onClick={props.onClose}
            class="btn btn-sm btn-circle btn-ghost hover:bg-base-300"
          >
            <Icon name="X" size={20} />
          </button>
        </div>

        {/* Body */}
        <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-6">
          <div class="grid grid-cols-1 md:grid-cols-12 gap-4 p-4 bg-base-200 rounded-xl border border-base-300">
            <div class="form-control md:col-span-5">
              <label class="label">
                <span class="label-text text-xs uppercase font-bold opacity-60">
                  Module
                </span>
              </label>
              <input
                type="text"
                value={props.moduleName || "N/A"}
                disabled
                class="input input-sm input-bordered font-bold text-base-content p-0 w-full"
              />
            </div>

            <div class="form-control md:col-span-2">
              <label class="label">
                <span class="label-text text-xs uppercase font-bold opacity-60">
                  Room
                </span>
              </label>
              <input
                type="text"
                value={
                  props.roomName === null ||
                  props.roomName === "" ||
                  props.roomName === "N/A"
                    ? "Online"
                    : props.roomName || "Online"
                }
                disabled
                class="input input-sm input-bordered font-bold text-base-content p-0 w-full"
              />
            </div>

            <div class="form-control md:col-span-3">
              <label class="label">
                <span class="label-text text-xs uppercase font-bold opacity-60">
                  Date
                </span>
              </label>
              <input
                type="text"
                value={props.dateStr || "N/A"}
                disabled
                class="input input-sm input-bordered font-bold text-base-content p-0 w-full"
              />
            </div>

            <div class="form-control md:col-span-2">
              <label class="label">
                <span class="label-text text-xs uppercase font-bold opacity-60">
                  Time
                </span>
              </label>
              <input
                type="text"
                value={props.timeStr || "N/A"}
                disabled
                class="input input-sm input-bordered font-bold text-base-content p-0 w-full"
              />
            </div>
          </div>

          <Show
            when={!loading()}
            fallback={
              <div class="flex flex-col items-center justify-center h-64 gap-4">
                <span class="loading loading-spinner loading-lg text-primary" />
                <span class="text-sm opacity-50">Loading class data...</span>
              </div>
            }
          >
            <div class="flex flex-col lg:flex-row gap-6 h-full min-h-0">
              <div class="lg:w-1/3 flex flex-col gap-2 h-full min-h-[300px]">
                <label class="label font-bold text-base flex items-center gap-2">
                  <Icon name="FileText" size={16} /> Summary Contents
                </label>
                <textarea
                  class="textarea textarea-bordered w-full h-full text-base leading-relaxed resize-none focus:border-primary shadow-sm"
                  placeholder="Describe what was taught in this class..."
                  value={contents()}
                  onInput={(e) => setContents(e.currentTarget.value)}
                ></textarea>
              </div>

              <div class="lg:w-2/3 flex flex-col gap-2 h-full min-h-[300px]">
                <div class="flex justify-between items-center">
                  <label class="label font-bold text-base flex items-center gap-2">
                    <Icon name="Users" size={16} /> Attendance Log
                  </label>
                  <div class="badge badge-outline gap-2 p-3">
                    <span class="w-2 h-2 rounded-full bg-error"></span>
                    <span class="text-xs">
                      Selected ={" "}
                      <span class="font-bold text-error">ABSENT</span>
                    </span>
                  </div>
                </div>

                <div class="bg-base-100 rounded-xl border border-base-300 h-full overflow-y-auto shadow-inner p-4">
                  <div class="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-4">
                    <For each={students()}>
                      {(student) => (
                        <div
                          class={`
                            card shadow-sm border transition-all cursor-pointer hover:shadow-md select-none group
                            ${student.is_absent ? "bg-error/5 border-error" : "bg-base-100 border-base-200 hover:border-primary/50"}
                          `}
                          onClick={() => toggleAttendance(student.trainee_id)}
                        >
                          <div class="card-body p-3 items-center text-center gap-3">
                            <div class="avatar relative">
                              <div
                                class={`w-14 h-14 rounded-full ring-2 ring-offset-2 transition-all ${student.is_absent ? "ring-error" : "ring-base-200 group-hover:ring-primary/50"}`}
                              >
                                <img
                                  src={
                                    student.image
                                      ? `${API_ENDPOINTS.BASE}/resource/public/${student.image}`
                                      : `https://ui-avatars.com/api/?name=${student.name}&background=random`
                                  }
                                  alt={student.name}
                                  class="rounded-full object-cover"
                                  onError={(e) =>
                                    (e.currentTarget.src = `https://ui-avatars.com/api/?name=${student.name}`)
                                  }
                                />
                              </div>
                              <Show when={student.is_absent}>
                                <div class="absolute -top-1 -right-1 bg-error text-white rounded-full p-1 shadow-sm">
                                  <Icon name="X" size={10} />
                                </div>
                              </Show>
                            </div>

                            <div class="flex flex-col w-full overflow-hidden">
                              <span
                                class="text-sm font-bold truncate w-full"
                                title={student.name}
                              >
                                {student.name}
                              </span>
                              <span
                                class={`text-[10px] uppercase tracking-wider font-bold mt-1 ${student.is_absent ? "text-error" : "text-success"}`}
                              >
                                {student.is_absent ? "Absent" : "Present"}
                              </span>
                            </div>
                          </div>
                        </div>
                      )}
                    </For>
                  </div>

                  <Show when={students().length === 0}>
                    <div class="flex flex-col items-center justify-center h-full opacity-40 gap-2">
                      <Icon name="Users" size={48} />
                      <span>No students enrolled in this class.</span>
                    </div>
                  </Show>
                </div>
              </div>
            </div>
          </Show>
        </div>

        {/* Footer */}
        <div class="modal-action p-4 bg-base-100 border-t border-base-300 m-0 flex justify-between items-center">
          <span class="text-xs opacity-50 flex items-center gap-2">
            <Icon name="Info" size={14} /> Changes are not saved automatically.
          </span>
          <div class="flex gap-2">
            <button class="btn btn-ghost" onClick={props.onClose}>
              Cancel
            </button>
            <button
              class="btn btn-primary min-w-[140px]"
              onClick={handleSave}
              disabled={loading() || saving()}
            >
              <Show
                when={saving()}
                fallback={
                  <>
                    <Icon name="Save" /> Save Summary
                  </>
                }
              >
                <span class="loading loading-spinner loading-xs"></span>{" "}
                Saving...
              </Show>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SummaryModal;
