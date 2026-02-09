import { createResource, Show } from "solid-js";
import type { Trainer } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";
import UserDocumentsManager from "@/components/DocumentManager";

const createEmptyTrainer = (): Trainer =>
  ({
    id: "",
    username: "",
    email: "",
    name: "",
    role: "trainer",
    trainerId: "",
    token: "",
    birthdayDate: "",
    image: null,
    verified: false,
    session_token: "",
    skills: [],
  }) as unknown as Trainer;

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";

  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";

  const pad = (n: number) => n.toString().padStart(2, "0");
  const yyyy = date.getFullYear();
  const mm = pad(date.getMonth() + 1);
  const dd = pad(date.getDate());

  return `${yyyy}-${mm}-${dd}`;
};

const validateTrainer = (
  trainer: Trainer,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(trainer.name || "").trim();
  if (!name) errors.push("Name is required");

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

  if (!trainer.birthdayDate) errors.push("Birthday date is required");

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
  birthday_date?: string;
} => {
  const changes: any = {};

  if (String(oldTrainer.name) !== String(newTrainer.name)) {
    changes.name = String(newTrainer.name);
  }

  if (String(oldTrainer.email) !== String(newTrainer.email)) {
    changes.email = String(newTrainer.email);
  }

  if (String(oldTrainer.birthdayDate) !== String(newTrainer.birthdayDate)) {
    changes.birthday_date = epochToDateTime(newTrainer.birthdayDate!);
  }

  return changes;
};


const TrainerPage = () => {
  const api = useApi();

  const [trainersData, { mutate }] = createResource<Trainer[]>(
    api.fetchTrainers,
  );

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

        const idToUpdate = String(trainer.trainerId || trainer.id);

        await api.updateTrainer(idToUpdate, changedFields);

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.trainerId === trainer.trainerId || u.id === trainer.id
                ? trainer
                : u,
            ) || [],
        );

        toast.success(`Trainer updated successfully`);
      } else {
        const tempPassword = "T" + Math.random().toString(36).slice(-10) + "1@";

        const trainerObj = {
          name: String(trainer.name),
          email: String(trainer.email),
          username: String(trainer.username),
          birthdayDate: epochToDateTime(trainer.birthdayDate!),
          password: tempPassword,
        };

        const newTrainer = await api.createTrainer(trainerObj);

        try {
          await api.sendEmail({
            to: trainer.email!,
            subject: "Welcome to Innovacad - Trainer Credentials",
            body: newPasswordEmail(tempPassword),
          });
        } catch (error) {
          console.error(`Email fail for ${trainer.email}`, error);
          toast.error("Trainer created but failed to send email.");
        }

        mutate((prev) => [...(prev || []), newTrainer]);
        toast.success("Trainer created successfully. Credentials sent.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainer");
      }
      throw error;
    }
  };

  const confirmDelete = async (trainerToDelete: Trainer) => {
    const idToDelete = String(trainerToDelete.trainerId || trainerToDelete.id);
    await api.deleteTrainer(idToDelete);

    mutate(
      (prev) => prev?.filter((u) => (u.trainerId || u.id) !== idToDelete) || [],
    );
    toast.success("Trainer deleted");
  };

  const handleExport = async (trainer: Trainer) => {
    try {
      toast.loading("Generating Trainer Sheet...", { id: "exp-trainer" });

      const idToExport = String(trainer.trainerId || trainer.id);

      await api.exportTrainerSheet(
        idToExport,
        String(trainer.name || "Trainer"),
      );

      toast.dismiss("exp-trainer");
      toast.success("Download started!");
    } catch (error: any) {
      toast.dismiss("exp-trainer");
      console.error(error);
      toast.error(error.message || "Failed to export document.");
    }
  };

  return (
    <EntityTable<Trainer>
      title="Manage Trainers"
      data={trainersData}
      handleExportClick={handleExport}
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
            e.username?.toLowerCase().includes(s)) ??
          false
        );
      }}
      fields={[
        {
          formattedName: "Trainer ID",
          fieldName: "trainerId",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Name",
          fieldName: "name",
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
          formattedName: "Birth Date",
          fieldName: "birthdayDate",
          customGeneration: (e: Trainer) => {
            const d = epochToDateTime(e.birthdayDate!);
            return <span class="text-sm">{d}</span>;
          },
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
          label: "Name",
          name: "name",
          required: true,
          type: "text",
        },
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
          label: "Birthday Date",
          name: "birthdayDate",
          required: true,
          type: "date",
        },
      ]}
      renderCustomFields={(formData) => (
        <Show
          when={formData.id}
          fallback={
            <div class="alert alert-info text-xs mt-4">
              <span>Save the trainer first to upload documents.</span>
            </div>
          }
        >
          <UserDocumentsManager userId={String(formData.id)} />
        </Show>
      )}
    />
  );
};

export default TrainerPage;
