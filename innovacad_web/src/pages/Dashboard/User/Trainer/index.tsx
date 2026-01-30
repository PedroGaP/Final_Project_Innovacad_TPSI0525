import { createResource } from "solid-js";
import type { Trainer } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";

const createEmptyTrainer = (): Trainer =>
  ({
    id: "",
    name: "",
    email: "",
    role: "trainer",
    trainerId: "",
    username: "",
    token: "",
    specialization: "",
    birthdayDate: "" as unknown as number, // Initialized for form string
    image: null,
    verified: false,
    session_token: "",
  }) as unknown as Trainer;

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

const validateTrainer = (
  trainer: Trainer,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(trainer.name || "").trim();
  if (!name) {
    errors.push("Name is required");
  }

  const email = String(trainer.email || "").trim();
  if (!email) {
    errors.push("Email is required");
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push("Email is invalid");
  }

  const username = String(trainer.username || "").trim();
  if (!username) {
    errors.push("Username is required");
  } else if (username.length < 3) {
    errors.push("Username must be at least 3 characters");
  }

  const birthdayDate = String(trainer.birthdayDate || "").trim();
  if (!birthdayDate) {
    errors.push("Birthday date is required");
  }

  const specialization = String(trainer.specialization || "").trim();
  if (!specialization) {
    errors.push("Specialization is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldTrainer: Trainer,
  newTrainer: Trainer,
): {
  name?: string;
  email?: string;
  username?: string;
  birthdayDate?: string;
  specialization?: string;
} => {
  const changes: any = {};

  if (String(oldTrainer.name) !== String(newTrainer.name)) {
    changes.name = String(newTrainer.name);
  }

  if (String(oldTrainer.email) !== String(newTrainer.email)) {
    changes.email = String(newTrainer.email);
  }

  if (String(oldTrainer.username) !== String(newTrainer.username)) {
    changes.username = String(newTrainer.username);
  }

  if (String(oldTrainer.birthdayDate) !== String(newTrainer.birthdayDate)) {
    changes.birthdayDate = epochToDateTime(newTrainer.birthdayDate!);
  }

  if (String(oldTrainer.specialization) !== String(newTrainer.specialization)) {
    changes.specialization = String(newTrainer.specialization);
  }

  return changes;
};

const TrainerPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainer[]>(api.fetchTrainers);

  const handleSaveTrainer = async (
    trainer: Trainer,
    original: Trainer | null,
  ) => {
    try {
      const validation = validateTrainer(trainer);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, trainer);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateTrainer(String(trainer.trainerId), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.trainerId === trainer.trainerId ? trainer : u,
            ) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Trainer updated successfully (${changedFieldNames})`);
      } else {
        const trainerObj = {
          name: String(trainer.name),
          email: String(trainer.email),
          username: String(trainer.username),
          birthdayDate: epochToDateTime(trainer.birthdayDate!),
          specialization: String(trainer.specialization),
          password: "T" + Math.random().toString(36).slice(-10) + "1@",
        };

        const newTrainer = await api.createTrainer(trainerObj);

        try {
          await api.sendEmail({
            to: trainer.email!,
            subject: "Account Creation - New Password Innovacad",
            body: newPasswordEmail(trainerObj.password),
          });
        } catch (error) {
          console.error(
            `Something went wrong sending an email for ${trainer.email}`,
            error,
          );
        }

        mutate((prev) => [...(prev || []), newTrainer]);
        toast.success(
          "Trainer created successfully. A temporary password has been sent to their email.",
        );
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainer");
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Trainer) => {
    await api.deleteTrainer(String(userToDelete.trainerId));
    mutate(
      (prev) =>
        prev?.filter((u) => u.trainerId !== userToDelete.trainerId) || [],
    );
  };

  return (
    <EntityTable<Trainer>
      title="Manage Trainers"
      data={usersData}
      // Prepare data for the Edit Modal (convert Epoch to String for Date Input)
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDateTime(user.birthdayDate!),
      })}
      handleAddClick={() => createEmptyTrainer()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainer}
      filter={(e: Trainer, search: string) => {
        const s = search.toLowerCase();
        return (
          (e.name?.toLowerCase().includes(s) ||
            e.email?.toLowerCase().includes(s) ||
            e.username?.toLowerCase().includes(s) ||
            e.specialization?.toLowerCase().includes(s)) ??
          false
        );
      }}
      fields={[
        {
          formattedName: "Trainer ID",
          fieldName: "trainerId",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "User ID",
          fieldName: "id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Email",
          fieldName: "email",
          canCopy: true,
        },
        {
          formattedName: "Username",
          fieldName: "username",
        },
        {
          formattedName: "Name",
          fieldName: "name",
        },
        {
          formattedName: "Specialization",
          fieldName: "specialization",
        },
        {
          formattedName: "Birthday Date",
          fieldName: "birthdayDate",
          customGeneration: (e: Trainer) => epochToDateTime(e.birthdayDate!),
        },
        {
          formattedName: "Role",
          fieldName: "role",
          capitalizeValue: true,
          smaller: true,
        },
        {
          formattedName: "Verified",
          fieldName: "verified",
          smaller: true,
        },
      ]}
      formFields={[
        {
          label: "Email",
          name: "email",
          required: true,
          type: "email",
        },
        {
          label: "Username",
          name: "username",
          required: true,
          type: "text",
        },
        {
          label: "Name",
          name: "name",
          required: true,
          type: "text",
        },
        {
          label: "Specialization",
          name: "specialization",
          required: true,
          type: "text",
        },
        {
          label: "Birthday Date",
          name: "birthdayDate",
          required: true,
          type: "datetime-local",
        },
      ]}
    />
  );
};

export default TrainerPage;
