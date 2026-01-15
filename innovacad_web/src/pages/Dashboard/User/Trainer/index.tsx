import { createMemo, createResource, createSignal, For, Show } from "solid-js";
import { Icon } from "@/components/Icon";
import type { Trainer } from "@/types/user";
import capitalize from "@/utils/capitalize";
import CopyToClipboard from "@/components/CopyToClipboard";
import { useApi } from "@/hooks/useApi";

const PAGE_SIZE = 10;
const createEmptyTrainer = (): Trainer =>
  ({
    id: "",
    name: "",
    email: "",
    role: "User",
    trainerId: "",
    username: "",
    token: "",
  } as Trainer);

const TrainerPage = () => {
  const api = useApi();

  const [usersData, { mutate, refetch }] = createResource<Trainer[]>(
    api.fetchTrainers
  );

  console.log(JSON.stringify(usersData()));

  const [page, setPage] = createSignal(1);
  const [search, setSearch] = createSignal("");

  const [editingUser, setEditingUser] = createSignal<Trainer | null>(null);
  const [deletingUser, setDeletingUser] = createSignal<Trainer | null>(null);

  const filteredUsers = createMemo(() => {
    const q = search().toLowerCase();
    const list = usersData() || [];
    return list.filter(
      (u: Trainer) =>
        u.name?.toLowerCase().includes(q) || u.email?.toLowerCase().includes(q)
    );
  });

  const totalPages = createMemo(() =>
    Math.ceil(filteredUsers().length / PAGE_SIZE)
  );

  const paginatedUsers = createMemo(() => {
    const start = (page() - 1) * PAGE_SIZE;
    return filteredUsers().slice(start, start + PAGE_SIZE);
  });

  const confirmDelete = async () => {
    const userToDelete = deletingUser();
    if (!userToDelete) return;

    // Optional: Call API to delete
    // await api.deleteTrainer(userToDelete.id);

    // Update the UI immediately without refetching the whole list
    mutate((prev) => prev?.filter((u) => u.id !== userToDelete.id) || []);
    setDeletingUser(null);
  };

  return (
    <div class="card bg-base-100 shadow">
      <div class="card-body gap-4">
        {/* HEADER */}
        <div class="flex justify-between items-center">
          <h2 class="card-title">Trainers</h2>

          <button
            class="btn btn-primary btn-sm"
            onClick={() => setEditingUser(createEmptyTrainer())}
          >
            <Icon name="Plus" size={16} />
            Add Trainer
          </button>
        </div>

        {/* FILTER */}
        <input
          type="text"
          placeholder="Search trainers..."
          class="input input-bordered input-sm w-full max-w-xs"
          onInput={(e) => {
            setSearch(e.currentTarget.value);
            setPage(1);
          }}
        />

        {/* TABLE */}
        <div class="overflow-x-auto">
          <table class="table table-zebra table-fixed w-full overflow-visible">
            <thead>
              <tr>
                <th class="w-52">Trainer ID</th>
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
                {(user) => {
                  console.log(user);
                  console.log(typeof user);
                  return (
                    <tr>
                      <td class="w-52">
                        <CopyToClipboard val={user.trainerId}>
                          <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
                            {user.trainerId}
                          </div>
                        </CopyToClipboard>
                      </td>
                      <td class="w-52">
                        <CopyToClipboard val={user.id}>
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
                  );
                }}
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
          <dialog open class="modal">
            <div class="modal-box">
              <h3 class="font-bold text-lg">
                {u().id ? "Edit Trainer" : "Add Trainer"}
              </h3>

              <div class="space-y-3 mt-4">
                <input
                  class="input input-bordered w-full"
                  placeholder="Name"
                  value={u().name}
                  onInput={(e) =>
                    setEditingUser({
                      ...u(),
                      name: e.currentTarget.value,
                    } as Trainer)
                  }
                />

                <input
                  class="input input-bordered w-full"
                  placeholder="Email"
                  value={u().email}
                  onInput={(e) =>
                    setEditingUser({
                      ...u(),
                      email: e.currentTarget.value,
                    } as Trainer)
                  }
                />

                <select
                  class="select select-bordered w-full"
                  value={u().role}
                  onChange={(e) =>
                    setEditingUser({
                      ...u(),
                      role: e.currentTarget.value,
                    } as Trainer)
                  }
                >
                  <option>Trainer</option>
                  <option>Trainer</option>
                  <option>Admin</option>
                </select>
              </div>

              <div class="modal-action">
                <button class="btn" onClick={() => setEditingUser(null)}>
                  Cancel
                </button>
                <button class="btn btn-primary">Save</button>
              </div>
            </div>
          </dialog>
        )}
      </Show>

      {/* DELETE MODAL */}
      <Show when={deletingUser()}>
        {(u) => (
          <dialog open class="modal">
            <div class="modal-box">
              <h3 class="font-bold text-lg">Delete Trainer</h3>
              <p class="py-4">
                Are you sure you want to delete <strong>{u().name}</strong>?
              </p>

              <div class="modal-action">
                <button class="btn" onClick={() => setDeletingUser(null)}>
                  Cancel
                </button>
                <button class="btn btn-error" onClick={confirmDelete}>
                  Delete
                </button>
              </div>
            </div>
          </dialog>
        )}
      </Show>
    </div>
  );
};

export default TrainerPage;
