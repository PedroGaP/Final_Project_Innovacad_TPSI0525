import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { Availability } from "@/types/availability";
import {
  createMemo,
  createResource,
  createSignal,
  Show,
  createEffect,
} from "solid-js";
import { AvailabilityCalendar } from "@/components/AvailabilityCalendar";
import { type EventInput } from "@fullcalendar/core";
import toast from "solid-toast";
import useI18n from "@/hooks/useL18N";

const { t } = useI18n();

const SLOT_TIMES: Record<number, { start: string; end: string }> = {
  1: { start: "08:00", end: "09:00" },
  2: { start: "09:00", end: "10:00" },
  3: { start: "10:00", end: "11:00" },
  4: { start: "12:00", end: "13:00" },
  5: { start: "13:00", end: "14:00" },
  6: { start: "14:00", end: "15:00" },
  7: { start: "16:00", end: "17:00" },
  8: { start: "17:00", end: "18:00" },
  9: { start: "18:00", end: "19:00" },
  10: { start: "20:00", end: "21:00" },
  11: { start: "21:00", end: "22:00" },
  12: { start: "22:00", end: "23:00" },
};

const SLOT_OPTIONS = [
  { label: "Slot 1 (08:00 - 09:00)", value: 1 },
  { label: "Slot 2 (09:00 - 10:00)", value: 2 },
  { label: "Slot 3 (10:00 - 11:00)", value: 3 },
  { label: "Slot 4 (12:00 - 13:00)", value: 4 },
  { label: "Slot 5 (13:00 - 14:00)", value: 5 },
  { label: "Slot 6 (14:00 - 15:00)", value: 6 },
  { label: "Slot 7 (16:00 - 17:00)", value: 7 },
  { label: "Slot 8 (17:00 - 18:00)", value: 8 },
  { label: "Slot 9 (18:00 - 19:00)", value: 9 },
  { label: "Slot 10 (20:00 - 21:00)", value: 10 },
  { label: "Slot 11 (21:00 - 22:00)", value: 11 },
  { label: "Slot 12 (22:00 - 23:00)", value: 12 },
];

const normalizeId = (id: string | undefined | null) => {
  return String(id || "")
    .trim()
    .toLowerCase();
};

const getTrainerId = (u: any): string => {
  if (!u) return "";
  const id = u.trainer_id || u.trainerId || u.id;
  return id ? String(id) : "";
};

const toInputDate = (dateVal?: string | number | Date): string => {
  if (!dateVal) {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
  }
  try {
    const strVal = String(dateVal);
    if (strVal.includes("T")) return strVal.split("T")[0];
    if (strVal.includes("-") && strVal.length === 10) return strVal;

    let ts = Number(strVal);
    if (!isNaN(ts)) {
      if (ts < 100000000000) ts *= 1000;
      const d = new Date(ts);
      const year = d.getUTCFullYear();
      const month = String(d.getUTCMonth() + 1).padStart(2, "0");
      const day = String(d.getUTCDate()).padStart(2, "0");
      return `${year}-${month}-${day}`;
    }
    return strVal;
  } catch {
    return "";
  }
};

const createEmptyAvailability = (): Availability =>
  ({
    trainer_id: "",
    date_day: toInputDate(),
    slot_number: 1,
    is_booked: false,
  }) as unknown as Availability;

const toSafeLocalDate = (input: string | Date): Date => {
  const d = new Date(input);
  if (input instanceof Date) return d;

  if (/^\d{4}-\d{2}-\d{2}$/.test(input)) {
    const [y, m, day] = input.split("-").map(Number);
    return new Date(y, m - 1, day);
  }
  return d;
};

const getLocalYYYYMMDD = (date: Date): string => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
};

const getMatchingSlots = (start: Date, end: Date): number[] => {
  const matching: number[] = [];

  const baseDay = new Date(start);

  for (const [slotNum, times] of Object.entries(SLOT_TIMES)) {
    const [sh, sm] = times.start.split(":").map(Number);
    const [eh, em] = times.end.split(":").map(Number);

    const slotStart = new Date(baseDay);
    slotStart.setHours(sh, sm, 0, 0);

    const slotEnd = new Date(baseDay);
    slotEnd.setHours(eh, em, 0, 0);

    if (start < slotEnd && end > slotStart) {
      matching.push(Number(slotNum));
    }
  }
  return matching;
};
const AvailabilitiesPage = () => {
  const api = useApi();
  const { user } = useUserDetails();

  const [viewMode, setViewMode] = createSignal<"calendar" | "list">("calendar");
  const [selectedTrainerFilter, setSelectedTrainerFilter] =
    createSignal<string>("");

  const [availabilitiesData, { refetch }] = createResource<Availability[]>(
    api.fetchAvailabilities,
  );

  createEffect(() => {
    selectedTrainerFilter();
    refetch();
  });
  const [trainersData] = createResource(api.fetchTrainers);

  const isStrictTrainer = createMemo(() => {
    const u = user();
    return (u?.role || "").toLowerCase() !== "admin";
  });

  const filteredAvailabilities = createMemo(() => {
    const list = availabilitiesData();
    if (!list) return [];

    const u = user();
    if (!u) return [];

    const role = (u.role || "").toLowerCase();
    let result = list;
    const myId = getTrainerId(u);

    if (role !== "admin") {
      if (!myId) return [];
      result = list.filter(
        (a) => normalizeId(a.trainer_id) === normalizeId(myId),
      );
    }

    if (selectedTrainerFilter()) {
      result = result.filter(
        (a) =>
          normalizeId(a.trainer_id) === normalizeId(selectedTrainerFilter()),
      );
    }

    return result;
  });
  const trainerOptions = createMemo(() => {
    const allTrainers = trainersData();
    const u = user();

    if (isStrictTrainer()) {
      return [
        {
          label: `${u?.name} (Me)`,
          value: getTrainerId(u),
        },
      ];
    }

    if (!allTrainers) return [];

    return allTrainers.map((t) => ({
      label: `${t.name} (${t.email})`,
      value: getTrainerId(t) || t.id || "",
    }));
  });

  const formFieldsConfig = createMemo<ModalFieldDefinition<Availability>[]>(
    () => [
      {
        label: t("dashboard.availabilities.fields.trainer"),
        name: "trainer_id",
        type: "select",
        options: trainerOptions(),
        required: true,
        disabled: isStrictTrainer(),
        placeholder: t("dashboard.availabilities.fields.trainer"),
      },
      {
        label: t("dashboard.availabilities.fields.date"),
        name: "date_day",
        type: "date",
        required: true,
      },
      {
        label: t("dashboard.availabilities.fields.slot"),
        name: "slot_number",
        type: "select",
        options: SLOT_OPTIONS.map((s) => ({
          ...s,
          label: s.label.replace(
            "Slot",
            t("dashboard.availabilities.fields.slot"),
          ),
        })),
        required: true,
      },
      {
        label: t("dashboard.availabilities.fields.modal.booked_status"),
        name: "is_booked",
        type: "checkbox",
        disabled: true,
      },
    ],
  );

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast.success(t("dashboard.availabilities.alerts.id_copied"));
  };

  const handleSave = async (
    availability: Availability,
    original: Availability | null,
  ) => {
    if (
      !availability.trainer_id ||
      !availability.date_day ||
      !availability.slot_number
    ) {
      toast.error(t("dashboard.availabilities.alerts.fill_required"));
      throw new Error("Validation failed");
    }

    const cleanData = {
      ...availability,
      date_day: toInputDate(availability.date_day),
      slot_number: Number(availability.slot_number),
    };

    try {
      if (original) {
        await api.updateAvailability(
          String(availability.availability_id),
          cleanData as any,
        );
        await refetch();
        toast.success(t("dashboard.availabilities.update_successful"));
      } else {
        await api.createAvailability({
          trainer_id: String(cleanData.trainer_id),
          date_day: String(cleanData.date_day),
          slot_number: Number(cleanData.slot_number),
          is_booked: 0,
        });
        await refetch();
        toast.success(t("dashboard.availabilities.create_successful"));
      }
    } catch (e: any) {
      if (e.message !== "Validation failed") toast.error(e.message);
      throw e;
    }
  };

  const confirmDelete = async (item: Availability) => {
    const id = String(item.availability_id);
    if (!id || id === "undefined") return;
    try {
      await api.deleteAvailability(id);
    } catch (e) {
      console.warn("Delete failed", e);
    }

    await refetch();
    toast.success(t("dashboard.availabilities.delete_successful"));
  };

  const prepareAdd = () => {
    const empty = createEmptyAvailability();
    const u = user();
    const myId = getTrainerId(u);

    if (isStrictTrainer() && myId) {
      empty.trainer_id = myId;
    }
    return empty;
  };

  const trainersMap = createMemo(() => {
    const map = new Map();
    const list = trainersData();
    if (list) {
      list.forEach((t) => {
        map.set(normalizeId(t.id), t);
        if (t.trainer_id) map.set(normalizeId(t.trainer_id), t);
      });
    }
    return map;
    return map;
  });

  const calendarEvents = createMemo<EventInput[]>(() => {
    const list = filteredAvailabilities();
    if (!list) return [];

    const groups: Record<string, Availability[]> = {};
    for (const av of list) {
      if (!av.slot_number) continue;
      const date = toInputDate(av.date_day);
      const key = `${normalizeId(av.trainer_id)}-${date}-${av.is_booked}`;
      if (!groups[key]) groups[key] = [];
      groups[key].push(av);
    }

    const events: EventInput[] = [];

    for (const key in groups) {
      const group = groups[key];
      group.sort((a, b) => (a.slot_number || 0) - (b.slot_number || 0));

      let currentEvent: EventInput | null = null;
      let lastEndTime: string | null = null;

      for (const av of group) {
        if (!av.slot_number) continue;
        const times = SLOT_TIMES[av.slot_number];
        if (!times) continue;

        const date = toInputDate(av.date_day);
        const startStr = `${date}T${times.start}`;
        const endStr = `${date}T${times.end}`;

        let isContiguous = false;
        if (currentEvent && lastEndTime && lastEndTime === startStr) {
          isContiguous = true;
        }

        if (isContiguous && currentEvent) {
          currentEvent.end = endStr;
          if (currentEvent.extendedProps) {
            currentEvent.extendedProps.mergedIds.push(
              String(av.availability_id),
            );
          }
          lastEndTime = endStr;
        } else {
          const trainer = trainersMap().get(normalizeId(av.trainer_id));
          const trainerName = trainer?.name || "Unknown";

          currentEvent = {
            id: String(av.availability_id),
            title: t("dashboard.availabilities.fields.available"),
            start: startStr,
            end: endStr,
            backgroundColor: av.is_booked
              ? "var(--color-error)"
              : "var(--color-success)",
            borderColor: av.is_booked
              ? "var(--color-error)"
              : "var(--color-success)",
            textColor: "#fff",
            extendedProps: {
              trainerName,
              mergedIds: [String(av.availability_id)],
              ...av,
            },
          };
          events.push(currentEvent);
          lastEndTime = endStr;
        }
      }
    }

    return events;
  });

  const handleCalendarCreate = async (startStr: string, endStr: string) => {
    const startDate = toSafeLocalDate(startStr);
    const endDate = toSafeLocalDate(endStr);

    const dateDay = getLocalYYYYMMDD(startDate);

    const slotsToCreate = getMatchingSlots(startDate, endDate);

    if (slotsToCreate.length === 0) {
      toast.error(t("dashboard.availabilities.alerts.select_range"));
      return;
    }

    try {
      const u = user();
      let trainerId = isStrictTrainer() ? getTrainerId(u) : "";

      if (!isStrictTrainer()) {
        if (selectedTrainerFilter()) {
          trainerId = selectedTrainerFilter();
        }
      }

      if (!trainerId) {
        toast.error(t("dashboard.availabilities.alerts.select_trainer"));
        return;
      }

      const createdList: Availability[] = [];
      for (const slot of slotsToCreate) {
        try {
          const newAv = await api.createAvailability({
            trainer_id: trainerId,
            date_day: dateDay,
            slot_number: slot,
            is_booked: 0,
          });
          createdList.push(newAv);
        } catch (e) {
          console.warn(`Failed to create for slot ${slot}`, e);
        }
      }

      if (createdList.length > 0) {
        await refetch();
        toast.success(
          t("dashboard.availabilities.alerts.created_slots", {
            count: createdList.length,
          }),
        );
      } else {
        toast.error(t("dashboard.availabilities.alerts.create_fail_slots"));
      }
    } catch (e: any) {
      toast.error(e.message);
    }
  };

  const handleCalendarEdit = async (event: any) => {
    const props = event.extendedProps;
    const idsToDelete: string[] = props.mergedIds || [event.id];

    if (
      confirm(
        `${t("dashboard.availabilities.alerts.delete_confirmation")} ${idsToDelete.length > 1
          ? t("dashboard.availabilities.alerts.delete_slots_info", {
            count: idsToDelete.length,
          })
          : ""
        }`,
      )
    ) {
      try {
        for (const id of idsToDelete) {
          if (!id || id === "undefined") continue;
          try {
            await api.deleteAvailability(id);
          } catch (e) {
            console.warn(`Failed to delete ${id}`, e);
          }
        }

        await refetch();
        toast.success(t("dashboard.availabilities.delete_successful"));
      } catch (e) {
        console.error(e);
        toast.error(t("dashboard.availabilities.alerts.delete_partial_fail"));
      }
    }
  };

  const handleCalendarMove = async (
    event: any,
    newStartStr: string,
    newEndStr: string,
  ) => {
    const props = event.extendedProps;
    const idsToDelete: string[] = props.mergedIds || [event.id];
    const trainerId = props.trainer_id;

    const newStart = toSafeLocalDate(newStartStr);
    const newEnd = toSafeLocalDate(newEndStr);

    const newSlots = getMatchingSlots(newStart, newEnd);
    const dateDay = getLocalYYYYMMDD(newStart);

    if (newSlots.length === 0) {
      toast.error(t("dashboard.availabilities.alerts.no_slots"));
      throw new Error("Invalid range");
    }

    try {
      for (const slot of newSlots) {
        await api.createAvailability({
          trainer_id: trainerId,
          date_day: dateDay,
          slot_number: slot,
          is_booked: 0,
        });
      }

      for (const id of idsToDelete) {
        if (!id || id === "undefined") continue;
        try {
          await api.deleteAvailability(id);
        } catch (e) {
          console.warn(
            `Failed to delete ${id}, likely already deleted or not found.`,
          );
        }
      }

      await refetch();
    } catch (e) {
      console.error(e);
      toast.error(t("dashboard.availabilities.alerts.moved_fail"));
      throw e;
    }
  };

  const isRangeValid = (start: string | Date, end: string | Date) => {
    const s = toSafeLocalDate(start);
    const e = toSafeLocalDate(end);

    for (const [_, times] of Object.entries(SLOT_TIMES)) {
      const [sh, sm] = times.start.split(":").map(Number);
      const [eh, em] = times.end.split(":").map(Number);

      const slotStart = new Date(s);
      slotStart.setHours(sh, sm, 0, 0);

      const slotEnd = new Date(s);
      slotEnd.setHours(eh, em, 0, 0);

      if (s < slotEnd && e > slotStart) {
        return true;
      }
    }
    return false;
  };

  return (
    <div class="p-6 h-full flex flex-col gap-6">
      <div class="flex flex-col sm:flex-row justify-between items-center gap-4">
        <div class="flex items-center gap-4 w-full sm:w-auto">
          <h1 class="text-2xl font-bold text-base-content">
            {t("dashboard.availabilities.title")}
          </h1>
          <Show when={!isStrictTrainer() && trainersData()}>
            <select
              class="select select-bordered select-sm w-full max-w-xs"
              value={selectedTrainerFilter()}
              onChange={(e) => setSelectedTrainerFilter(e.currentTarget.value)}
            >
              <option value="">
                {t("dashboard.availabilities.select_default")}
              </option>
              {trainerOptions().map((t) => (
                <option value={String(t.value)}>{t.label}</option>
              ))}
            </select>
          </Show>
        </div>

        <div class="join bg-base-200/50 p-1 rounded-lg">
          <button
            class={`join-item btn border-0 ${viewMode() === "calendar" ? "btn-active shadow-sm !bg-base-100 text-base-content hover:!bg-base-100" : "btn-ghost text-base-content/70 hover:bg-transparent"}`}
            onClick={() => setViewMode("calendar")}
          >
            {t("dashboard.availabilities.btn.calendar")}
          </button>
          <button
            class={`join-item btn border-0 ${viewMode() === "list" ? "btn-active shadow-sm !bg-base-100 text-base-content hover:!bg-base-100" : "btn-ghost text-base-content/70 hover:bg-transparent"}`}
            onClick={() => setViewMode("list")}
          >
            {t("dashboard.availabilities.btn.list")}
          </button>
        </div>
      </div>

      <div class="flex-1 min-h-0">
        <Show when={viewMode() === "calendar"}>
          <div class="card bg-base-100 shadow-xl h-full border border-base-300">
            <div class="card-body p-4 h-full relative overflow-hidden">
              <AvailabilityCalendar
                events={calendarEvents()}
                isEditable={true}
                loading={availabilitiesData.loading}
                onCreateRequest={handleCalendarCreate}
                onEditRequest={handleCalendarEdit}
                onMoveRequest={handleCalendarMove}
                validateDrop={isRangeValid}
              />
            </div>
          </div>
        </Show>

        <Show when={viewMode() === "list"}>
          <EntityTable<Availability>
            title=""
            data={filteredAvailabilities}
            handleEditClick={(item) => ({
              ...item,
              date_day: toInputDate(item.date_day),
            })}
            handleAddClick={prepareAdd}
            confirmDelete={confirmDelete}
            handleSave={handleSave}
            formFields={formFieldsConfig()}
            filter={(e: Availability, search: string) => {
              const s = search.toLowerCase();
              const tData = trainersData();

              const trainer = tData?.find(
                (t) =>
                  normalizeId(getTrainerId(t)) === normalizeId(e.trainer_id),
              );
              const tName = trainer?.name?.toLowerCase() || "";
              const dateStr = toInputDate(e.date_day);

              return tName.includes(s) || dateStr.includes(s);
            }}
            fields={[
              {
                formattedName: t("dashboard.availabilities.fields.trainer"),
                fieldName: "trainer_id",
                canCopy: false,
                customGeneration: (e) => {
                  return (
                    <Show
                      when={!trainersData.loading && trainersData()}
                      fallback={<div class="skeleton h-4 w-32"></div>}
                    >
                      {(_) => {
                        const avTrainerId = normalizeId(e.trainer_id);
                        const trainer = trainersMap().get(avTrainerId);

                        const name =
                          trainer?.name ||
                          trainer?.username ||
                          t("common.unknown_trainer");
                        const idToDisplay = e.trainer_id || "N/A";

                        return (
                          <div class="flex flex-col items-start justify-center">
                            <div class="font-bold text-sm">{name}</div>
                            <div
                              class="text-[10px] font-mono opacity-60 flex items-center gap-1 cursor-pointer hover:text-primary hover:opacity-100 transition-colors"
                              onClick={(evt) => {
                                evt.stopPropagation();
                                copyToClipboard(idToDisplay);
                              }}
                              title="Click to copy ID"
                            >
                              {idToDisplay.substring(0, 8)}...
                            </div>
                          </div>
                        );
                      }}
                    </Show>
                  );
                },
              },
              {
                formattedName: t("dashboard.availabilities.fields.date"),
                fieldName: "date_day",
                customGeneration: (e) => toInputDate(e.date_day),
              },
              {
                formattedName: t("dashboard.availabilities.fields.slot"),
                fieldName: "slot_number",
                customGeneration: (e) => {
                  const slot = SLOT_OPTIONS.find(
                    (s) => s.value == e.slot_number,
                  );
                  return (
                    <span class="badge badge-ghost badge-sm">
                      {slot ? slot.label : `Slot ${e.slot_number}`}
                    </span>
                  );
                },
              },
              {
                formattedName: t(
                  "dashboard.availabilities.fields.status.title",
                ),
                fieldName: "is_booked",
                customGeneration: (e) =>
                  e.is_booked ? (
                    <span class="badge badge-error gap-1 text-xs font-semibold text-white">
                      {t("dashboard.availabilities.fields.status.booked")}
                    </span>
                  ) : (
                    <span class="badge badge-success gap-1 text-xs font-semibold text-white">
                      {t("dashboard.availabilities.fields.status.free")}
                    </span>
                  ),
              },
            ]}
          />
        </Show>
      </div>
    </div>
  );
};

export default AvailabilitiesPage;
