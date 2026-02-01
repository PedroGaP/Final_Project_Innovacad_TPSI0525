import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { Availability } from "@/types/availability";
import { createResource, createMemo, Show } from "solid-js";
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

  const [availabilitiesData, { mutate }] = createResource<Availability[]>(
    api.fetchAvailabilities,
  );

  const [trainersData] = createResource(api.fetchTrainers);

  const trainerOptions = createMemo(() => {
    return (
      trainersData()?.map((t) => ({
        label:
          `${t.name} (${t.email})` || `Trainer ${t.trainerId?.substring(0, 4)}`,
        value: t.trainerId || "",
      })) || []
    );
  });

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
  };

  return (
    <EntityTable<Availability>
      title="Manage Availabilities"
      data={availabilitiesData}
      handleEditClick={(item) => ({
        ...item,
        date_day: toInputDate(item.date_day),
      })}
      handleAddClick={() => createEmptyAvailability()}
      confirmDelete={confirmDelete}
      handleSave={handleSave}
      formFields={[
        {
          label: "Trainer",
          name: "trainer_id",
          type: "select",
          options: trainerOptions(),
          required: true,
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
          label: "Booked",
          name: "is_booked",
          type: "checkbox",
          disabled: true,
        },
      ]}
      fields={[
        {
          formattedName: "Trainer",
          fieldName: "trainer_id",
          canCopy: false,
          customGeneration: (e) => {
            return (
              <Show
                when={!trainersData.loading && trainersData()}
                fallback={
                  <div class="flex flex-col gap-1 w-32 animate-pulse">
                    <div class="h-4 bg-base-300 rounded w-full"></div>
                    <div class="h-2 bg-base-300 rounded w-2/3"></div>
                  </div>
                }
              >
                {(trainers) => {
                  const availabilityTrainerId = normalizeId(e.trainer_id);
                  const trainer = trainers().find(
                    (t) => normalizeId(t.trainerId) === availabilityTrainerId,
                  );

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
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          width="10"
                          height="10"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          stroke-width="2"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                        >
                          <rect
                            width="14"
                            height="14"
                            x="8"
                            y="8"
                            rx="2"
                            ry="2"
                          />
                          <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2" />
                        </svg>
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
              <span class="badge badge-error gap-1 text-xs">Booked</span>
            ) : (
              <span class="badge badge-success gap-1 text-xs">Free</span>
            ),
        },
      ]}
    />
  );
};

export default AvailabilitiesPage;
