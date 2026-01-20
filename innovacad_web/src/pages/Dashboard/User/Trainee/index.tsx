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

const PAGE_SIZE = 10;

const createEmptyTrainee = (): Trainee =>
  ({
    id: "",
    name: "",
    email: "",
    username: "",
    role: "trainee",
    traineeId: "",
    token: "",
    birthdayDate: "",
    image: null,
    verified: false,
    session_token: "",
  }) as unknown as Trainee;

const TraineePage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Trainee[]>(api.fetchTrainees);

  const [page, setPage] = createSignal(1);
  const [search, setSearch] = createSignal("");

  const [editingUser, setEditingUser] = createSignal<Trainee | null>(null);
  const [deletingUser, setDeletingUser] = createSignal<Trainee | null>(null);

  const filteredUsers = createMemo(() => {
    const q = search().toLowerCase();
    const list = usersData() || [];
    return list.filter(
      (u: Trainee) =>
        u.name?.toLowerCase().includes(q) || u.email?.toLowerCase().includes(q),
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
      const isEditing = trainee.traineeId && trainee.traineeId.length > 0;

      if (isEditing) {

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.traineeId === trainee.traineeId ? trainee : u,
            ) || [],
        );
        toast.success("Trainee updated successfully");
      } else {

        mutate((prev) => [...(prev || []), trainee]);
        toast.success("Trainee created successfully");
      }

      setEditingUser(null);
    } catch (error) {
      toast.error(
        error instanceof Error ? error.message : "Failed to save trainee",
      );
      throw error;
    }
  };

  const confirmDelete = async () => {
    const userToDelete = deletingUser();
    if (!userToDelete) return;

    try {

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
    }
  };

  return (
    <div class="card bg-base-100 shadow">
      <Toaster />
      <div class="card-body gap-4">
        {/* HEADER */}
        <div class="flex justify-between items-center">
          <h2 class="card-title">Trainees</h2>

          <button
            class="btn btn-primary btn-sm"
            onClick={() => setEditingUser(createEmptyTrainee())}
          >
            <Icon name="Plus" size={16} />
            Add Trainee
          </button>
        </div>

        {/* FILTER */}
        <input
          type="text"
          placeholder="Search trainees..."
          class="input input-bordered input-sm w-full max-w-xs"
          onInput={(e) => {
            setSearch(e.currentTarget.value);
            setPage(1);
          }}
        />

        {/* TABLE */}
        <div class="overflow-x-auto">
          <table class="table table-zebra table-fixed w-full">
            <thead>
              <tr>
                <th class="w-52">Trainee ID</th>
                <th class="w-52">User ID</th>
                <th class="w-32">Name</th>
                <th class="w-48">Email</th>
                <th class="w-32">Username</th>
                <th class="w-24">Role</th>
                <th class="w-28 text-right">Actions</th>
              </tr>
            </thead>

            <tbody>
              <For each={paginatedUsers()}>
                {(user) => (
                  <tr>
                    <td class="w-52">
                      <CopyToClipboard val={user.traineeId}>
                        <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
                          {user.traineeId}
                        </div>
                      </CopyToClipboard>
                    </td>

                    <td class="w-52">
                      <CopyToClipboard val={user.id || ""}>
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
                        onClick={() => setEditingUser(user)}
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

        {/* PAGINATION */}
        <div class="flex justify-between items-center">
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

      {/* ADD / EDIT MODAL */}
      <Show when={editingUser()}>
        {(u) => (
          <ModalEdit<Trainee>
            value={u}
            setValue={setEditingUser}
            onSave={handleSaveTrainee}
            onCancel={() => setEditingUser(null)}
            title="Trainee"
          />
        )}
      </Show>

      {/* DELETE MODAL */}
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
