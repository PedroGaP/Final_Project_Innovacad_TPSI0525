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


    const [roomsData] = createResource<Room[]>(api.fetchRooms);

    const fetchAvailability = async (roomId: string, date: string) => {
        try {
            const slots = await api.fetchRoomAvailability(roomId, date);
            return slots.map(slot => ({ ...slot, roomId }));
        } catch (e) {
            console.warn(`Failed to fetch availability for room ${roomId}`, e);
            return [];
        }
    };

    const [availabilityData] = createResource(
        () => ({ roomId: selectedRoomId(), date: selectedDate(), rooms: roomsData.loading ? undefined : roomsData() }),
        async ({ roomId, date, rooms }) => {
            if (!date) return [];

            if (roomId) {
                return await fetchAvailability(roomId, date);
            } else if (rooms && rooms.length > 0) {
                const promises = rooms.map(r => fetchAvailability(r.room_id!.toString(), date));
                const results = await Promise.all(promises);
                return results.flat();
            }
            return [];
        }
    );

    const filteredSlots = createMemo(() => {
        let slots = availabilityData() || [];

        if (searchQuery()) {
            const query = searchQuery().toLowerCase();
            slots = slots.filter(s =>
                s.description?.toLowerCase().includes(query)
            );
        }

        return slots
            .filter(s => !isNaN(s.start.getTime()) && !isNaN(s.end.getTime()))
            .sort((a, b) => a.start.getTime() - b.start.getTime());
    });

    const getRoomName = (id?: string) => {
        if (!id) return "";
        return roomsData()?.find(r => r.room_id!.toString() === id)?.room_name || "";
    };

    const formatTime = (date: Date | undefined) => {
        if (!date || isNaN(date.getTime())) return "N/A";
        return new Intl.DateTimeFormat("pt-PT", {
            hour: "2-digit",
            minute: "2-digit",
        }).format(date);
    };

    return (
        <div class="min-h-screen bg-base-200 p-6">
            <div class="w-full">
                <div class="mb-8">
                    <h1 class="text-4xl font-bold mb-2 text-primary">
                        {t("public.rooms_page.title")}
                    </h1>
                    <p class="text-base-content/60">
                        {t("public.rooms_page.desc")}
                    </p>
                </div>

                <div class="card bg-base-100 shadow-xl mb-6">
                    <div class="card-body">
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-semibold">{t("public.rooms_page.select_room")}</span>
                                </label>
                                <select
                                    class="select select-bordered w-full"
                                    value={selectedRoomId()}
                                    onChange={(e) => {
                                        setSelectedRoomId(e.currentTarget.value);
                                    }}
                                >
                                    <option value="">{t("public.rooms_page.select_all_rooms") || "All Rooms"}</option>
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
                                    <span class="label-text font-semibold">{t("public.rooms_page.select_date")}</span>
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
                                    <span class="label-text font-semibold">{t("public.rooms_page.search_label")}</span>
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

                <Show when={availabilityData.loading}>
                    <div class="flex justify-center items-center py-20">
                        <span class="loading loading-spinner loading-lg text-primary"></span>
                    </div>
                </Show>

                <Show when={availabilityData.error}>
                    <div class="alert alert-error shadow-lg">
                        <Icon name="CircleAlert" size={24} />
                        <span>{t("common.error_loading")}</span>
                    </div>
                </Show>

                <Show when={!availabilityData.loading && !availabilityData.error}>
                    <Show
                        when={selectedDate()}
                        fallback={
                            <div class="card bg-base-100 shadow-xl">
                                <div class="card-body text-center py-20">
                                    <Icon
                                        name="Armchair"
                                        size={64}
                                        class="mx-auto mb-4 text-base-content/20"
                                    />
                                    <p class="text-lg text-base-content/60">
                                        {t("public.rooms_page.select_prompt")}
                                    </p>
                                </div>
                            </div>
                        }
                    >
                        <div class="card bg-base-100 shadow-xl">
                            <div class="card-body">
                                <div class="flex items-center justify-between mb-4">
                                    <h2 class="card-title">
                                        <Icon name="Calendar" size={24} />
                                        {t("public.rooms_page.found")}
                                    </h2>
                                    <div class="badge badge-primary badge-lg">
                                        {filteredSlots().length}
                                    </div>
                                </div>

                                <Show
                                    when={filteredSlots().length > 0}
                                    fallback={
                                        <div class="text-center py-12">
                                            <Icon
                                                name="CalendarX"
                                                size={48}
                                                class="mx-auto mb-3 text-base-content/20"
                                            />
                                            <p class="text-base-content/60">
                                                {t("public.rooms_page.no_results")}
                                            </p>
                                        </div>
                                    }
                                >
                                    <div class="overflow-x-auto">
                                        <table class="table table-zebra">
                                            <thead>
                                                <tr>
                                                    <th>{t("entity.time")}</th>
                                                    <th>{t("entity.room")}</th>
                                                    <th>{t("entity.description")}</th>
                                                    <th>{t("entity.duration")}</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <For each={filteredSlots()}>
                                                    {(slot) => (
                                                        <tr class="hover">
                                                            <td>
                                                                <div class="flex items-center gap-2">
                                                                    <Icon name="Clock" size={16} class="text-base-content/60" />
                                                                    <span>
                                                                        {formatTime(slot.start)} - {formatTime(slot.end)}
                                                                    </span>
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="badge badge-outline">
                                                                    {getRoomName((slot as any).roomId)}
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <div class="font-medium">{slot.description || "Busy"}</div>
                                                            </td>
                                                            <td>
                                                                <div class="flex items-center gap-1">
                                                                    <Icon name="Clock" size={14} class="text-base-content/60" />
                                                                    <span>
                                                                        {slot.start && slot.end
                                                                            ? ((slot.end.getTime() - slot.start.getTime()) / (1000 * 60 * 60)).toFixed(1)
                                                                            : "N/A"}h
                                                                    </span>
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
                </Show>
            </div>
        </div>
    );
};

export default Rooms;
