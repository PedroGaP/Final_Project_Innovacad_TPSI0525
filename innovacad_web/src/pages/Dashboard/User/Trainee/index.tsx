import { createResource, Show } from "solid-js";
import type { Trainee } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";
import UserDocumentsManager from "@/components/DocumentManager";

// --- Funções Auxiliares ---

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

  // Retorna YYYY-MM-DD para compatibilidade com input type="date"
  return `${yyyy}-${mm}-${dd}`;
};

const validateTrainee = (
  trainee: Trainee,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(trainee.name || "").trim();
  if (!name) errors.push("Name is required");

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
  if (!birthdayDate) errors.push("Birthday date is required");

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

// --- Componente Principal ---

const TraineePage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainee[]>(api.fetchTrainees);

  // Lógica de Criar/Editar
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
        // --- UPDATE ---
        const changedFields = getChangedFields(original, trainee);
        if (Object.keys(changedFields).length === 0) return;

        await api.updateTrainee(String(trainee.traineeId), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.traineeId === trainee.traineeId ? trainee : u,
            ) || [],
        );

        toast.success(`Trainee updated successfully`);
      } else {
        // --- CREATE ---
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
            subject: "Account Creation - New Password Innovacad",
            body: newPasswordEmail(traineeObj.password),
          });
        } catch (error) {
          console.error(
            `Something went wrong sending an email for ${trainee.email}`,
            error,
          );
          toast.error("User created but failed to send email.");
        }

        mutate((prev) => [...(prev || []), newTrainee]);
        toast.success(
          "Trainee created successfully. Credentials sent via email.",
        );
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainee");
      }
      throw error;
    }
  };

  // Lógica de Apagar
  const confirmDelete = async (userToDelete: Trainee) => {
    await api.deleteTrainee(String(userToDelete.traineeId));
    mutate(
      (prev) =>
        prev?.filter((u) => u.traineeId !== userToDelete.traineeId) || [],
    );
    toast.success("Trainee deleted");
  };

  // Lógica de Exportar PDF
  const handleExport = async (trainee: Trainee) => {
    try {
      toast.loading("Generating PDF...", { id: "export-loading" });

      await api.exportTraineeSheet(
        String(trainee.traineeId),
        String(trainee.name || "Trainee"),
      );

      toast.dismiss("export-loading");
      toast.success("Download started!");
    } catch (error: any) {
      toast.dismiss("export-loading");
      console.error(error);
      toast.error(error.message || "Failed to export document.");
    }
  };

  return (
    <EntityTable<Trainee>
      title="Manage Trainees"
      data={usersData}
      // Ações Principais
      handleExportClick={handleExport}
      handleAddClick={() => createEmptyTrainee()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainee}
      // Preparação de dados para edição
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDateTime(user.birthdayDate!),
      })}
      // Filtro de pesquisa
      filter={(e: Trainee, search: string) => {
        const s = search.toLowerCase();
        return (
          (e.name?.toLowerCase().includes(s) ||
            e.email?.toLowerCase().includes(s) ||
            e.username?.toLowerCase().includes(s)) ??
          false
        );
      }}
      // Configuração das Colunas
      fields={[
        {
          formattedName: "ID",
          fieldName: "traineeId",
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
          customGeneration: (e: Trainee) => {
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
      // Configuração do Formulário
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
      // Injeção da Gestão de Documentos no Modal
      renderCustomFields={(formData) => (
        <Show
          when={formData.id}
          fallback={
            <div class="alert alert-info text-xs mt-4">
              <span>Save the trainee first to upload documents.</span>
            </div>
          }
        >
          {/* Passamos o ID do User (formData.id) para a gestão de ficheiros */}
          <UserDocumentsManager userId={String(formData.id)} />
        </Show>
      )}
    />
  );
};

export default TraineePage;
