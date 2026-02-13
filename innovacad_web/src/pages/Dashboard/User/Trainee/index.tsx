import { createResource, Show } from "solid-js";
import type { Trainee } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";
import UserDocumentsManager from "@/components/DocumentManager";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import useI18n from "@/hooks/useL18N";

const { t } = useI18n();

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

const validateTrainee = (
  trainee: Trainee,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(trainee.name || "").trim();
  if (!name) errors.push(t("fields.required_name"));

  const email = String(trainee.email || "").trim();
  if (!email) {
    errors.push(t("fields.required_email"));
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push(t("fields.invalid_email"));
  }

  const username = String(trainee.username || "").trim();
  if (!username) {
    errors.push(t("fields.required_username"));
  } else if (username.length < 3) {
    errors.push(t("fields.length_username"));
  }

  const birthdayDate = String(trainee.birthdayDate || "").trim();
  if (!birthdayDate) errors.push(t("fields.required_birthday_date"));

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
    changes.birthdayDate = epochToDateTime(newTrainee.birthdayDate!);
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
        throw new Error(t("dashboard.users.trainers.validate_fail"));
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

        toast.success(t("dashboard.users.trainers.update_successful"));
      } else {
        const traineeObj = {
          name: String(trainee.name),
          email: String(trainee.email),
          birthdayDate: epochToDateTime(trainee.birthdayDate!),
          username: String(trainee.username),
          password: "T" + Math.random().toString(36).slice(-10) + "1@",
        };

        const newTrainee = await api.createTrainee(traineeObj);

        try {
          await api.sendEmail({
            to: trainee.email!,
            subject: t("dashboard.users.email_new_password_subject"),
            body: newPasswordEmail(traineeObj.password),
          });
        } catch (error) {
          console.error(
            `Something went wrong sending an email for ${trainee.email}`,
            error,
          );
          toast.error(t("dashboard.users.send_email_fail"));
        }

        mutate((prev) => [...(prev || []), newTrainee]);
        toast.success(t("dashboard.users.trainers.create_successful"));
      }
    } catch (error) {
      if (original) {
        if (error instanceof Error && error.message !== "Validation failed") {
          toast.error(t("dashboard.users.trainers.update_fail"));
        } else {
          toast.error(t("dashboard.users.trainers.create_fail"));
        }
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Trainee) => {
    try {
      await api.deleteTrainee(String(userToDelete.traineeId));
      mutate(
        (prev) =>
          prev?.filter((u) => u.traineeId !== userToDelete.traineeId) || [],
      );
      toast.success(t("dashboard.users.trainers.delete_successful"));
    } catch (e) {
      toast.error(t("dashboard.users.trainers.delete_fail"));
      throw e;
    }
  };

  const handleExport = async (trainee: Trainee) => {
    try {
      toast.loading(t("dashboard.users.trainers.pdf_generating"), {
        id: "export-loading",
      });

      await api.exportTraineeSheet(
        String(trainee.traineeId),
        String(trainee.name || "Trainee"),
      );

      toast.dismiss("export-loading");
      toast.success(t("dashboard.users.trainers.pdf_successful"));
    } catch (error: any) {
      toast.dismiss("export-loading");
      console.error(error);
      toast.error(t("dashboard.users.trainers.pdf_fail"));
    }
  };

  const { user } = useUserDetails();
  const isTrainee = () => user()?.role === "trainee";

  return (
    <EntityTable<Trainee>
      title={t("dashboard.users.trainers.title")}
      data={usersData}
      handleExportClick={handleExport}
      handleAddClick={() => createEmptyTrainee()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainee}
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDateTime(user.birthdayDate!),
      })}
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
          formattedName: "ID",
          fieldName: "traineeId",
          canCopy: true,
          smaller: true,
          hidden: isTrainee(),
        },
        {
          formattedName: t("general.name"),
          fieldName: "name",
        },
        {
          formattedName: t("general.email"),
          fieldName: "email",
          canCopy: true,
        },
        {
          formattedName: t("general.username"),
          fieldName: "username",
        },
        {
          formattedName: t("general.birthday_date"),
          fieldName: "birthdayDate",
          customGeneration: (e: Trainee) => {
            const d = epochToDateTime(e.birthdayDate!);
            return <span class="text-sm">{d}</span>;
          },
          smaller: true,
        },
        {
          formattedName: t("general.verified"),
          fieldName: "verified",
          smaller: true,
        },
      ]}
      formFields={[
        {
          label: t("general.name"),
          name: "name",
          required: true,
          type: "text",
        },
        {
          label: t("general.email"),
          name: "email",
          required: true,
          type: "email",
        },
        {
          label: t("general.username"),
          name: "username",
          required: true,
          type: "text",
        },
        {
          label: t("general.birthday_date"),
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
              <span>
                {t("dashboard.users.trainers.save_to_upload_documents")}
              </span>
            </div>
          }
        >
          <UserDocumentsManager userId={String(formData.id)} />
        </Show>
      )}
    />
  );
};

export default TraineePage;
