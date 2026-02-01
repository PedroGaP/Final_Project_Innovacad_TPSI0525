import { createResource, For, Show } from "solid-js";
import type { Trainer } from "@/types/user";
import { Module } from "@/types/module";
import { Class } from "@/types/class";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
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
    class_ids: [],
    coordinated_class_ids: [],
    is_coordinator: false,
    birthdayDate: "" as unknown as number,
    image: null,
    verified: false,
    session_token: "",
    toJson: () => "",
  }) as unknown as Trainer;

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";
  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";
  return date.toISOString().slice(0, 16);
};

const validateTrainer = (
  trainer: Trainer,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  if (!trainer.name?.trim()) errors.push("Name is required");
  if (!trainer.email?.trim()) errors.push("Email is required");
  if (!trainer.username?.trim()) errors.push("Username is required");
  if (!trainer.birthdayDate) errors.push("Birthday date is required");
  return { valid: errors.length === 0, errors };
};

const TrainerPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainer[]>(api.fetchTrainers);
  const [modulesData] = createResource<Module[]>(api.fetchModules);
  const [classesData] = createResource<Class[]>(api.fetchClasses);

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

        if (trainer.is_coordinator !== original.is_coordinator) {
          changedFields.is_coordinator = trainer.is_coordinator;
        }

        const newDate = epochToDateTime(trainer.birthdayDate!);
        const oldDate = epochToDateTime(original.birthdayDate!);
        if (newDate !== oldDate) changedFields.birthday_date = newDate;

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

        if (skillsToAdd.length > 0) changedFields.skills_to_add = skillsToAdd;
        if (skillsToRemoveIds.length > 0)
          changedFields.skills_to_remove = skillsToRemoveIds.join(",");

        const originalClasses = original.coordinated_class_ids || [];
        const currentClasses = trainer.coordinated_class_ids || [];

        const classesToAdd = currentClasses.filter(
          (id) => !originalClasses.includes(id),
        );
        const classesToRemove = originalClasses.filter(
          (id) => !currentClasses.includes(id),
        );

        if (classesToAdd.length > 0)
          changedFields.class_ids_to_add = classesToAdd;
        if (classesToRemove.length > 0)
          changedFields.class_ids_to_remove = classesToRemove;

        if (Object.keys(changedFields).length === 0) return;

        const updatedTrainerFromApi = await api.updateTrainer(
          String(trainer.trainerId),
          changedFields,
        );

        updatedTrainerFromApi.skills = [...trainer.skills];
        updatedTrainerFromApi.coordinated_class_ids = [
          ...(trainer.coordinated_class_ids || []),
        ];
        updatedTrainerFromApi.is_coordinator = trainer.is_coordinator;

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.trainerId === updatedTrainerFromApi.trainerId
                ? updatedTrainerFromApi
                : u,
            ) || [],
        );
        toast.success("Trainer updated successfully");
      } else {
        const generatedPassword =
          "T" + Math.random().toString(36).slice(-8) + "1@";

        const trainerObj = {
          name: trainer.name || "",
          email: trainer.email || "",
          username: trainer.username || "",
          birthdayDate: epochToDateTime(trainer.birthdayDate!),
          skills_to_add: trainer.skills || [],
          password: generatedPassword,
          is_coordinator: trainer.is_coordinator,
          class_ids: trainer.coordinated_class_ids,
        };

        const newTrainerFromApi = await api.createTrainer(trainerObj);

        newTrainerFromApi.skills = [...(trainer.skills || [])];
        newTrainerFromApi.coordinated_class_ids = [
          ...(trainer.coordinated_class_ids || []),
        ];
        newTrainerFromApi.is_coordinator = trainer.is_coordinator;

        mutate((prev) => [...(prev || []), newTrainerFromApi]);

        try {
          await api.sendEmail({
            to: trainerObj.email,
            subject: "Welcome to InnovAcad - Your Credentials",
            body: `Hello ${trainerObj.name},\n\nYour Trainer account has been created.\n\nUsername: ${trainerObj.username}\nPassword: ${generatedPassword}\n\nPlease login and change your password.`,
          });
          toast.success("Trainer created and email sent.");
        } catch (e) {
          console.error("Failed to send email", e);
          toast.success("Trainer created (Email failed to send).");
        }
      }
    } catch (error: any) {
      if (error.message !== "Validation failed") {
        console.error(error);
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

  const renderCustomFields = (formData: Trainer, setFormData: any) => {
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

    const toggleCoordinator = (e: any) => {
      setFormData((prev: Trainer) => ({
        ...prev,
        is_coordinator: e.target.checked,
      }));
    };

    const toggleClass = (classId: string) => {
      const currentClasses = formData.coordinated_class_ids || [];

      if (currentClasses.includes(classId)) {
        setFormData((prev: Trainer) => ({
          ...prev,
          coordinated_class_ids: prev.coordinated_class_ids?.filter(
            (id) => id !== classId,
          ),
        }));
      } else {
        setFormData((prev: Trainer) => ({
          ...prev,
          coordinated_class_ids: [
            ...(prev.coordinated_class_ids || []),
            classId,
          ],
        }));
      }
    };

    return (
      <div class="space-y-6 mt-6">
        {/* SKILLS SECTION */}
        <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm">
          <header class="mb-4 flex justify-between items-center">
            <div>
              <h3 class="text-lg font-bold">Trainer Skills</h3>
              <p class="text-xs opacity-60">
                Select modules and assign competence.
              </p>
            </div>
            <span class="badge badge-neutral">
              {formData.skills?.length || 0} Selected
            </span>
          </header>

          <div class="space-y-2 max-h-40 overflow-y-auto pr-2 custom-scrollbar">
            <For
              each={modulesData()}
              fallback={<span class="loading loading-dots loading-xs"></span>}
            >
              {(mod) => {
                const skill = () =>
                  formData.skills?.find((s) => s.module_id === mod.module_id);
                return (
                  <label
                    class={`flex items-center justify-between p-2 rounded-lg border transition-all cursor-pointer ${skill() ? "border-primary bg-primary/5" : "border-base-200 hover:bg-base-200"}`}
                  >
                    <div class="flex items-center gap-3">
                      <input
                        type="checkbox"
                        class="checkbox checkbox-primary checkbox-sm"
                        checked={!!skill()}
                        onChange={() => toggleSkill(mod.module_id!)}
                      />
                      <span class="text-sm font-medium">{mod.name}</span>
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

        {/* COORDINATOR SECTION */}
        <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm">
          <header class="mb-4 flex justify-between items-center">
            <div>
              <h3 class="text-lg font-bold">Coordinator Role</h3>
              <p class="text-xs opacity-60">Is this trainer a coordinator?</p>
            </div>
            <input
              type="checkbox"
              class="toggle toggle-primary"
              checked={!!formData.is_coordinator}
              onChange={toggleCoordinator}
            />
          </header>

          <Show when={formData.is_coordinator}>
            <div class="divider text-xs opacity-50 my-2">
              Coordinated Classes
            </div>
            <div class="space-y-2 max-h-40 overflow-y-auto pr-2 custom-scrollbar">
              <For
                each={classesData()}
                fallback={
                  <span class="text-xs opacity-50">No classes available</span>
                }
              >
                {(cls) => (
                  <label
                    class={`flex items-center gap-3 p-2 rounded-lg border transition-all cursor-pointer ${formData.coordinated_class_ids?.includes(cls.class_id!) ? "border-primary bg-primary/5" : "border-base-200 hover:bg-base-200"}`}
                  >
                    <input
                      type="checkbox"
                      class="checkbox checkbox-xs checkbox-primary"
                      checked={formData.coordinated_class_ids?.includes(
                        cls.class_id!,
                      )}
                      onChange={() => toggleClass(cls.class_id!)}
                    />
                    <span class="text-sm font-medium">
                      {cls.identifier || cls.class_id?.substring(0, 8)}
                    </span>
                    <span class="text-xs opacity-50 ml-auto">
                      {cls.course_id || "No Course"}
                    </span>
                  </label>
                )}
              </For>
            </div>
          </Show>
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
      renderCustomFields={renderCustomFields}
      filter={(e, search) => {
        const s = search.toLowerCase();
        const matchesSkills = e.skills?.some((sk) =>
          sk.module_id.toLowerCase().includes(s),
        );
        return (
          e.name?.toLowerCase().includes(s) ||
          e.email?.toLowerCase().includes(s) ||
          e.username?.toLowerCase().includes(s) ||
          matchesSkills ||
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
        { formattedName: "Name", fieldName: "name", bigger: true },
        { formattedName: "Email", fieldName: "email", canCopy: true },
        { formattedName: "Username", fieldName: "username" },
        {
          formattedName: "Role",
          fieldName: "role",
          capitalizeValue: true,
          smaller: true,
        },
        {
          formattedName: "Coordinator",
          fieldName: "is_coordinator",
          customGeneration: (e) =>
            e.is_coordinator ? (
              <span class="badge badge-primary badge-sm gap-1">
                Yes{" "}
                <span class="opacity-50 text-[10px]">
                  ({e.coordinated_class_ids?.length || 0})
                </span>
              </span>
            ) : (
              <span class="badge badge-ghost badge-sm opacity-50">No</span>
            ),
        },
        {
          formattedName: "Skills",
          fieldName: "skills",
          customGeneration: (e) => (
            <span class="badge badge-ghost">{e.skills?.length || 0}</span>
          ),
        },
      ]}
      formFields={[
        { label: "Name", name: "name", required: true, type: "text" },
        { label: "Email", name: "email", required: true, type: "email" },
        { label: "Username", name: "username", required: true, type: "text" },
        {
          label: "Birthday",
          name: "birthdayDate",
          required: true,
          type: "datetime-local",
        },
      ]}
    />
  );
};

export default TrainerPage;
