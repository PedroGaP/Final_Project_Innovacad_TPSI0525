import { createMemo, createSignal, For, Show } from "solid-js";
import { Icon } from "@/components/Icon";
import { useApi } from "@/hooks/useApi";

interface User {
  id: number;
  name: string;
  email: string;
  role: string;
}

const PAGE_SIZE = 10;

const UsersPage = () => {
  const [users, setUsers] = createSignal<User[]>([]);

  const [page, setPage] = createSignal(1);
  const [search, setSearch] = createSignal("");

  const [editingUser, setEditingUser] = createSignal<User | null>(null);
  const [deletingUser, setDeletingUser] = createSignal<User | null>(null);

  const filteredUsers = createMemo(() => {
    const q = search().toLowerCase();
    return users().filter(
      (u) =>
        u.name.toLowerCase().includes(q) ||
        u.email.toLowerCase().includes(q) ||
        u.role.toLowerCase().includes(q)
    );
  });

  const totalPages = createMemo(() =>
    Math.ceil(filteredUsers().length / PAGE_SIZE)
  );

  const paginatedUsers = createMemo(() => {
    const start = (page() - 1) * PAGE_SIZE;
    return filteredUsers().slice(start, start + PAGE_SIZE);
  });

  const saveUser = (user: User) => {
    setUsers((prev) => {
      const exists = prev.find((u) => u.id === user.id);
      return exists
        ? prev.map((u) => (u.id === user.id ? user : u))
        : [...prev, { ...user, id: Date.now() }];
    });
    setEditingUser(null);
  };

  const confirmDelete = () => {
    setUsers(users().filter((u) => u.id !== deletingUser()?.id));
    setDeletingUser(null);
  };

  return (
    <div class="card bg-base-100 shadow">
      <div class="card-body gap-4">
        <div class="flex justify-between items-center">
          <h2 class="card-title">Users</h2>

          <button
            class="btn btn-primary btn-sm"
            onClick={() =>
              setEditingUser({ id: 0, name: "", email: "", role: "User" })
            }
          >
            <Icon name="Plus" size={16} />
            Add User
          </button>
        </div>

        <input
          type="text"
          placeholder="Search users..."
          class="input input-bordered input-sm w-full max-w-xs"
          onInput={(e) => {
            setSearch(e.currentTarget.value);
            setPage(1);
          }}
        />

        <div class="overflow-x-auto">
          <table class="table table-zebra">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th class="text-right">Actions</th>
              </tr>
            </thead>

            <tbody>
              <For each={paginatedUsers()}>
                {(user) => (
                  <tr>
                    <td>{user.name}</td>
                    <td>{user.email}</td>
                    <td>
                      <span class="badge badge-outline">{user.role}</span>
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

      <Show when={editingUser()}>
        {(u) => (
          <dialog open class="modal">
            <div class="modal-box">
              <h3 class="font-bold text-lg">
                {u().id ? "Edit User" : "Add User"}
              </h3>

              <div class="space-y-3 mt-4">
                <input
                  class="input input-bordered w-full"
                  placeholder="Name"
                  value={u().name}
                  onInput={(e) =>
                    setEditingUser({ ...u(), name: e.currentTarget.value })
                  }
                />

                <input
                  class="input input-bordered w-full"
                  placeholder="Email"
                  value={u().email}
                  onInput={(e) =>
                    setEditingUser({ ...u(), email: e.currentTarget.value })
                  }
                />

                <select
                  class="select select-bordered w-full"
                  value={u().role}
                  onChange={(e) =>
                    setEditingUser({ ...u(), role: e.currentTarget.value })
                  }
                >
                  <option>User</option>
                  <option>Admin</option>
                </select>
              </div>

              <div class="modal-action">
                <button class="btn" onClick={() => setEditingUser(null)}>
                  Cancel
                </button>
                <button class="btn btn-primary" onClick={() => saveUser(u())}>
                  Save
                </button>
              </div>
            </div>
          </dialog>
        )}
      </Show>

      <Show when={deletingUser()}>
        {(u) => (
          <dialog open class="modal">
            <div class="modal-box">
              <h3 class="font-bold text-lg">Delete User</h3>
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

export default UsersPage;
