import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import {
  AvailabilityStatusEnum,
  type Availability,
} from "@/types/availability";
import { createResource } from "solid-js";
import toast from "solid-toast";

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";

  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";

  const pad = (n: number) => n.toString().padStart(2, "0");

  const yyyy = date.getFullYear();
  const mm = pad(date.getMonth() + 1);
  const dd = pad(date.getDate());
  const hh = pad(date.getHours());
  const min = pad(date.getMinutes());

  return `${yyyy}-${mm}-${dd}T${hh}:${min}`;
};

const createEmptyAvailability = (): Availability =>
  ({
    trainer_id: "",
    status: AvailabilityStatusEnum.FREE,
    start_date_timestamp: "",
    end_date_timestamp: "",
  }) as unknown as Availability;

const validateAvailability = (
  availability: Availability,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const trainer_id = String(availability.trainer_id || "").trim();
  if (!trainer_id) {
    errors.push("Trainer Id is required");
  }

  const status = String(availability.status || "").trim();
  if (!status) {
    errors.push("Staatus Type is required");
  } else if (!(status.toUpperCase() in AvailabilityStatusEnum)) {
    errors.push("Status Type is invalid");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldAvailability: Availability,
  newAvailability: Availability,
): {
  trainer_id?: string;
  status?: string;
  start_date_timestamp?: string;
  end_date_timestamp?: string;
} => {
  const changes: any = {};

  if (
    String(oldAvailability.trainer_id) !== String(newAvailability.trainer_id)
  ) {
    changes.trainer_id = String(newAvailability.trainer_id);
  }

  if (String(oldAvailability.status) !== String(newAvailability.status)) {
    changes.status = String(newAvailability.status);
  }

  if (
    String(oldAvailability.start_date_timestamp) !==
    String(newAvailability.start_date_timestamp)
  ) {
    changes.status = String(newAvailability.start_date_timestamp);
  }

  if (
    String(oldAvailability.end_date_timestamp) !==
    String(newAvailability.end_date_timestamp)
  ) {
    changes.status = String(newAvailability.end_date_timestamp);
  }

  return changes;
};

const AvailabilitiesPage = () => {
  const api = useApi();

  const [availabilityesData, { mutate }] = createResource<Availability[]>(
    api.fetchAvailabilities,
  );

  const handleSaveTrainee = async (
    availability: Availability,
    original: Availability | null,
  ) => {
    try {
      const validation = validateAvailability(availability);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, availability);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateAvailability(
          String(availability.availability_id),
          changedFields,
        );

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.availability_id === availability.availability_id
                ? availability
                : u,
            ) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(
          `Availability updated successfully (${changedFieldNames})`,
        );
      } else {
        const availabilityObj = {
          trainer_id: String(availability.trainer_id),
          status: String(availability.status),
          start_date_timestamp: String(availability.start_date_timestamp),
          end_date_timestamp: String(availability.end_date_timestamp),
        };

        const newAvailability = await api.createAvailability(availabilityObj);

        mutate((prev: Availability[] | undefined) => [
          ...(prev || []),
          newAvailability,
        ]);
        toast.success("Availability created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save availability");
      }
      throw error;
    }
  };

  const confirmDelete = async (availabilityToDelete: Availability) => {
    await api.deleteAvailability(String(availabilityToDelete.availability_id));
    mutate(
      (prev: Availability[] | undefined) =>
        prev?.filter(
          (c: Availability) =>
            c.availability_id !== availabilityToDelete.availability_id,
        ) || [],
    );
  };

  return (
    <EntityTable<Availability>
      title="Manage Availabilities"
      data={availabilityesData}
      handleEditClick={(availability) => ({
        ...availability,
      })}
      handleAddClick={() => createEmptyAvailability()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainee}
      fields={[
        {
          formattedName: "Availability ID",
          fieldName: "availability_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Trainer ID",
          fieldName: "trainer_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Status Type",
          fieldName: "status",
          capitalizeValue: true,
        },
        {
          formattedName: "Start Date",
          fieldName: "start_date_timestamp",
          capitalizeValue: true,
          customGeneration: (e: Availability) =>
            epochToDateTime(e.start_date_timestamp!),
        },
        {
          formattedName: "End Date",
          fieldName: "end_date_timestamp",
          capitalizeValue: true,
          customGeneration: (e: Availability) =>
            epochToDateTime(e.end_date_timestamp!),
        },
      ]}
    ></EntityTable>
  );
};

export default AvailabilitiesPage;
