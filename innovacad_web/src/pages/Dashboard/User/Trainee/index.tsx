import { createResource } from "solid-js";
import type { Trainee } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";

const createEmptyTrainee = (): Trainee =>
  ({
    id: "",
    username: "",
    email: "",
    name: "",
    role: "trainee",
    traineeId: "",
    token: "",
    birthdayDate: "",
    image: null,
    verified: false,
    session_token: "",
  }) as unknown as Trainee;

const epochToDate = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";

  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";

  return date.toISOString().split("T")[0];
};

const validateTrainee = (
  trainee: Trainee,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(trainee.name || "").trim();
  if (!name) {
    errors.push("Name is required");
  }

  const email = String(trainee.email || "").trim();
  if (!email) {
    errors.push("Email is required");
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push("Email is invalid");
  }

  const username = String(trainee.username || "").trim();
  if (!username) {
    errors.push("Username is required");
  } else if (username.length < 3) {
    errors.push("Username must be at least 3 characters");
  }

  const birthdayDate = String(trainee.birthdayDate || "").trim();
  if (!birthdayDate) {
    errors.push("Birthday date is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldTrainee: Trainee,
  newTrainee: Trainee,
): {
  name?: string;
  email?: string;
  username?: string;
  birthdayDate?: string;
} => {
  const changes: any = {};

  if (String(oldTrainee.name) !== String(newTrainee.name)) {
    changes.name = String(newTrainee.name);
  }

  if (String(oldTrainee.email) !== String(newTrainee.email)) {
    changes.email = String(newTrainee.email);
  }

  if (String(oldTrainee.username) !== String(newTrainee.username)) {
    changes.username = String(newTrainee.username);
  }

  if (String(oldTrainee.birthdayDate) !== String(newTrainee.birthdayDate)) {
    changes.birthdayDate = String(newTrainee.birthdayDate);
  }

  return changes;
};

const TraineePage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainee[]>(api.fetchTrainees);

  const handleSaveTrainee = async (
    trainee: Trainee,
    original: Trainee | null,
  ) => {
    try {
      const validation = validateTrainee(trainee);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, trainee);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateTrainee(String(trainee.traineeId), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.traineeId === trainee.traineeId ? trainee : u,
            ) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Trainee updated successfully (${changedFieldNames})`);
      } else {
        const traineeObj = {
          name: String(trainee.name),
          email: String(trainee.email),
          birthdayDate: String(trainee.birthdayDate),
          username: String(trainee.username),
          password: "T" + Math.random().toString(36).slice(-10) + "1@",
        };

        const newTrainee = await api.createTrainee(traineeObj);

        try {
          await api.sendEmail({
            to: trainee.email!,
            subject: "Account Creation - New Password Innovacad",
            body: newPasswordEmail(traineeObj.password),
          });
        } catch (error) {
          console.error(
            `Something went wrong sending an email for ${trainee.email}`,
            error,
          );
        }

        mutate((prev) => [...(prev || []), newTrainee]);
        toast.success(
          "Trainee created successfully. A temporary password has been sent to their email.",
        );
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainee");
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Trainee) => {
    await api.deleteTrainee(String(userToDelete.traineeId));
    mutate(
      (prev) =>
        prev?.filter((u) => u.traineeId !== userToDelete.traineeId) || [],
    );
  };

  return (
    <EntityTable<Trainee>
      title="Manage Trainees"
      data={usersData}
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDate(user.birthdayDate!),
      })}
      handleAddClick={() => createEmptyTrainee()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainee}
      filter={(e: Trainee, search: string) => {
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
          formattedName: "Trainee ID",
          fieldName: "traineeId",
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
          formattedName: "Birthday Date",
          fieldName: "birthdayDate",
          customGeneration: (e: Trainee) => epochToDate(e.birthdayDate!),
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
          customGeneration: (e: Trainee) => (
            <div
              class="badge"
              classList={{
                "badge-warning": !e.verified,
                "badge-success": e.verified,
              }}
            >
              {e.verified ? "Yes" : "No"}
            </div>
          ),
        },
      ]}
    />
  );
};

export default TraineePage;
