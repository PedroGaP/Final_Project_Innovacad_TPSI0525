import { EventCalendar } from "@/components/EventCalendar";
import { Icon } from "@/components/Icon";
import ModalDelete from "@/components/Modal/Delete";
import ModalEdit from "@/components/Modal/Edit";
import ScheduleInfoModal from "@/components/Modal/ScheduleInfo";
import SummaryModal from "@/components/Modal/Summary";
import { useApi } from "@/hooks/useApi";
import useI18n from "@/hooks/useL18N";
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

interface SummaryTargetData {
  id: string;
  title: string;
  moduleName?: string;
  roomName?: string;
  dateStr?: string;
  timeStr?: string;
  className?: string;
  totalDuration?: number;
  currentDuration?: number;
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
  const { t } = useI18n();

  const [fetchedClasses] = createResource(fetchClasses);
  const [allTrainers] = createResource(fetchTrainers);
  const [allRooms] = createResource(fetchRooms);

  const [selectedClass, setSelectedClass] = createSignal<Class | null>(null);
  const [canEdit, setCanEdit] = createSignal(false);

  const [isEditModalOpen, setIsEditModalOpen] = createSignal(false);
  const [isSummaryModalOpen, setIsSummaryModalOpen] = createSignal(false);
  const [summaryTarget, setSummaryTarget] =
    createSignal<SummaryTargetData | null>(null);
  const [isInfoModalOpen, setIsInfoModalOpen] = createSignal(false);
  const [infoTarget, setInfoTarget] = createSignal<any>(null);

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
      const coordinatedIds = Object.keys(
        (u as any).coordinated_class_ids || {},
      );
      if (coordinatedIds.includes(String(c.class_id))) {
        setCanEdit(true);
      }
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
      const ids = Object.keys((u as any).coordinated_class_ids || {});
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
    async (source) => {
      if (source.type === "class") {
        return await fetchSchedules(source.id!);
      } else {
        return await fetchUserSchedules();
      }
    },
  );

  const displaySchedules = createMemo<any[]>((prev) => {
    const current = schedules();
    if (schedules.loading && prev) return prev;
    return current || [];
  }, []);

  const calendarEvents = createMemo(() => {
    const rawData = displaySchedules();
    if (!rawData || !Array.isArray(rawData)) return [];

    return rawData
      .filter((s: any) => (s.start && s.end) || (s.start_time && s.end_time))
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

        const trainerId = s.trainer_id || s.trainerId || (s as any).trainerId;

        console.log("SCHEDULE: " + JSON.stringify(s));

        return {
          id: s.schedule_id || s.scheduleId,
          title: `${s.module_name || s.moduleName} (${s.trainer_name || s.trainerName})`,
          start,
          end,
          backgroundColor: s.is_online || s.isOnline ? "#3b82f6" : "#10b981",
          borderColor: s.is_online || s.isOnline ? "#2563eb" : "#059669",
          extendedProps: {
            classModuleId: s.class_module_id || s.classModuleId,
            trainerId: trainerId,
            trainerEmail: s.trainer_email,
            roomId: s.room_id || s.roomId,
            moduleName: s.module_name || s.moduleName,
            roomName: s.room_name || s.roomName,
            instructor: s.trainer_name || s.trainerName,
            isOnline: s.is_online || s.isOnline,
            className: s.class_name,
            totalDuration: s.total_duration,
            currentDuration: s.current_duration,
          },
        };
      });
  });

  const formatForInput = (dateInput: string | Date) => {
    const d = new Date(dateInput);
    const offset = d.getTimezoneOffset() * 60000;
    return new Date(d.getTime() - offset).toISOString().slice(0, 16);
  };

  const handleEditRequest = (event: any) => {
    const u = user();
    const isClassContext = selectedClass() !== null;
    const props = event.extendedProps;

    const startVal = event.startStr || event.start;
    const endVal = event.endStr || event.end;
    const eventStart = new Date(startVal);
    const eventEnd = endVal
      ? new Date(endVal)
      : new Date(eventStart.getTime() + 60 * 60 * 1000);
    const now = new Date();
    const eventTrainerId = String(event.extendedProps?.trainerId || "");

    const hasStarted = now.getTime() >= eventStart.getTime();

    if (u?.role === "trainee") {
      const readOnlyData = {
        id: event.id,
        title: event.title,
        moduleName: props.extendedProps?.moduleName || props.moduleName,
        trainerName: props.instructor,
        trainerEmail: props.trainerEmail,
        className: props.className || selectedClass()?.identifier,
        roomName:
          props.roomName === "N/A"
            ? "Online"
            : props.roomName || (props.isOnline ? "Online" : "N/A"),
        start: startVal,
        end: endVal || eventEnd.toISOString(),
        totalDuration: props.totalDuration || 0,
        currentDuration: props.currentDuration || 0,
      };
      setInfoTarget(readOnlyData);
      setIsInfoModalOpen(true);
      return true;
    }

    console.log("==== Debug ====");
    console.log("Event Trainer ID: " + eventTrainerId);
    console.log(
      "Current Trainer ID: " +
        (u && "trainer_id" in u! ? String((u as any).trainer_id) : ""),
    );
    console.log("Has Started: " + hasStarted);
    console.log("EVENT: " + Object.keys(event));
    console.log("EVENT EXTENDED PROPS: " + Object.keys(event.extendedProps));
    console.log("===============");

    if (!isClassContext) {
      const myTrainerId =
        u && "trainer_id" in u ? String((u as any).trainer_id) : "";
      const isMyClass = u?.role === "admin" || myTrainerId === eventTrainerId;

      if (hasStarted) {
        if (isMyClass) {
          const dateStr = eventStart.toLocaleDateString();
          const timeStr = `${eventStart.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })} - ${eventEnd.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}`;

          setSummaryTarget({
            id: event.id,
            title: event.title,
            moduleName: event.extendedProps?.moduleName,
            roomName: event.extendedProps?.roomName || "Online",
            dateStr,
            timeStr,
            className: event.extendedProps?.className,
            totalDuration: event.extendedProps?.totalDuration,
            currentDuration: event.extendedProps?.currentDuration,
          });
          setIsSummaryModalOpen(true);
          return true;
        } else {
          toast.error(
            `Aulas passadas: apenas o formador (${event.extendedProps?.instructor}) pode preencher sumários.`,
          );
          return false;
        }
      }
    }

    if (!canEdit()) {
      toast.success(
        `Informação da Aula:\n${event.title}\nSala: ${event.extendedProps?.roomName || "N/A"}`,
      );
      return false;
    }

    setModalMode("edit");
    setCurrentScheduleId(event.id);

    let resolvedModuleId = props.classModuleId || "";
    if (!resolvedModuleId && props.moduleName && selectedClass()?.modules) {
      const foundMod: any = selectedClass()!.modules.find(
        (m: any) =>
          m.module_name === props.moduleName || m.name === props.moduleName,
      );
      if (foundMod)
        resolvedModuleId =
          foundMod.classes_modules_id || foundMod.courses_modules_id;
    }

    setFormData({
      moduleId: String(resolvedModuleId || ""),
      trainerId: String(props.trainerId || ""),
      roomId: String(props.roomId || ""),
      start: formatForInput(event.start),
      end: formatForInput(event.end),
      isOnline: Boolean(props.isOnline),
      force: false,
    });
    setIsEditModalOpen(true);
    return true;
  };

  const handleFormChange = (newData: ScheduleFormData) => {
    if (modalMode() === "create" && newData.moduleId !== formData().moduleId) {
      const cls = selectedClass();
      let defaultTrainerId = "";
      if (cls && cls.modules) {
        const targetId = String(newData.moduleId);
        const mod = cls.modules.find(
          (m: any) =>
            (m.classes_modules_id ||
              m.classesModulesId ||
              m.courses_modules_id) === targetId,
        );
        defaultTrainerId = mod?.trainer_id || "";
      }
      setFormData({ ...newData, trainerId: defaultTrainerId, force: false });
    } else {
      setFormData(newData);
    }
  };

  const handleSave = async (data: ScheduleFormData) => {
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
        toast.success(t("dashboard.schedule.create_successful"));
      } else {
        await updateSchedule(currentScheduleId()!, payload);
        toast.success(t("dashboard.schedule.update_successful"));
      }
      setIsEditModalOpen(false);
      refetchSchedules();
    } catch (e: any) {
      if (modalMode() === "create") {
        toast.error(t("dashboard.schedule.create_fail"));
      } else {
        toast.error(t("dashboard.schedule.update_fail"));
      }
    }
  };

  const handleConfirmDelete = async () => {
    const item = itemToDelete();
    if (item) {
      try {
        await deleteSchedule(item.id);
        toast.success(t("dashboard.schedule.delete_success"));
        setItemToDelete(null);
        refetchSchedules();
      } catch (e: any) {
        toast.error(t("dashboard.schedule.delete_fail"));
      }
    }
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
                const found = availableClasses().find(
                  (c) => String(c.class_id) === id,
                );
                setSelectedClass(found || null);
              }}
            >
              <option value="">
                {user()?.role === "admin"
                  ? t("dashboard.schedule.select_class")
                  : t("dashboard.schedule.my_schedule")}
              </option>
              <For each={availableClasses()}>
                {(k) => (
                  <option value={k.class_id}>
                    {k.course_identifier} {k.location} {k.identifier}
                  </option>
                )}
              </For>
            </select>
            <Show when={schedules.loading}>
              <span class="loading loading-spinner loading-sm text-primary"></span>
            </Show>
          </div>

          <div
            class={`badge gap-2 py-4 px-4 font-bold border transition-all ${
              canEdit() && selectedClass() !== null
                ? "badge-success border-success/20 text-success-content"
                : "badge-ghost border-base-300 opacity-70"
            }`}
          >
            <Show
              when={canEdit() && selectedClass() !== null}
              fallback={
                <>
                  <Icon name="Lock" size={14} />
                  <span class="uppercase text-[10px] tracking-wider">
                    {t("dashboard.schedule.read_only")}
                  </span>
                </>
              }
            >
              <Icon name="LockOpen" size={14} />
              <span class="uppercase text-[10px] tracking-wider">
                {t("dashboard.schedule.editing")}:{" "}
                {selectedClass()?.identifier || "N/A"}
              </span>
            </Show>
          </div>
        </div>

        <div class="grow relative z-0">
          <EventCalendar
            selectedClass={selectedClass()}
            events={calendarEvents()}
            isEditable={true}
            loading={schedules.loading}
            onCreateRequest={(start, end) => {
              if (!canEdit()) return false;
              setModalMode("create");
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
              return true;
            }}
            onEditRequest={handleEditRequest}
            onMoveRequest={async (id, start, end) => {
              if (!canEdit()) return false;
              try {
                const original = displaySchedules().find(
                  (s: any) => (s.schedule_id || s.scheduleId) === id,
                );
                if (!original) return false;
                await updateSchedule(id, {
                  trainer_id: original.trainer_id || original.trainerId,
                  room_id: original.room_id || original.roomId,
                  is_online: original.is_online || original.isOnline,
                  start_time: start.toISOString(),
                  end_time: end.toISOString(),
                });
                refetchSchedules();
                return true;
              } catch (e: any) {
                toast.error(t("dashboard.schedule.move_fail"));
                return false;
              }
            }}
          />
        </div>

        <Show when={isEditModalOpen()}>
          <ModalEdit<ScheduleFormData>
            title={
              modalMode() === "create"
                ? t("dashboard.schedule.new_session")
                : t("dashboard.schedule.edit_session")
            }
            value={formData()}
            setValue={handleFormChange}
            onSave={handleSave}
            onCancel={() => setIsEditModalOpen(false)}
            onDelete={
              modalMode() === "edit"
                ? () => {
                    setItemToDelete({ id: currentScheduleId() });
                    setIsEditModalOpen(false);
                    return Promise.resolve();
                  }
                : undefined
            }
            fields={[
              {
                name: "moduleId",
                label: t("entity.module"),
                type: "select",
                required: true,
                disabled: modalMode() === "edit",
                options: moduleOptions(),
              },
              {
                name: "trainerId",
                label: t("entity.trainer"),
                type: "select",
                required: true,
                options: trainerOptions(),
              },
              {
                name: "roomId",
                label: t("entity.room"),
                type: "select",
                hidden: formData().isOnline,
                options: roomOptions(),
              },
              {
                name: "isOnline",
                label: t("entity.online_class_q"),
                type: "checkbox",
              },
              {
                name: "start",
                label: t("entity.start_time"),
                type: "datetime-local",
                disabled: true,
              },
              {
                name: "end",
                label: t("entity.end_time"),
                type: "datetime-local",
                disabled: true,
              },
              {
                name: "force",
                label: t("dashboard.schedule.force_trainer_change_q"),
                type: "checkbox",
                hidden: modalMode() === "edit",
              },
            ]}
          />
        </Show>

        <Show when={isSummaryModalOpen() && summaryTarget()}>
          <SummaryModal
            isOpen={isSummaryModalOpen()}
            onClose={() => {
              setIsSummaryModalOpen(false);
              setSummaryTarget(null);
            }}
            scheduleId={summaryTarget()!.id}
            title={summaryTarget()!.title}
            moduleName={summaryTarget()!.moduleName}
            roomName={summaryTarget()!.roomName}
            dateStr={summaryTarget()!.dateStr}
            timeStr={summaryTarget()!.timeStr}
            className={summaryTarget()!.className}
            totalDuration={summaryTarget()!.totalDuration}
            currentDuration={summaryTarget()!.currentDuration}
          />
        </Show>

        <Show when={isInfoModalOpen() && infoTarget()}>
          <ScheduleInfoModal
            isOpen={isInfoModalOpen()}
            onClose={() => {
              setIsInfoModalOpen(false);
              setInfoTarget(null);
            }}
            data={infoTarget()}
          />
        </Show>

        <ModalDelete
          onCancel={() => {}}
          value={itemToDelete}
          setValue={setItemToDelete}
          onConfirm={handleConfirmDelete}
          title={t("dashboard.schedule.delete_schedule")}
          description={t("dashboard.schedule.delete_schedule_desc_q")}
        />
      </div>
    </div>
  );
};

export default Calendar;
