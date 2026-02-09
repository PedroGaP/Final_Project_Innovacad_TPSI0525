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
    fetchTrainers,
    fetchRooms,
  } = useApi();

  const { user } = useUserDetails();

  const [fetchedClasses] = createResource(fetchClasses);
  const [allTrainers] = createResource(fetchTrainers);
  const [allRooms] = createResource(fetchRooms);

  const [selectedClass, setSelectedClass] = createSignal<Class | null>(null);
  const [canEdit, setCanEdit] = createSignal(false);

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

  const trainerOptions = createMemo(
    () =>
      allTrainers()?.map((t) => ({
        label: t.name || "Unknown",
        value: t.trainerId!,
      })) || [],
  );
  const roomOptions = createMemo(
    () =>
      allRooms()?.map((r) => ({
        label: r.room_name || "Unknown",
        value: String(r.room_id),
      })) || [],
  );
  const moduleOptions = createMemo(
    () =>
      selectedClass()?.modules?.map((m: any) => ({
        label: m.module_name || m.name || "Unknown",
        value:
          m.classes_modules_id || m.classesModulesId || m.courses_modules_id,
      })) || [],
  );

  const availableClasses = createMemo(() => {
    const remote = fetchedClasses() || [];
    const u = user();
    if (!u) return [];
    if (u.role === "admin") return remote;
    if (u.role === "coordinator" || (u as any).is_coordinator) {
      const ids = ((u as any).coordinated_class_ids || []).map((id: any) =>
        String(id),
      );
      return remote.filter((c) => ids.includes(String(c.class_id)));
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
      if (sel?.class_id) return { type: "class", id: sel.class_id };
      return { type: "personal", id: u.id };
    },
    async (source) =>
      source.type === "class"
        ? await fetchSchedules(source.id!)
        : await fetchUserSchedules(),
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
          start,
          end,
          backgroundColor: s.is_online || s.isOnline ? "#3b82f6" : "#10b981",
          borderColor: s.is_online || s.isOnline ? "#2563eb" : "#059669",
          extendedProps: {
            classModuleId: s.class_module_id || s.classModuleId,
            trainerId: s.trainer_id || s.trainerId,
            roomId: s.room_id || s.roomId,
            moduleName: s.module_name || s.moduleName,
            roomName: s.room_name || s.roomName,
            instructor: s.trainer_name || s.trainerName,
            isOnline: s.is_online || s.isOnline,
          },
        };
      });
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
    force: false,
  });
  const [currentScheduleId, setCurrentScheduleId] = createSignal<string | null>(
    null,
  );
  const [itemToDelete, setItemToDelete] = createSignal<Record<
    string,
    any
  > | null>(null);

  const currentSelectedModuleDef = createMemo(() => {
    const modId = formData().moduleId;
    const cls = selectedClass();
    if (!modId || !cls || !cls.modules) return null;
    const targetId = String(modId);
    return cls.modules.find((m: any) => {
      const id1 = m.classes_modules_id ? String(m.classes_modules_id) : "";
      const id2 = m.classesModulesId ? String(m.classesModulesId) : "";
      const id3 = m.courses_modules_id ? String(m.courses_modules_id) : "";
      return id1 === targetId || id2 === targetId || id3 === targetId;
    });
  });

  const handleFormChange = (newData: ScheduleFormData) => {
    if (modalMode() === "create" && newData.moduleId !== formData().moduleId) {
      const cls = selectedClass();
      let defaultTrainerId = "";

      if (cls && cls.modules) {
        const targetId = String(newData.moduleId);
        const mod = cls.modules.find((m: any) => {
          const id1 = m.classes_modules_id ? String(m.classes_modules_id) : "";
          const id2 = m.classesModulesId ? String(m.classesModulesId) : "";
          const id3 = m.courses_modules_id ? String(m.courses_modules_id) : "";
          return id1 === targetId || id2 === targetId || id3 === targetId;
        });
        defaultTrainerId = mod?.trainer_id || mod?.trainer_id || "";
      }

      console.log("Module Changed -> Auto-setting trainer:", defaultTrainerId);

      setFormData({
        ...newData,
        trainerId: defaultTrainerId,
        force: false,
      });
    } else {
      const cls = selectedClass();
      let defaultTrainerId = "";

      if (cls && cls.modules) {
        const targetId = String(newData.moduleId);
        const mod = cls.modules.find((m: any) => {
          const id1 = m.classes_modules_id ? String(m.classes_modules_id) : "";
          const id2 = m.classesModulesId ? String(m.classesModulesId) : "";
          const id3 = m.courses_modules_id ? String(m.courses_modules_id) : "";
          return id1 === targetId || id2 === targetId || id3 === targetId;
        });
        defaultTrainerId = mod?.trainer_id || mod?.trainer_id || "";
      }

      if (newData.trainerId !== defaultTrainerId) {
        newData.force = true;
      }
      setFormData(newData);
    }
  };

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
    try {
      await updateSchedule(id, {
        trainer_id: originalEvent.trainer_id,
        room_id: originalEvent.room_id,
        is_online: originalEvent.is_online,
        start_time: start.toISOString(),
        end_time: end.toISOString(),
      });
      refetchSchedules();
    } catch (e) {
      toast.error("Update failed");
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

    let resolvedModuleId = props.classModuleId || "";
    if (!resolvedModuleId && props.moduleName && selectedClass()?.modules) {
      const foundMod: any = selectedClass()!.modules.find(
        (m: any) =>
          m.module_name === props.moduleName || m.name === props.moduleName,
      );
      if (foundMod)
        resolvedModuleId =
          foundMod.classes_modules_id ||
          foundMod.classesModulesId ||
          foundMod.courses_modules_id;
    }
    let resolvedRoomId = props.roomId ? String(props.roomId) : "";
    if (
      !resolvedRoomId &&
      props.roomName &&
      props.roomName.toLowerCase() !== "online" &&
      allRooms()
    ) {
      const foundRoom = allRooms()?.find((r) => r.room_name === props.roomName);
      if (foundRoom) resolvedRoomId = String(foundRoom.room_id);
    }
    let resolvedTrainerId = props.trainerId ? String(props.trainerId) : "";
    if (!resolvedTrainerId && props.instructor && allTrainers()) {
      const foundTrainer = allTrainers()?.find(
        (t) => t.name === props.instructor,
      );
      if (foundTrainer) resolvedTrainerId = String(foundTrainer.trainerId);
    }

    setFormData({
      moduleId: String(resolvedModuleId || ""),
      trainerId: String(resolvedTrainerId || ""),
      roomId: String(resolvedRoomId || ""),
      start: formatForInput(event.start),
      end: formatForInput(event.end),
      isOnline: Boolean(props.isOnline),
      force: false,
    });
    setIsEditModalOpen(true);
  };

  const handleSave = async (data: ScheduleFormData) => {
    if (!data.moduleId || !data.trainerId) {
      toast.error("Required fields missing");
      return;
    }
    try {
      const payload = {
        trainer_id: data.trainerId,
        room_id: data.roomId ? parseInt(data.roomId) : undefined,
        is_online: data.isOnline,
        start_time: new Date(data.start).toISOString(),
        end_time: new Date(data.end).toISOString(),
      };
      if (modalMode() === "create") {
        await createSchedule({
          ...payload,
          class_module_id: data.moduleId,
          force_trainer_change: !!data.force,
        });
      } else {
        await updateSchedule(currentScheduleId()!, payload);
        toast.success("Updated!");
      }
      setIsEditModalOpen(false);
      refetchSchedules();
    } catch (e: any) {
      toast.error(e.message || "Failed");
    }
  };

  const handleConfirmDelete = async () => {
    const item = itemToDelete();
    if (item) {
      await deleteSchedule(item.id);
      toast.success("Deleted");
      refetchSchedules();
    }
  };

  const dynamicFields = createMemo<ModalFieldDefinition<ScheduleFormData>[]>(
    () => {
      const selectedMod: any = currentSelectedModuleDef();
      const defaultTrainerId =
        selectedMod?.trainer_id || selectedMod?.trainerId;
      const hasDefaultTrainer = !!defaultTrainerId;

      const isTrainerSelectDisabled = hasDefaultTrainer && !formData().force;

      const trainerPlaceholder = allTrainers.loading
        ? "Loading trainers..."
        : isTrainerSelectDisabled
          ? "Default Trainer (Check Override to change)"
          : "Select a trainer";

      return [
        {
          name: "moduleId",
          label: "Module",
          type: "select",
          required: true,
          disabled: modalMode() === "edit",
          options: moduleOptions(),
        },
        {
          name: "trainerId",
          label: "Trainer",
          type: "select",
          required: true,
          disabled: isTrainerSelectDisabled,
          placeholder: trainerPlaceholder,
          options: trainerOptions(),
        },
        {
          name: "roomId",
          label: "Room",
          type: "select",
          hidden: formData().isOnline,
          options: roomOptions(),
        },
        { name: "isOnline", label: "Online Class?", type: "checkbox" },
        {
          name: "start",
          label: "Start",
          type: "datetime-local",
          disabled: true,
        },
        { name: "end", label: "End", type: "datetime-local", disabled: true },
        {
          name: "force",
          label: "Override Default Trainer?",
          type: "checkbox",
          hidden: modalMode() === "edit" || !hasDefaultTrainer,
        },
      ];
    },
  );

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
                setSelectedClass(
                  availableClasses().find((c) => String(c.class_id) === id) ||
                    null,
                );
              }}
            >
              <option value="">
                {user()?.role === "admin" ? "Select Class" : "My Schedule"}
              </option>
              <For each={availableClasses()}>
                {(k) => <option value={k.class_id}>{k.identifier}</option>}
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
              "badge-ghost": !canEdit(),
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

        <div class="grow relative z-0">
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
            setValue={handleFormChange}
            onSave={handleSave}
            onCancel={() => setIsEditModalOpen(false)}
            onDelete={
              modalMode() === "edit"
                ? () => Promise.resolve(handleConfirmDelete())
                : undefined
            }
            fields={dynamicFields()}
          />
        </Show>

        <ModalDelete
          value={itemToDelete}
          setValue={setItemToDelete}
          onConfirm={handleConfirmDelete}
          onCancel={() => {}}
          title="Delete Session"
          description={`Remove session?`}
        />
      </div>
    </div>
  );
};

export default Calendar;
