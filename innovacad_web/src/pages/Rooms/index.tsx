import { createResource, createSignal, For, Show, createMemo } from "solid-js";
import { useApi } from "@/hooks/useApi";
import { Icon } from "@/components/Icon";
import { useI18n } from "@/hooks/useL18N";
import { Room } from "@/types/room";

const Rooms = () => {
  const api = useApi();
  const { t } = useI18n();

  const [selectedRoomId, setSelectedRoomId] = createSignal<string>("");
  const [selectedDate, setSelectedDate] = createSignal<string>("");
  const [searchQuery, setSearchQuery] = createSignal("");

  const [roomsData] = createResource<Room[]>(api.fetchRoomsPublic);

  // --- LÓGICA DE FILTRAGEM (NOVO) ---
  const filteredRooms = createMemo(() => {
    let rooms = roomsData() || [];

    // Filtro por ID da Sala (Selectbox)
    if (selectedRoomId()) {
      // Nota: O teu value no option é room.room_id (number?),
      // mas o signal é string. A comparação deve ter isso em conta.
      rooms = rooms.filter((r) => r.room_id?.toString() === selectedRoomId());
    }

    // Filtro por Pesquisa de Texto
    if (searchQuery()) {
      const query = searchQuery().toLowerCase();
      rooms = rooms.filter((r) => r.room_name?.toLowerCase().includes(query));
    }

    return rooms;
  });
  // ----------------------------------

  return (
    <div class="min-h-screen bg-base-200 p-6">
      <div class="w-full">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2 text-primary">
            {t("public.rooms_page.title")}
          </h1>
          <p class="text-base-content/60">{t("public.rooms_page.desc")}</p>
        </div>

        {/* --- CARD DE FILTROS --- */}
        <div class="card bg-base-100 shadow-xl mb-6">
          <div class="card-body">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    {t("public.rooms_page.select_room")}
                  </span>
                </label>
                <select
                  class="select select-bordered w-full"
                  value={selectedRoomId()}
                  onChange={(e) => {
                    setSelectedRoomId(e.currentTarget.value);
                  }}
                >
                  <option value="">
                    {t("public.rooms_page.select_all_rooms") || "All Rooms"}
                  </option>
                  <For each={roomsData()}>
                    {(room) => (
                      <option value={room.room_id}>
                        {room.room_name} (Cap: {room.capacity})
                      </option>
                    )}
                  </For>
                </select>
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    {t("public.rooms_page.select_date")}
                  </span>
                </label>
                <input
                  type="date"
                  class="input input-bordered w-full"
                  value={selectedDate()}
                  onInput={(e) => setSelectedDate(e.currentTarget.value)}
                />
              </div>

              <div class="form-control lg:col-span-2">
                <label class="label">
                  <span class="label-text font-semibold">
                    {t("public.rooms_page.search_label")}
                  </span>
                </label>
                <div class="relative">
                  <Icon
                    name="Search"
                    size={20}
                    class="absolute left-3 top-1/2 -translate-y-1/2 text-base-content/40"
                  />
                  <input
                    type="text"
                    placeholder={t("public.rooms_page.search_placeholder")}
                    class="input input-bordered w-full pl-10"
                    value={searchQuery()}
                    onInput={(e) => setSearchQuery(e.currentTarget.value)}
                  />
                </div>
              </div>
            </div>

            <div class="flex justify-end mt-4">
              <button
                class="btn btn-ghost btn-sm"
                onClick={() => {
                  setSelectedRoomId("");
                  setSelectedDate("");
                  setSearchQuery("");
                }}
              >
                <Icon name="X" size={16} />
                {t("public.rooms_page.clear_filters")}
              </button>
            </div>
          </div>
        </div>

        {/* --- ESTADOS DE LOADING E ERRO --- */}
        <Show when={roomsData.loading}>
          <div class="flex justify-center py-10">
            <span class="loading loading-spinner loading-lg text-primary"></span>
          </div>
        </Show>

        <Show when={roomsData.error}>
          <div class="alert alert-error">
            {t("common.error_loading") || "Error loading data"}
          </div>
        </Show>

        {/* --- TABELA DE RESULTADOS --- */}
        <Show when={!roomsData.loading && !roomsData.error && roomsData()}>
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <div class="flex items-center justify-between mb-4">
                <h2 class="card-title">
                  <Icon name="Calendar" size={24} />
                  {t("public.rooms_page.found")}
                </h2>
                <div class="badge badge-primary badge-lg">
                  {filteredRooms().length}
                </div>
              </div>

              <Show
                when={filteredRooms().length > 0}
                fallback={
                  <div class="text-center py-10 opacity-50">
                    {t("public.rooms_page.no_results") || "Sem resultados"}
                  </div>
                }
              >
                <div class="overflow-x-auto">
                  <table class="table table-zebra">
                    <thead>
                      <tr>
                        <th>{t("entity.room")}</th>
                        <th>{t("general.capacity")}</th>
                        <th>{t("general.equipment") || "Equipamento"}</th>
                      </tr>
                    </thead>
                    <tbody>
                      {/* AQUI USAMOS O FILTEREDROOMS */}
                      <For each={filteredRooms()}>
                        {(room) => (
                          <tr class="hover">
                            <td>
                              <div class="badge badge-outline">
                                {room.room_name}
                              </div>
                            </td>
                            <td>
                              <div class="font-medium">{room.capacity}</div>
                            </td>
                            <td>
                              <div class="flex gap-2">
                                <Show when={room.has_computers}>
                                  <div
                                    class="tooltip"
                                    data-tip={t("general.has_computers")}
                                  >
                                    <div class="badge badge-ghost p-2">
                                      <Icon
                                        name="Monitor"
                                        size={16}
                                        class="text-primary"
                                      />
                                    </div>
                                  </div>
                                </Show>

                                <Show when={room.has_projector}>
                                  <div
                                    class="tooltip"
                                    data-tip={t("general.has_projector")}
                                  >
                                    <div class="badge badge-ghost p-2">
                                      <Icon
                                        name="Projector"
                                        size={16}
                                        class="text-secondary"
                                      />
                                    </div>
                                  </div>
                                </Show>

                                <Show when={room.has_whiteboard}>
                                  <div
                                    class="tooltip"
                                    data-tip={t("general.has_whiteboard")}
                                  >
                                    <div class="badge badge-ghost p-2">
                                      <Icon
                                        name="SquarePen"
                                        size={16}
                                        class="text-accent"
                                      />
                                    </div>
                                  </div>
                                </Show>

                                <Show when={room.has_smartboard}>
                                  <div
                                    class="tooltip"
                                    data-tip={t("general.has_smartboard")}
                                  >
                                    <div class="badge badge-ghost p-2">
                                      <Icon
                                        name="Tv"
                                        size={16}
                                        class="text-info"
                                      />
                                    </div>
                                  </div>
                                </Show>

                                <Show
                                  when={
                                    !room.has_computers &&
                                    !room.has_projector &&
                                    !room.has_whiteboard &&
                                    !room.has_smartboard
                                  }
                                >
                                  <span class="text-xs text-base-content/40 italic">
                                    -
                                  </span>
                                </Show>
                              </div>
                            </td>
                          </tr>
                        )}
                      </For>
                    </tbody>
                  </table>
                </div>
              </Show>
            </div>
          </div>
        </Show>
      </div>
    </div>
  );
};

export default Rooms;
