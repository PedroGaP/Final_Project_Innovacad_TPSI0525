import { createMemo, createResource, createSignal, For, Show } from "solid-js";
import { Icon } from "@/components/Icon";
import type { Trainer } from "@/types/user";
import capitalize from "@/utils/capitalize";
import CopyToClipboard from "@/components/CopyToClipboard";
import { useApi } from "@/hooks/useApi";
import { Toaster } from "solid-toast";
import toast from "solid-toast";
import ModalEdit from "@/components/Modal/Edit";
import ModalDelete from "@/components/Modal/Delete";
import { newPasswordEmail } from "@/components/NewPasswordEmail";

const PAGE_SIZE = 10;

const epochToDate = (epoch: number | string): string => {
  if (!epoch) return "";
  const date = new Date(Number(epoch));
  return date.toISOString().split("T")[0];
};

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
    birthdayDate: "" as unknown as number,
    image: "",
    verified: false,
    session_token: "",
  }) as Trainer;

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
  role?: string;
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

  if (String(oldTrainer.role) !== String(newTrainer.role)) {
    changes.role = String(newTrainer.role);
  }

  if (String(oldTrainer.specialization) !== String(newTrainer.specialization)) {
    changes.specialization = String(newTrainer.specialization);
  }

  return changes;
};

const TrainerPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainer[]>(api.fetchTrainers);
  const [originalTrainer, setOriginalTrainer] = createSignal<Trainer | null>(
    null,
  );

  const [page, setPage] = createSignal(1);
  const [search, setSearch] = createSignal("");

  const [editingUser, setEditingUser] = createSignal<Trainer | null>(null);
  const [deletingUser, setDeletingUser] = createSignal<Trainer | null>(null);

  const filteredUsers = createMemo(() => {
    const q = search().toLowerCase();
    const list = usersData() || [];
    return list.filter(
      (u: Trainer) =>
        String(u.name).toLowerCase().includes(q) ||
        String(u.email).toLowerCase().includes(q),
    );
  });

  const totalPages = createMemo(() =>
    Math.ceil(filteredUsers().length / PAGE_SIZE),
  );

  const paginatedUsers = createMemo(() => {
    const start = (page() - 1) * PAGE_SIZE;
    return filteredUsers().slice(start, start + PAGE_SIZE);
  });

  const handleSaveTrainer = async (trainer: Trainer) => {
    try {
      const validation = validateTrainer(trainer);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      const isEditing =
        trainer.trainerId && String(trainer.trainerId).length > 0;

      if (isEditing) {
        const original = originalTrainer();
        if (!original) {
          throw new Error("Original trainer data not found");
        }

        const changedFields = getChangedFields(original, trainer);

        if (Object.keys(changedFields).length === 0) {
          toast.success("No changes detected");
          setEditingUser(null);
          return;
        }

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
        const tempPassword = "T" + Math.random().toString(36).slice(-10) + "1@";

        const newTrainer = await api.createTrainer({
          name: String(trainer.name),
          email: String(trainer.email),
          username: String(trainer.username),
          password: tempPassword,
          birthdayDate: String(trainer.birthdayDate),
          specialization: String(trainer.specialization),
        });

        try {
          await api.sendEmail({
            to: trainer.email!,
            subject: "Account Creation - New Password Innovacad",
            body: newPasswordEmail(tempPassword),
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

      setEditingUser(null);
      setOriginalTrainer(null);
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainer");
      }
      throw error;
    }
  };

  const confirmDelete = async () => {
    const userToDelete = deletingUser();
    if (!userToDelete) return;

    try {
      await api.deleteTrainer(String(userToDelete.trainerId));

      mutate(
        (prev) =>
          prev?.filter((u) => u.trainerId !== userToDelete.trainerId) || [],
      );
      toast.success("Trainer deleted successfully");
      setDeletingUser(null);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to delete trainer",
      );
      throw error;
    }
  };

  const handleEditClick = (user: Trainer) => {
    const dateStr = epochToDate(user.birthdayDate!);
    const trainerClone = { ...user, birthdayDate: dateStr } as any as Trainer;
    setOriginalTrainer(trainerClone);
    setEditingUser(trainerClone);
  };

  const handleAddClick = () => {
    setOriginalTrainer(null);
    setEditingUser(createEmptyTrainer());
  };

  return (
    <div class="card bg-base-100 shadow h-full flex flex-col">
      <Toaster />
      <div class="card-body gap-4 flex-1 flex flex-col overflow-hidden min-h-0 p-6">
        <div class="flex justify-between items-center shrink-0">
          <h2 class="card-title">Trainers</h2>

          <button class="btn btn-primary btn-sm" onClick={handleAddClick}>
            <Icon name="Plus" size={16} />
            Add Trainer
          </button>
        </div>

        <div class="shrink-0">
          <input
            type="text"
            placeholder="Search trainers..."
            class="input input-bordered input-sm w-full max-w-xs"
            onInput={(e) => {
              setSearch(e.currentTarget.value);
              setPage(1);
            }}
          />
        </div>

        <div class="overflow-auto flex-1 border border-base-200 rounded-lg">
          <table class="table table-zebra table-pin-rows table-fixed w-full">
            <thead>
              <tr class="z-10">
                <th class="w-52 bg-base-100">Trainer ID</th>
                <th class="w-52 bg-base-100">User ID</th>
                <th class="w-32 bg-base-100">Name</th>
                <th class="w-48 bg-base-100">Email</th>
                <th class="w-32 bg-base-100">Username</th>
                <th class="w-24 bg-base-100">Role</th>
                <th class="w-28 text-right bg-base-100">Actions</th>
              </tr>
            </thead>

            <tbody>
              <For each={paginatedUsers()}>
                {(user) => (
                  <tr>
                    <td class="w-52">
                      <CopyToClipboard val={user.trainerId!}>
                        <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
                          {user.trainerId}
                        </div>
                      </CopyToClipboard>
                    </td>
                    <td class="w-52">
                      <CopyToClipboard val={user.id!}>
                        <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
                          {user.id}
                        </div>
                      </CopyToClipboard>
                    </td>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>{user.username}</td>
                    <td>
                      <span class="badge badge-outline">
                        {!!user.role ? capitalize(user.role) : "N/A"}
                      </span>
                    </td>
                    <td class="text-right space-x-2">
                      <button
                        class="btn btn-ghost btn-sm"
                        onClick={() => handleEditClick(user)}
                      >
                        <Icon name="Pencil" size={16} />
                      </button>

                      <button
                        class="btn btn-ghost btn-sm text-error"
                        onClick={() => setDeletingUser(user)}
                      >
                        <Icon name="Trash" size={16} />
                      </button>
                    </td>
                  </tr>
                )}
              </For>
            </tbody>
          </table>
        </div>

        <div class="flex justify-between items-center shrink-0 pt-2">
          <span class="text-sm opacity-60">
            Page {page()} of {totalPages()}
          </span>

          <div class="join">
            <button
              class="join-item btn btn-sm"
              disabled={page() === 1}
              onClick={() => setPage(page() - 1)}
            >
              «
            </button>

            <For each={Array.from({ length: totalPages() })}>
              {(_, i) => (
                <button
                  class="join-item btn btn-sm"
                  classList={{ "btn-active": page() === i() + 1 }}
                  onClick={() => setPage(i() + 1)}
                >
                  {i() + 1}
                </button>
              )}
            </For>

            <button
              class="join-item btn btn-sm"
              disabled={page() === totalPages()}
              onClick={() => setPage(page() + 1)}
            >
              »
            </button>
          </div>
        </div>
      </div>

      <Show when={editingUser()}>
        {(u) => (
          <ModalEdit<Trainer>
            value={u()}
            setValue={setEditingUser}
            onSave={handleSaveTrainer}
            onCancel={() => {
              setEditingUser(null);
              setOriginalTrainer(null);
            }}
            title={originalTrainer() ? "Edit Trainer" : "Add Trainer"}
            disabledFields={
              originalTrainer() ? ["email", "username", "trainerId"] : []
            }
          />
        )}
      </Show>

      <Show when={deletingUser()}>
        {(u) => (
          <ModalDelete<Trainer>
            value={u}
            setValue={setDeletingUser}
            onConfirm={confirmDelete}
            onCancel={() => setDeletingUser(null)}
            title="Delete Trainer"
            description="Are you sure you want to delete this trainer? This action cannot be undone."
          />
        )}
      </Show>
    </div>
  );
};

export default TrainerPage;
