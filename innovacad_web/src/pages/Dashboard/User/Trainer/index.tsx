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
    skills: [],
    birthdayDate: "" as unknown as number,
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

  const oldIds = oldTrainer.skills.map((s) => s.module_id);
  const newIds = newTrainer.skills.map((s) => s.module_id);

  const toAdd = newTrainer.skills.filter((ns) => {
    const os = oldTrainer.skills.find((o) => o.module_id === ns.module_id);
    return !os || os.competence_level !== ns.competence_level;
  });

  const toRemove = oldIds.filter((id) => !newIds.includes(id));

  if (toAdd.length > 0) changes.skills_to_add = toAdd;
  if (toRemove.length > 0) changes.skills_to_remove = toRemove.join(",");

  return changes;
};

const TrainerPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainer[]>(api.fetchTrainers);
  const [modulesData] = createResource<Module[]>(api.fetchModules);

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
        const changedFields: any = {};

        if (trainer.name !== original.name) changedFields.name = trainer.name;
        if (trainer.email !== original.email)
          changedFields.email = trainer.email;
        if (trainer.username !== original.username)
          changedFields.username = trainer.username;
        if (trainer.birthdayDate !== original.birthdayDate) {
          changedFields.birthday_date = epochToDateTime(trainer.birthdayDate!);
        }

        const originalSkills = original.skills || [];
        const currentSkills = trainer.skills || [];

        const skillsToAdd = currentSkills.filter((curr) => {
          const orig = originalSkills.find(
            (o) => o.module_id === curr.module_id,
          );
          return (
            !orig ||
            Number(orig.competence_level) !== Number(curr.competence_level)
          );
        });

        const skillsToRemoveIds = originalSkills
          .filter(
            (orig) =>
              !currentSkills.some((curr) => curr.module_id === orig.module_id),
          )
          .map((s) => s.module_id);

        const skillsToRemove =
          skillsToRemoveIds.length > 0
            ? skillsToRemoveIds.join(",")
            : undefined;

        if (skillsToAdd.length > 0) changedFields.skills_to_add = skillsToAdd;
        if (skillsToRemove) changedFields.skills_to_remove = skillsToRemove;

        if (Object.keys(changedFields).length === 0) return;

        const updatedTrainer = await api.updateTrainer(
          String(trainer.trainerId),
          changedFields,
        );

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.trainerId === updatedTrainer.trainerId ? updatedTrainer : u,
            ) || [],
        );

        toast.success("Trainer updated successfully");
      } else {
        const trainerObj = {
          name: trainer.name,
          email: trainer.email,
          username: trainer.username,
          birthday_date: epochToDateTime(trainer.birthdayDate!),
          skills_to_add: trainer.skills,
          password: "T" + Math.random().toString(36).slice(-10) + "1@",
        };

        const newTrainer = await api.createTrainer(trainerObj);
        mutate((prev) => [...(prev || []), newTrainer]);
        toast.success("Trainer created successfully.");
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

  const renderSkillsManager = (formData: Trainer, setFormData: any) => {
    console.log(formData.skills);

    const toggleSkill = (moduleId: string) => {
      const current = formData.skills || [];
      const exists = current.find((s) => s.module_id === moduleId);

      if (exists) {
        setFormData((prev: Trainer) => ({
          ...prev,
          skills: prev.skills.filter((s) => s.module_id !== moduleId),
        }));
      } else {
        setFormData((prev: Trainer) => ({
          ...prev,
          skills: [
            ...(prev.skills || []),
            { module_id: moduleId, competence_level: 1 },
          ],
        }));
      }
    };

    const updateLevel = (moduleId: string, level: number) => {
      setFormData((prev: Trainer) => ({
        ...prev,
        skills: prev.skills.map((s) =>
          s.module_id === moduleId ? { ...s, competence_level: level } : s,
        ),
      }));
    };

    return (
      <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm mt-6">
        <header class="mb-4">
          <h3 class="text-lg font-bold">Trainer Skills</h3>
          <p class="text-xs opacity-60">
            Select modules and assign competence level.
          </p>
        </header>

        <div class="space-y-2 max-h-60 overflow-y-auto pr-2">
          <For
            each={modulesData()}
            fallback={<span class="loading loading-dots loading-xs"></span>}
          >
            {(mod) => {
              const skill = () =>
                formData.skills?.find((s) => s.module_id === mod.module_id);
              return (
                <label class="flex items-center justify-between p-2 rounded-lg border border-base-200 hover:bg-base-200 cursor-pointer">
                  <div class="flex items-center gap-3">
                    <input
                      type="checkbox"
                      class="checkbox checkbox-primary checkbox-sm"
                      checked={!!skill()}
                      onChange={() => toggleSkill(mod.module_id!)}
                    />
                    <span class="text-sm">{mod.name}</span>
                  </div>

                  <Show when={skill()}>
                    <select
                      class="select select-bordered select-xs"
                      value={skill()?.competence_level}
                      onClick={(e) => e.stopPropagation()}
                      onChange={(e) =>
                        updateLevel(
                          mod.module_id!,
                          parseInt(e.currentTarget.value),
                        )
                      }
                    >
                      <option value={1}>Básico</option>
                      <option value={2}>Expert</option>
                    </select>
                  </Show>
                </label>
              );
            }}
          </For>
        </div>
      </div>
    );
  };

  return (
    <EntityTable<Trainer>
      title="Manage Trainers"
      data={usersData}
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDateTime(user.birthdayDate!),
      })}
      handleAddClick={() => createEmptyTrainer()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainer}
      renderCustomFields={renderSkillsManager}
      filter={(e, search) => {
        const s = search.toLowerCase();
        const matchesSkills = e.skills?.some((sk) =>
          sk.module_id.toLowerCase().includes(s),
        );
        return (
          e.name?.toLowerCase().includes(s) ||
          e.email?.toLowerCase().includes(s) ||
          matchesSkills ||
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
