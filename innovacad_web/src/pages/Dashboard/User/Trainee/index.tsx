import { createMemo, createResource, createSignal, For, Show } from "solid-js";
import { Icon } from "@/components/Icon";
import type { Trainee } from "@/types/user";
import CopyToClipboard from "@/components/CopyToClipboard";
import capitalize from "@/utils/capitalize";
import { useApi } from "@/hooks/useApi";
import { Toaster } from "solid-toast";
import toast from "solid-toast";
import ModalEdit from "@/components/Modal/Edit";
import ModalDelete from "@/components/Modal/Delete";
import { newPasswordEmail } from "@/components/NewPasswordEmail";

const PAGE_SIZE = 10;

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
  if (!epoch) return "";
  const date = new Date(Number(epoch));
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
  const [originalTrainee, setOriginalTrainee] = createSignal<Trainee | null>(
    null,
  );

  const [page, setPage] = createSignal(1);
  const [search, setSearch] = createSignal("");

  const [editingUser, setEditingUser] = createSignal<Trainee | null>(null);
  const [deletingUser, setDeletingUser] = createSignal<Trainee | null>(null);

  const filteredUsers = createMemo(() => {
    const q = search().toLowerCase();
    const list = usersData() || [];
    return list.filter(
      (u: Trainee) =>
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

  const handleSaveTrainee = async (trainee: Trainee) => {
    try {
      const validation = validateTrainee(trainee);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      const isEditing =
        trainee.traineeId && String(trainee.traineeId).length > 0;

      if (isEditing) {
        const original = originalTrainee();
        if (!original) {
          throw new Error("Original trainee data not found");
        }

        const changedFields = getChangedFields(original, trainee);

        if (Object.keys(changedFields).length === 0) {
          toast.success("No changes detected");
          setEditingUser(null);
          return;
        }

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
        const tempPassword = "T" + Math.random().toString(36).slice(-10) + "1@";

        const newTrainee = await api.createTrainee({
          name: String(trainee.name),
          email: String(trainee.email),
          username: String(trainee.username),
          password: tempPassword,
          birthdayDate: String(trainee.birthdayDate),
        });

        try {
          await api.sendEmail({
            to: trainee.email!,
            subject: "Account Creation - New Password Innovacad",
            body: newPasswordEmail(tempPassword),
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

      setEditingUser(null);
      setOriginalTrainee(null);
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save trainee");
      }
      throw error;
    }
  };

  const confirmDelete = async () => {
    const userToDelete = deletingUser();
    if (!userToDelete) return;

    try {
      await api.deleteTrainee(String(userToDelete.traineeId));

      mutate(
        (prev) =>
          prev?.filter((u) => u.traineeId !== userToDelete.traineeId) || [],
      );
      toast.success("Trainee deleted successfully");
      setDeletingUser(null);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to delete trainee",
      );
      throw error;
    }
  };

  const handleEditClick = (user: Trainee) => {
    const dateStr = epochToDate(user.birthdayDate!);
    const traineeWithDateStr = {
      ...user,
      birthdayDate: dateStr,
    } as any as Trainee;

    setOriginalTrainee(traineeWithDateStr);
    setEditingUser(traineeWithDateStr);
  };

  const handleAddClick = () => {
    setOriginalTrainee(null);
    setEditingUser(createEmptyTrainee());
  };

  return (
    <div class="card bg-base-100 shadow h-full flex flex-col">
      <Toaster />
      <div class="card-body gap-4 flex-1 flex flex-col overflow-hidden min-h-0 p-6">
        <div class="flex justify-between items-center shrink-0">
          <h2 class="card-title">Trainees</h2>
          <button class="btn btn-primary btn-sm" onClick={handleAddClick}>
            <Icon name="Plus" size={16} />
            Add Trainee
          </button>
        </div>

        <div class="shrink-0">
          <input
            type="text"
            placeholder="Search trainees..."
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
                {" "}
                <th class="w-52 bg-base-100">Trainee ID</th>
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
                      <CopyToClipboard val={String(user.traineeId)}>
                        <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
                          {user.traineeId}
                        </div>
                      </CopyToClipboard>
                    </td>
                    <td class="w-52">
                      <CopyToClipboard val={String(user.id || "")}>
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
                        {!!user.role ? capitalize(String(user.role)) : "N/A"}
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
          <ModalEdit<Trainee>
            value={u()}
            setValue={setEditingUser}
            onSave={handleSaveTrainee}
            onCancel={() => {
              setEditingUser(null);
              setOriginalTrainee(null);
            }}
            title={originalTrainee() ? "Edit Trainee" : "Add Trainee"}
            disabledFields={originalTrainee() ? ["email", "username"] : []}
          />
        )}
      </Show>

      <Show when={deletingUser()}>
        {(u) => (
          <ModalDelete<Trainee>
            value={u}
            setValue={setDeletingUser}
            onConfirm={confirmDelete}
            onCancel={() => setDeletingUser(null)}
            title="Delete Trainee"
            description="Are you sure you want to delete this trainee? This action cannot be undone."
          />
        )}
      </Show>
    </div>
  );
};

export default TraineePage;
