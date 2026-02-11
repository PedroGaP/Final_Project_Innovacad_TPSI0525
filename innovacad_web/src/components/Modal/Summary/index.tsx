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
        s.trainee_id === traineeId ? { ...s, isAbsent: !s.is_absent } : s,
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
      <div class="modal-box w-11/12 max-w-5xl h-[90vh] flex flex-col p-0 bg-base-100">
        {/* Header */}
        <div class="flex items-center justify-between p-4 border-b border-base-300">
          <div class="flex items-center gap-2">
            <Icon name="BookOpen" class="text-primary" />
            <h3 class="font-bold text-lg">{props.title}</h3>
          </div>
          <button
            onClick={props.onClose}
            class="btn btn-sm btn-circle btn-ghost"
          >
            <Icon name="X" size={20} />
          </button>
        </div>

        {/* Body */}
        <div class="flex-1 overflow-y-auto p-6">
          <Show
            when={!loading()}
            fallback={
              <div class="flex justify-center p-10">
                <span class="loading loading-spinner loading-lg" />
              </div>
            }
          >
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full">
              <div class="lg:col-span-1 flex flex-col gap-2 h-full">
                <label class="label font-bold text-base">
                  Summary Contents
                </label>
                <textarea
                  class="textarea textarea-bordered w-full h-full min-h-50 text-base leading-relaxed resize-none focus:border-primary"
                  placeholder="Describe what was taught in this class..."
                  value={contents()}
                  onInput={(e) => setContents(e.currentTarget.value)}
                ></textarea>
              </div>

              <div class="lg:col-span-2 flex flex-col gap-2 h-full">
                <div class="flex justify-between items-center">
                  <label class="label font-bold text-base">Attendance</label>
                  <span class="text-xs text-base-content/60">
                    Check the box if the student was{" "}
                    <span class="text-error font-bold">ABSENT</span>
                  </span>
                </div>

                <div class="bg-base-200/50 rounded-xl p-4 border border-base-300 h-full overflow-y-auto">
                  <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-5 gap-4">
                    <For each={students()}>
                      {(student) => (
                        <div
                          class={`
                            card bg-base-100 shadow-sm border transition-all cursor-pointer hover:shadow-md select-none
                            ${student.is_absent ? "border-error ring-1 ring-error bg-error/5" : "border-base-300"}
                          `}
                          onClick={() => toggleAttendance(student.trainee_id)}
                        >
                          <div class="card-body p-3 items-center text-center gap-3">
                            <div class="avatar relative">
                              <div
                                class={`w-16 h-16 rounded-full ring-2 ring-offset-2 ${student.is_absent ? "ring-error" : "ring-base-300"}`}
                              >
                                <img
                                  src={
                                    student.image
                                      ? `${API_ENDPOINTS.BASE}/resource/public/${student.image}`
                                      : `https://ui-avatars.com/api/?name=${student.name}&background=random`
                                  }
                                  alt={student.name}
                                  onError={(e) =>
                                    (e.currentTarget.src = `https://ui-avatars.com/api/?name=${student.name}`)
                                  }
                                />
                              </div>
                              <Show when={student.is_absent}>
                                <div class="absolute -top-1 -right-1 bg-error text-white rounded-full p-1">
                                  <Icon name="X" size={12} />
                                </div>
                              </Show>
                            </div>

                            <div class="flex flex-col gap-1 w-full overflow-hidden">
                              <span
                                class="text-sm font-bold truncate w-full"
                                title={student.name}
                              >
                                {student.name}
                              </span>
                              <span
                                class={`text-[10px] uppercase tracking-wider font-bold ${student.is_absent ? "text-error" : "text-success"}`}
                              >
                                {student.is_absent ? "Absent" : "Present"}
                              </span>
                            </div>

                            <input
                              type="checkbox"
                              class="checkbox checkbox-error checkbox-sm mt-1"
                              checked={student.is_absent}
                              style={{ "pointer-events": "none" }}
                            />
                          </div>
                        </div>
                      )}
                    </For>
                  </div>

                  <Show when={students().length === 0}>
                    <div class="flex flex-col items-center justify-center h-48 opacity-50">
                      <Icon name="Users" size={48} />
                      <span>No students enrolled found.</span>
                    </div>
                  </Show>
                </div>
              </div>
            </div>
          </Show>
        </div>

        {/* Footer */}
        <div class="modal-action p-4 bg-base-100 border-t border-base-300 m-0 flex justify-between items-center">
          <span class="text-xs opacity-50">
            Auto-save is disabled. Please save manually.
          </span>
          <div class="flex gap-2">
            <button class="btn btn-ghost" onClick={props.onClose}>
              Cancel
            </button>
            <button
              class="btn btn-primary min-w-30"
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
                <span class="loading loading-spinner"></span> Saving...
              </Show>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SummaryModal;
