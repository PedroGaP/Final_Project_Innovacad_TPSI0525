import { createMemo, createResource, Show } from "solid-js";
import type { Trainer } from "@/types/user";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { newPasswordEmail } from "@/components/NewPasswordEmail";
import EntityTable from "@/components/EntityTable";
import UserDocumentsManager from "@/components/DocumentManager";
import type { Class } from "@/types/class";
import { useUserDetails } from "@/providers/UserDetailsProvider";

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
    is_coordinator: false,
    coordinated_class_ids: {},
  }) as unknown as Trainer;

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";
  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";
  const pad = (n: number) => n.toString().padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
};

const validateTrainer = (
  trainer: Trainer,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  if (!trainer.name) errors.push("Name is required");
  if (!trainer.email) errors.push("Email is required");
  if (!trainer.username) errors.push("Username is required");
  if (!trainer.birthdayDate) errors.push("Birthday date is required");
  return { valid: errors.length === 0, errors };
};

const TrainerPage = () => {
  const api = useApi();

  const [trainersData, { mutate }] = createResource<Trainer[]>(
    api.fetchTrainers,
  );
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

      const currentClassIds = Object.keys(trainer.coordinated_class_ids) || [];
      const isCoordinator = currentClassIds.length > 0;

      if (original) {
        const changes: any = {};

        if (String(original.name) !== String(trainer.name))
          changes.name = String(trainer.name);
        if (String(original.email) !== String(trainer.email))
          changes.email = String(trainer.email);
        if (String(original.birthdayDate) !== String(trainer.birthdayDate))
          changes.birthday_date = epochToDateTime(trainer.birthdayDate!);

        const oldIds = Object.keys(original.coordinated_class_ids || {});
        const newIds = currentClassIds;

        console.log('DEBUG: oldIds:', oldIds);
        console.log('DEBUG: newIds:', newIds);

        const toAdd = newIds.filter((id) => !oldIds.includes(id));
        const toRemove = oldIds.filter((id) => !newIds.includes(id));

        console.log('DEBUG: toAdd:', toAdd);
        console.log('DEBUG: toRemove:', toRemove);

        if (toAdd.length > 0) changes.class_ids_to_add = toAdd;
        if (toRemove.length > 0) changes.class_ids_to_remove = toRemove;

        if (original.is_coordinator !== isCoordinator) {
          changes.is_coordinator = isCoordinator;
        }

        console.log('DEBUG: changes being sent:', changes);

        if (Object.keys(changes).length === 0) return;

        const idToUpdate = String(trainer.trainerId || trainer.id);
        await api.updateTrainer(idToUpdate, changes);

        mutate(
          (prev) =>
            prev?.map((u) => {
              if (u.trainerId === trainer.trainerId) {
                Object.assign(u, trainer, { is_coordinator: isCoordinator });
              }
              return u;
            }) || [],
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
          classIds: currentClassIds,
          isCoordinator: isCoordinator,
        };

        const newTrainer = await api.createTrainer(trainerObj);

        try {
          await api.sendEmail({
            to: trainer.email!,
            subject: "Welcome - Trainer Credentials",
            body: newPasswordEmail(tempPassword),
          });
        } catch (e) {
          console.error(e);
        }

        mutate((prev) => [...(prev || []), newTrainer]);
        toast.success("Trainer created successfully.");
      }
    } catch (error: any) {
      if (error.message !== "Validation failed")
        toast.error(error.message || "Failed to save");
    }
  };

  const confirmDelete = async (trainer: Trainer) => {
    await api.deleteTrainer(String(trainer.trainerId || trainer.id));
    mutate(
      (prev) => prev?.filter((u) => u.trainerId !== trainer.trainerId) || [],
    );
    toast.success("Trainer deleted");
  };

  const { user } = useUserDetails();
  const isTrainee = () => user()?.role === "trainee";

  return (
    <EntityTable<Trainer>
      title="Manage Trainers"
      data={trainersData}
      handleEditClick={(user) => ({
        ...user,
        birthdayDate: epochToDateTime(user.birthdayDate!),
        coordinated_class_ids: user.coordinated_class_ids || {},
      })}
      handleAddClick={() => createEmptyTrainer()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainer}
      filter={(e, s) =>
        e.name?.toLowerCase().includes(s.toLowerCase()) ?? false
      }
      fields={[
        {
          formattedName: "ID",
          fieldName: "trainer_id",
          canCopy: true,
          bigger: true,
          hidden: isTrainee(),
        },
        { formattedName: "Name", fieldName: "name" },
        { formattedName: "Email", fieldName: "email" },
        { formattedName: "Username", fieldName: "username" },
        {
          formattedName: "Birth Date",
          fieldName: "birthdayDate",
          customGeneration: (t) => epochToDateTime(t.birthdayDate!),
        },
        {
          formattedName: "Role",
          fieldName: "role",
          customGeneration: (t) => (
            <span
              class={`badge ${t.is_coordinator ? "badge-primary" : "badge-ghost"}`}
            >
              {t.is_coordinator ? "Coordinator" : "Trainer"}
            </span>
          ),
        },
        {
          formattedName: "Verified",
          fieldName: "verified",
        },
      ]}
      formFields={[
        { label: "Name", name: "name", required: true, type: "text" },
        { label: "Email", name: "email", required: true, type: "email" },
        { label: "Username", name: "username", required: true, type: "text" },
        {
          label: "Birth Date",
          name: "birthdayDate",
          required: true,
          type: "date",
        },
      ]}
      renderCustomFields={(formData, setFormData) => (
        <div class="flex flex-col gap-4 mt-2">
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text font-bold">Coordination Classes</span>
            </label>
            <div class="h-48 overflow-y-auto border rounded-lg p-2 bg-base-100">
              <Show
                when={classesData()}
                fallback={<span class="loading loading-spinner" />}
              >
                {classesData()?.map((cls) => (
                  <label class="label cursor-pointer justify-start gap-3 hover:bg-base-200 rounded px-2">
                    <input
                      type="checkbox"
                      class="checkbox checkbox-sm checkbox-primary"
                      checked={Object.keys(
                        formData.coordinated_class_ids || {},
                      ).includes(String(cls.class_id))}
                      onChange={(e) => {
                        const checked = e.currentTarget.checked;
                        const clsId = String(cls.class_id);
                        const current =
                          formData.coordinated_class_ids || {};

                        let updated: Record<string, string>;
                        if (checked) {
                          updated = { ...current, [clsId]: cls.identifier } as Record<string, string>;
                        } else {
                          const { [clsId]: _, ...rest } = current;
                          updated = rest as Record<string, string>;
                        }

                        setFormData((prev) => {
                          const newFormData = {
                            ...prev,
                            coordinated_class_ids: updated,
                            is_coordinator: Object.keys(updated).length > 0,
                          };
                          return newFormData as any;
                        });
                      }}
                    />
                    <span class="label-text">
                      {cls.identifier} - {cls.location}
                    </span>
                  </label>
                ))}
              </Show>
            </div>
            <label class="label">
              <span class="label-text-alt text-warning">
                Selecting classes will automatically promote this user to
                Coordinator.
              </span>
            </label>
          </div>

          <Show when={formData.id}>
            <div class="divider">Documents</div>
            <UserDocumentsManager userId={String(formData.id)} />
          </Show>
        </div>
      )}
    />
  );
};

export default TrainerPage;
