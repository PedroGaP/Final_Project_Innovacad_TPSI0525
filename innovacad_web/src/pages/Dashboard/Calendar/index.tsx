import { EventCalendar } from "@/components/EventCalendar";
import { Icon } from "@/components/Icon";
import ModalDelete from "@/components/Modal/Delete";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import ModalEdit from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { Class } from "@/types/class";
import {
  createEffect,
  createMemo,
  createResource,
  createSignal,
  For,
  Show,
} from "solid-js";
import toast from "solid-toast";

interface ScheduleFormData {
  moduleId: string;
  trainerId: string;
  roomId: string;
  start: string;
  end: string;
  isOnline: boolean;
  force?: boolean;
}

const Calendar = () => {
  const {
    fetchClasses,
    fetchSchedules,
    fetchUserSchedules,
    createSchedule,
    updateSchedule,
    deleteSchedule,
    fetchModules,
    fetchTrainers,
    fetchRooms,
  } = useApi();

  const { user } = useUserDetails();

  const [fetchedClasses] = createResource(fetchClasses);
  const [allModules] = createResource(fetchModules);
  const [allTrainers] = createResource(fetchTrainers);
  const [allRooms] = createResource(fetchRooms);

  const [selectedClass, setSelectedClass] = createSignal<Class | null>(null);
  const [canEdit, setCanEdit] = createSignal(false);

  createEffect(() => {
    console.log("--- DEBUG DATA LOAD ---");
    console.log("User Role:", user()?.role);
    console.log("Coordinated IDs:", (user() as any)?.coordinated_class_ids);
    console.log("Classes from API (Raw):", fetchedClasses());
  });

  const availableClasses = createMemo(() => {
    const remote = fetchedClasses() || [];
    const u = user();

    if (!u) {
      console.log("AvailableClasses: No user found.");
      return [];
    }

    if (u.role === "admin") {
      return remote;
    }

    if (u.role === "coordinator" || (u as any).is_coordinator) {
      const coordinatedIds = (u as any).coordinated_class_ids || [];
      const idsStrings = coordinatedIds.map((id: any) => String(id));

      const filtered = remote.filter((c) => {
        const isMatch = idsStrings.includes(String(c.class_id));
        console.log(
          `Checking class ${c.identifier} (${c.class_id}): Match = ${isMatch}`,
        );
        return isMatch;
      });

      console.log("Final Filtered Classes for Coordinator:", filtered);
      return filtered;
    }

    return remote.filter(
      (c) => String((u as any).class_id) === String(c.class_id),
    );
  });

  const [schedules, { refetch: refetchSchedules }] = createResource(
    () => {
      const u = user();
      const sel = selectedClass();
      if (!u) return null;

      if (sel?.class_id) {
        return { type: "class", id: sel.class_id };
      }

      return { type: "personal", id: u.id };
    },
    async (source) => {
      if (source.type === "class") return await fetchSchedules(source.id!);
      return await fetchUserSchedules();
    },
  );

  const calendarEvents = createMemo(() => {
    const rawData = schedules();
    if (!rawData || !Array.isArray(rawData)) return [];

    return rawData
      .filter((s: any) => (s.start && s.end) || (s.date_day && s.start_time))
      .map((s: any) => {
        let start = s.start;
        let end = s.end;

        if (!start && s.date_day && s.start_time) {
          const baseDate = new Date(Number(s.date_day))
            .toISOString()
            .split("T")[0];
          start = `${baseDate}T${s.start_time}`;
          end = `${baseDate}T${s.end_time}`;
        }

        return {
          id: s.schedule_id || s.scheduleId,
          title: `${s.module_name || s.moduleName} (${s.trainer_name || s.trainerName})`,
          start: start,
          end: end,
          backgroundColor: s.is_online || s.isOnline ? "#3b82f6" : "#10b981",
          borderColor: s.is_online || s.isOnline ? "#2563eb" : "#059669",
          extendedProps: {
            classModuleId: s.class_module_id || s.classModuleId,
            trainerId: s.trainer_id || s.trainerId,
            roomId: s.room_id || s.roomId,
            isOnline: s.is_online || s.isOnline,
            roomName: s.room_name || s.roomName,
            instructor: s.trainer_name || s.trainerName,
            regime: s.regime_type || s.regimeType,
          },
        };
      });
  });

  createEffect(() => {
    const u = user();
    const c = selectedClass();
    setCanEdit(false);

    if (!u) return;
    if (u.role === "admin") {
      setCanEdit(true);
      return;
    }

    if (((u as any).role === "coordinator" || (u as any).is_coordinator) && c) {
      setCanEdit(true);
    }
  });

  const [isEditModalOpen, setIsEditModalOpen] = createSignal(false);
  const [modalMode, setModalMode] = createSignal<"create" | "edit">("create");
  const [formData, setFormData] = createSignal<ScheduleFormData>({
    moduleId: "",
    trainerId: "",
    roomId: "",
    start: "",
    end: "",
    isOnline: false,
  });
  const [currentScheduleId, setCurrentScheduleId] = createSignal<string | null>(
    null,
  );
  const [itemToDelete, setItemToDelete] = createSignal<Record<
    string,
    any
  > | null>(null);

  const formatForInput = (dateInput: string | Date) => {
    const d = new Date(dateInput);
    const offset = d.getTimezoneOffset() * 60000;
    return new Date(d.getTime() - offset).toISOString().slice(0, 16);
  };

  const handleMoveRequest = async (id: string, start: Date, end: Date) => {
    if (!canEdit()) return;

    const allEvents = schedules() || [];
    const originalEvent = allEvents.find(
      (s: any) => (s.schedule_id || s.scheduleId) === id,
    );

    if (!originalEvent) return;

    const payload = {
      trainer_id: originalEvent.trainer_id,
      room_id: originalEvent.room_id,
      is_online: originalEvent.is_online,
      regime_type: Number(originalEvent.regime_type),
      start_time: start.toISOString(),
      end_time: end.toISOString(),
    };

    try {
      await updateSchedule(id, payload);
      refetchSchedules();
    } catch (e) {
      console.error("Payload rejection:", e);
      toast.error("Update failed: Check data types.");
    }
  };

  const handleCreateRequest = (start: string, end: string) => {
    if (!canEdit()) return;
    setModalMode("create");
    setCurrentScheduleId(null);
    setFormData({
      moduleId: "",
      trainerId: "",
      roomId: "",
      start: formatForInput(start),
      end: formatForInput(end),
      isOnline: false,
      force: false,
    });
    setIsEditModalOpen(true);
  };

  const handleEditRequest = (event: any) => {
    if (!canEdit()) return;
    setModalMode("edit");
    setCurrentScheduleId(event.id);
    const props = event.extendedProps;
    setFormData({
      moduleId: props.classModuleId || "",
      trainerId: props.trainerId || "",
      roomId: props.roomId ? props.roomId.toString() : "",
      start: formatForInput(event.start),
      end: formatForInput(event.end),
      isOnline: props.isOnline || false,
      force: false,
    });
    setIsEditModalOpen(true);
  };

  const handleSave = async (data: ScheduleFormData) => {
    if (!data.moduleId || !data.trainerId) {
      toast.error("Please fill all required fields");
      return;
    }
    try {
      // Inside handleSave
      if (modalMode() === "create") {
        await createSchedule({
          class_module_id: data.moduleId,
          trainer_id: data.trainerId,
          room_id: data.roomId ? parseInt(data.roomId) : undefined,
          start_time: new Date(data.start).toISOString(),
          end_time: new Date(data.end).toISOString(),
          force_trainer_change: !!data.force,
        });
      } else {
        await updateSchedule(currentScheduleId()!, {
          trainer_id: data.trainerId,
          room_id: data.roomId ? parseInt(data.roomId) : undefined,
          is_online: data.isOnline,
          start_time: new Date(data.start).toISOString(),
          end_time: new Date(data.end).toISOString(),
        });

        toast.success("Schedule updated!");
      }
      setIsEditModalOpen(false);
      refetchSchedules();
    } catch (e: any) {
      toast.error(e.message || "Operation failed");
    }
  };

  const handleConfirmDelete = async () => {
    const item = itemToDelete();
    if (!item) return;
    try {
      await deleteSchedule(item.id);
      toast.success("Deleted successfully");
      refetchSchedules();
    } catch (e: any) {
      toast.error(e.message);
    }
  };

  const formatClassName = (klass: Class) =>
    klass.course_identifier
      ? `${klass.course_identifier} ${klass.location || ""} ${klass.identifier || ""}`.trim()
      : klass.identifier || "Unknown Class";

  const getDropdownLabel = () => {
    const role = user()?.role;
    if (role === "admin" || role === "coordinator")
      return "Select Class to Manage";
    return "My Schedule (Filter by Class)";
  };

  return (
    <div class="card w-full h-[80vh] bg-base-100 shadow-xl border border-base-300">
      <div class="card-body p-4 relative flex flex-col gap-4">
        <div class="flex justify-between items-center gap-4">
          <div class="flex items-center gap-3">
            <select
              class="select select-bordered w-full max-w-md font-mono text-sm"
              value={selectedClass()?.class_id || ""}
              onChange={(e) => {
                const id = e.currentTarget.value;
                const found =
                  availableClasses().find((c) => String(c.class_id) === id) ||
                  null;
                setSelectedClass(found);
              }}
            >
              <option value="">{getDropdownLabel()}</option>
              <For each={availableClasses()}>
                {(klass) => (
                  <option value={klass.class_id}>
                    {formatClassName(klass)}
                  </option>
                )}
              </For>
            </select>
            <Show when={schedules.loading || fetchedClasses.loading}>
              <span class="loading loading-spinner loading-sm text-primary"></span>
            </Show>
          </div>

          <div
            class="badge gap-2 py-4 px-4 font-bold border transition-all"
            classList={{
              "badge-success border-success/20 text-success-content": canEdit(),
              "badge-ghost border-base-300 opacity-70": !canEdit(),
            }}
          >
            <Show
              when={canEdit()}
              fallback={
                <>
                  <Icon name="Lock" size={14} />
                  <span class="uppercase text-[10px]">Read Only</span>
                </>
              }
            >
              <Icon name="LockOpen" size={14} />
              <span class="uppercase text-[10px]">
                Editing: {selectedClass()?.identifier}
              </span>
            </Show>
          </div>
        </div>

        <div class="flex-grow relative z-0">
          <EventCalendar
            selectedClass={selectedClass()}
            events={calendarEvents()}
            isEditable={canEdit()}
            loading={schedules.loading}
            onCreateRequest={handleCreateRequest}
            onEditRequest={handleEditRequest}
            onMoveRequest={handleMoveRequest}
          />
        </div>

        <Show when={isEditModalOpen()}>
          <ModalEdit<ScheduleFormData>
            title={modalMode() === "create" ? "New Session" : "Edit Session"}
            value={formData()}
            setValue={setFormData as any}
            onSave={handleSave}
            onCancel={() => setIsEditModalOpen(false)}
            onDelete={
              modalMode() === "edit"
                ? () => Promise.resolve(handleConfirmDelete())
                : undefined
            }
            fields={[
              {
                name: "moduleId",
                label: "Module",
                type: "select",
                required: true,
                disabled: modalMode() === "edit",
                options:
                  selectedClass()?.modules?.map((m: any) => ({
                    label: m.module_name || m.name,
                    value: m.classes_modules_id,
                  })) || [],
              },
              {
                name: "trainerId",
                label: "Trainer",
                type: "select",
                required: true,
                options:
                  allTrainers()?.map((t) => ({
                    label: `${t.name}`,
                    value: t.trainerId!,
                  })) || [],
              },
              {
                name: "roomId",
                label: "Room",
                type: "select",
                options:
                  allRooms()?.map((r) => ({
                    label: r.room_name!,
                    value: r.room_id!.toString(),
                  })) || [],
              },
              { name: "isOnline", label: "Online Class?", type: "checkbox" },
              {
                name: "start",
                label: "Start",
                type: "datetime-local",
                disabled: true,
              },
              {
                name: "end",
                label: "End",
                type: "datetime-local",
                disabled: true,
              },
              {
                name: "force",
                label: "Emergency Override",
                type: "checkbox",
                hidden: modalMode() === "edit",
              },
            ]}
          />
        </Show>

        <ModalDelete
          value={itemToDelete}
          setValue={setItemToDelete}
          onConfirm={handleConfirmDelete}
          onCancel={() => {}}
          title="Delete Session"
          description={`Are you sure you want to remove this session?`}
        />
      </div>
    </div>
  );
};

export default Calendar;
