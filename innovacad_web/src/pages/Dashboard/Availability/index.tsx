import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { Availability } from "@/types/availability";
import { createEffect, createMemo, createResource, Show } from "solid-js";
import toast from "solid-toast";

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
  if (!dateVal) return new Date().toISOString().split("T")[0];
  try {
    const strVal = String(dateVal);
    if (strVal.includes("T")) return strVal.split("T")[0];
    if (strVal.includes("-") && strVal.length === 10) return strVal;
    if (!isNaN(Number(strVal))) {
      let ts = Number(strVal);
      if (ts < 100000000000) ts *= 1000;
      return new Date(ts).toISOString().split("T")[0];
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

const AvailabilitiesPage = () => {
  const api = useApi();
  const { user } = useUserDetails();

  const [availabilitiesData, { mutate }] = createResource<Availability[]>(
    api.fetchAvailabilities,
  );
  const [trainersData] = createResource(api.fetchTrainers);

  createEffect(() => {
    const u = user();
    if (u) {
      console.log("DEBUG: Current User:", u.name, "| Role:", u.role);
      console.log("DEBUG: Detected Trainer ID:", getTrainerId(u));
    }
  });

  const isStrictTrainer = createMemo(() => {
    const u = user();
    return u?.role === "trainer";
  });

  const filteredAvailabilities = createMemo(() => {
    const list = availabilitiesData();
    if (!list) return [];

    const u = user();
    if (!u) return [];

    const role = u.role as string;

    if (role === "admin" || role === "coordinator") return list;

    const myId = getTrainerId(u);
    if (!myId) return [];

    console.log(
      `DEBUG: Filtering ${list.length} records for Trainer ID: ${myId}`,
    );

    const results = list.filter((a) => {
      const isMatch = normalizeId(a.trainer_id) === normalizeId(myId);
      return isMatch;
    });

    console.log(`DEBUG: Found ${results.length} matches.`);
    return results;
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
        label: "Trainer",
        name: "trainer_id",
        type: "select",
        options: trainerOptions(),
        required: true,
        disabled: isStrictTrainer(),
        placeholder: "Select Trainer",
      },
      {
        label: "Date",
        name: "date_day",
        type: "date",
        required: true,
      },
      {
        label: "Slot Time",
        name: "slot_number",
        type: "select",
        options: SLOT_OPTIONS,
        required: true,
      },
      {
        label: "Booked Status",
        name: "is_booked",
        type: "checkbox",
        disabled: true,
      },
    ],
  );

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
    toast.success("ID copiado!");
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
      toast.error("Preencha todos os campos obrigatórios");
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
        mutate(
          (prev) =>
            prev?.map((u) =>
              u.availability_id === availability.availability_id
                ? (cleanData as Availability)
                : u,
            ) || [],
        );
        toast.success("Updated");
      } else {
        const newAv = await api.createAvailability({
          trainer_id: String(cleanData.trainer_id),
          date_day: String(cleanData.date_day),
          slot_number: Number(cleanData.slot_number),
          is_booked: 0,
        });
        mutate((prev) => [...(prev || []), newAv]);
        toast.success("Created");
      }
    } catch (e: any) {
      if (e.message !== "Validation failed") toast.error(e.message);
      throw e;
    }
  };

  const confirmDelete = async (item: Availability) => {
    await api.deleteAvailability(String(item.availability_id));
    mutate(
      (prev) =>
        prev?.filter((c) => c.availability_id !== item.availability_id) || [],
    );
    toast.success("Availability deleted");
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
  });

  return (
    <EntityTable<Availability>
      title="Manage Availabilities"
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
          (t) => normalizeId(getTrainerId(t)) === normalizeId(e.trainer_id),
        );
        const tName = trainer?.name?.toLowerCase() || "";
        const dateStr = toInputDate(e.date_day);

        return tName.includes(s) || dateStr.includes(s);
      }}
      fields={[
        {
          formattedName: "Trainer",
          fieldName: "trainer_id",
          canCopy: false,
          customGeneration: (e) => {
            return (
              <Show
                when={!trainersData.loading && trainersData()}
                fallback={<div class="skeleton h-4 w-32"></div>}
              >
                {(trainers) => {
                  const avTrainerId = normalizeId(e.trainer_id);
                  const trainer = trainersMap().get(avTrainerId);

                  const name =
                    trainer?.name || trainer?.username || "Unknown Trainer";
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
          formattedName: "Date",
          fieldName: "date_day",
          customGeneration: (e) => toInputDate(e.date_day),
        },
        {
          formattedName: "Slot",
          fieldName: "slot_number",
          customGeneration: (e) => {
            const slot = SLOT_OPTIONS.find((s) => s.value == e.slot_number);
            return (
              <span class="badge badge-ghost badge-sm">
                {slot ? slot.label : `Slot ${e.slot_number}`}
              </span>
            );
          },
        },
        {
          formattedName: "Status",
          fieldName: "is_booked",
          customGeneration: (e) =>
            e.is_booked ? (
              <span class="badge badge-error gap-1 text-xs font-semibold text-white">
                Booked
              </span>
            ) : (
              <span class="badge badge-success gap-1 text-xs font-semibold text-white">
                Free
              </span>
            ),
        },
      ]}
    />
  );
};

export default AvailabilitiesPage;
