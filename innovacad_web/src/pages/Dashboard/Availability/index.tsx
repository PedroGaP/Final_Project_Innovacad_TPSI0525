import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import { Availability } from "@/types/availability";
// REMOVIDO: import type { Trainer } ... (Erro 6133)
import { createEffect, createMemo, createResource, Show } from "solid-js";
import toast from "solid-toast";

const SLOT_OPTIONS = [
  { label: "Slot 1 (08:00 - 09:00)", value: 1 },
  { label: "Slot 2 (09:00 - 10:00)", value: 2 },
  { label: "Slot 3 (10:00 - 11:00)", value: 3 },
  { label: "Slot 4 (11:00 - 12:00)", value: 4 },
  { label: "Slot 5 (12:00 - 13:00)", value: 5 },
  { label: "Slot 6 (13:00 - 14:00)", value: 6 },
  { label: "Slot 7 (14:00 - 15:00)", value: 7 },
  { label: "Slot 8 (15:00 - 16:00)", value: 8 },
  { label: "Slot 9 (16:00 - 17:00)", value: 9 },
  { label: "Slot 10 (17:00 - 18:00)", value: 10 },
  { label: "Slot 11 (18:00 - 19:00)", value: 11 },
  { label: "Slot 12 (19:00 - 20:00)", value: 12 },
  { label: "Slot 13 (20:00 - 21:00)", value: 13 },
  { label: "Slot 14 (21:00 - 22:00)", value: 14 },
  { label: "Slot 15 (22:00 - 23:00)", value: 15 },
];

const normalizeId = (id: string | undefined | null) => {
  return String(id || "")
    .trim()
    .toLowerCase();
};

// Helper robusto para obter o ID do trainer da sessão
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

  // --- Data Fetching ---
  const [availabilitiesData, { mutate }] = createResource<Availability[]>(
    api.fetchAvailabilities,
  );
  const [trainersData] = createResource(api.fetchTrainers);

  // --- Debug Effect ---
  createEffect(() => {
    const u = user();
    if (u) {
      console.log("DEBUG: Current User:", u.name, "| Role:", u.role);
      console.log("DEBUG: Detected Trainer ID:", getTrainerId(u));
    }
  });

  // --- Helpers de Permissões ---
  const isStrictTrainer = createMemo(() => {
    const u = user();
    // CORREÇÃO (Erro 2367): Simplificado. Se é trainer, não é admin.
    return u?.role === "trainer";
  });

  // --- Filtragem de Dados (Visualização) ---
  const filteredAvailabilities = createMemo(() => {
    const list = availabilitiesData();
    if (!list) return [];

    const u = user();
    if (!u) return [];

    const role = u.role as string;

    // Se for Admin, mostra tudo
    if (role === "admin" || role === "coordinator") return list;

    // Se for Trainer
    const myId = getTrainerId(u);
    if (!myId) return [];

    console.log(
      `DEBUG: Filtering ${list.length} records for Trainer ID: ${myId}`,
    );

    const results = list.filter((a) => {
      const isMatch = normalizeId(a.trainer_id) === normalizeId(myId);
      // Descomenta a linha abaixo se quiseres ver cada comparação (pode encher a consola)
      // if (isMatch) console.log(">> Found Record:", a);
      return isMatch;
    });

    console.log(`DEBUG: Found ${results.length} matches.`);
    return results;
  });
  // --- Configuração do Formulário ---
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
      // CORREÇÃO (Erro 2322): Adicionado || "" para garantir que nunca é undefined
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

  // --- Actions ---

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
                  const trainer = trainers().find(
                    (t) =>
                      normalizeId(getTrainerId(t)) === avTrainerId ||
                      normalizeId(t.id) === avTrainerId,
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
