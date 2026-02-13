import { createResource, createSignal, For, Show, createMemo } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Schedule } from "@/types/schedule";
import type { Class } from "@/types/class";
import { Icon } from "@/components/Icon";
import { useI18n } from "@/hooks/useL18N";

const Schedules = () => {
    const api = useApi();
    const { t } = useI18n();

    const [viewMode, setViewMode] = createSignal<"class" | "trainer">("class");
    const [selectedClassId, setSelectedClassId] = createSignal<string>("");
    const [selectedTrainerId, setSelectedTrainerId] = createSignal<string>("");
    const [startDate, setStartDate] = createSignal<string>("");
    const [endDate, setEndDate] = createSignal<string>("");
    const [searchQuery, setSearchQuery] = createSignal("");

    const [classesData] = createResource<Class[]>(api.fetchClasses);
    const [trainersData] = createResource(api.fetchTrainers);

    const [schedulesData] = createResource(
        () => ({
            mode: viewMode(),
            classId: selectedClassId(),
            classes: classesData.loading ? undefined : classesData()
        }),
        async ({ mode, classId, classes }) => {
            if (mode === "class") {
                if (classId) {
                    return await api.fetchSchedules(classId);
                } else {
                    if (!classes) return [];

                    const allSchedules: Schedule[] = [];
                    for (const cls of classes) {
                        try {
                            const schedules = await api.fetchSchedules(cls.class_id!);
                            allSchedules.push(...schedules);
                        } catch (e) {
                            console.warn(`Failed to fetch schedules for class ${cls.class_id}`, e);
                        }
                    }
                    return allSchedules;
                }
            } else {
                if (!classes) return [];

                const allSchedules: Schedule[] = [];
                for (const cls of classes) {
                    try {
                        const schedules = await api.fetchSchedules(cls.class_id!);
                        allSchedules.push(...schedules);
                    } catch (e) {
                        console.warn(`Failed to fetch schedules for class ${cls.class_id}`, e);
                    }
                }
                return allSchedules;
            }
        }
    );


    const filteredSchedules = createMemo(() => {
        let schedules = schedulesData() || [];

        if (viewMode() === "trainer" && selectedTrainerId()) {
            schedules = schedules.filter(s => s.trainer_id === selectedTrainerId());
        }

        if (startDate()) {
            const start = new Date(startDate());
            schedules = schedules.filter(s => {
                const scheduleDate = s.start;
                return scheduleDate && scheduleDate >= start;
            });
        }

        if (endDate()) {
            const end = new Date(endDate());
            end.setHours(23, 59, 59, 999);
            schedules = schedules.filter(s => {
                const scheduleDate = s.start;
                return scheduleDate && scheduleDate <= end;
            });
        }

        if (searchQuery()) {
            const query = searchQuery().toLowerCase();
            schedules = schedules.filter(s =>
                s.module_name?.toLowerCase().includes(query) ||
                s.trainer_name?.toLowerCase().includes(query) ||
                s.room_name?.toLowerCase().includes(query) ||
                s.class_name?.toLowerCase().includes(query)
            );
        }

        return schedules;
    });

    const formatDate = (date: Date | undefined) => {
        if (!date) return "N/A";
        return new Intl.DateTimeFormat("pt-PT", {
            day: "2-digit",
            month: "2-digit",
            year: "numeric",
        }).format(date);
    };

    const formatTime = (date: Date | undefined) => {
        if (!date) return "N/A";
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
                        {t("public.schedules.title")}
                    </h1>
                    <p class="text-base-content/60">
                        {t("public.schedules.desc")}
                    </p>
                </div>

                <div class="mb-6 flex justify-center">
                    <div class="join bg-base-200/50 p-1 rounded-lg">
                        <button
                            class={`join-item btn border-0 ${viewMode() === "class" ? "btn-active shadow-sm !bg-base-100 text-base-content hover:!bg-base-100" : "btn-ghost text-base-content/70 hover:bg-transparent"}`}
                            onClick={() => {
                                setViewMode("class");
                                setSelectedTrainerId("");
                            }}
                        >
                            <Icon name="School" size={20} />
                            {t("public.schedules.by_class")}
                        </button>
                        <button
                            class={`join-item btn border-0 ${viewMode() === "trainer" ? "btn-active shadow-sm !bg-base-100 text-base-content hover:!bg-base-100" : "btn-ghost text-base-content/70 hover:bg-transparent"}`}
                            onClick={() => {
                                setViewMode("trainer");
                                setSelectedClassId("");
                            }}
                        >
                            <Icon name="User" size={20} />
                            {t("public.schedules.by_trainer")}
                        </button>
                    </div>
                </div>

                <div class="card bg-base-100 shadow-xl mb-6">
                    <div class="card-body">
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                            <Show when={viewMode() === "class"}>
                                <div class="form-control">
                                    <label class="label">
                                        <span class="label-text font-semibold">{t("public.schedules.select_class")}</span>
                                    </label>
                                    <select
                                        class="select select-bordered w-full"
                                        value={selectedClassId()}
                                        onChange={(e) => {
                                            setSelectedClassId(e.currentTarget.value);
                                        }}
                                    >
                                        <option value="">{t("public.schedules.select_all_classes")}</option>
                                        <For each={classesData()}>
                                            {(cls) => (
                                                <option value={cls.class_id}>
                                                    {cls.identifier} - {cls.location}
                                                </option>
                                            )}
                                        </For>
                                    </select>
                                </div>
                            </Show>

                            <Show when={viewMode() === "trainer"}>
                                <div class="form-control">
                                    <label class="label">
                                        <span class="label-text font-semibold">{t("public.schedules.select_trainer")}</span>
                                    </label>
                                    <select
                                        class="select select-bordered w-full"
                                        value={selectedTrainerId()}
                                        onChange={(e) => {
                                            setSelectedTrainerId(e.currentTarget.value);

                                        }}
                                    >
                                        <option value="">{t("public.schedules.select_all_trainers")}</option>
                                        <For each={trainersData()}>
                                            {(trainer) => (
                                                <option value={trainer.trainer_id || trainer.trainerId}>
                                                    {trainer.name} ({trainer.email})
                                                </option>
                                            )}
                                        </For>
                                    </select>
                                </div>
                            </Show>

                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-semibold">{t("public.schedules.start_date")}</span>
                                </label>
                                <input
                                    type="date"
                                    class="input input-bordered w-full"
                                    value={startDate()}
                                    onInput={(e) => setStartDate(e.currentTarget.value)}
                                />
                            </div>

                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-semibold">{t("public.schedules.end_date")}</span>
                                </label>
                                <input
                                    type="date"
                                    class="input input-bordered w-full"
                                    value={endDate()}
                                    onInput={(e) => setEndDate(e.currentTarget.value)}
                                />
                            </div>

                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-semibold">{t("public.schedules.search_label")}</span>
                                </label>
                                <div class="relative">
                                    <Icon
                                        name="Search"
                                        size={20}
                                        class="absolute left-3 top-1/2 -translate-y-1/2 text-base-content/40"
                                    />
                                    <input
                                        type="text"
                                        placeholder={t("public.schedules.search_detailed_placeholder")}
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
                                    setStartDate("");
                                    setEndDate("");
                                    setSearchQuery("");
                                }}
                            >
                                <Icon name="X" size={16} />
                                {t("public.schedules.clear_filters")}
                            </button>
                        </div>
                    </div>
                </div>

                <Show when={schedulesData.loading}>
                    <div class="flex justify-center items-center py-20">
                        <span class="loading loading-spinner loading-lg text-primary"></span>
                    </div>
                </Show>

                <Show when={schedulesData.error}>
                    <div class="alert alert-error shadow-lg">
                        <Icon name="CircleAlert" size={24} />
                        <span>{t("common.error_loading")}</span>
                    </div>
                </Show>

                <Show when={!schedulesData.loading && !schedulesData.error}>
                    <div class="card bg-base-100 shadow-xl">
                        <div class="card-body">
                            <div class="flex items-center justify-between mb-4">
                                <h2 class="card-title">
                                    <Icon name="Calendar" size={24} />
                                    {t("public.schedules.found")}
                                </h2>
                                <div class="badge badge-primary badge-lg">
                                    {filteredSchedules().length} {filteredSchedules().length === 1 ? t("entity.schedule") : t("entity.schedules")}
                                </div>
                            </div>

                            <Show
                                when={filteredSchedules().length > 0}
                                fallback={
                                    <div class="text-center py-12">
                                        <Icon
                                            name="CalendarX"
                                            size={48}
                                            class="mx-auto mb-3 text-base-content/20"
                                        />
                                        <p class="text-base-content/60">
                                            {t("public.schedules.no_results")}
                                        </p>
                                    </div>
                                }
                            >
                                <div class="overflow-x-auto">
                                    <table class="table table-zebra">
                                        <thead>
                                            <tr>
                                                <th>{t("entity.date")}</th>
                                                <th>{t("entity.time")}</th>
                                                <th>{t("entity.module")}</th>
                                                <Show when={viewMode() === "class"}>
                                                    <th>{t("entity.trainer")}</th>
                                                </Show>
                                                <Show when={viewMode() === "trainer"}>
                                                    <th>{t("entity.class")}</th>
                                                </Show>
                                                <th>{t("entity.room")}</th>
                                                <th>{t("entity.regime")}</th>
                                                <th>{t("entity.duration")}</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <For each={filteredSchedules()}>
                                                {(schedule) => (
                                                    <tr class="hover">
                                                        <td>
                                                            <div class="flex items-center gap-2">
                                                                <Icon name="Calendar" size={16} class="text-primary" />
                                                                <span class="font-medium">{formatDate(schedule.start)}</span>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="flex items-center gap-2">
                                                                <Icon name="Clock" size={16} class="text-base-content/60" />
                                                                <span>
                                                                    {formatTime(schedule.start)} - {formatTime(schedule.end)}
                                                                </span>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="font-medium">{schedule.module_name}</div>
                                                            <div class="text-xs text-base-content/60">
                                                                {schedule.current_duration?.toFixed(1)}h / {schedule.total_duration?.toFixed(1)}h
                                                            </div>
                                                        </td>
                                                        <Show when={viewMode() === "class"}>
                                                            <td>
                                                                <div class="flex items-center gap-2">
                                                                    <Icon name="User" size={16} class="text-base-content/60" />
                                                                    <div>
                                                                        <div class="font-medium">{schedule.trainer_name}</div>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                        </Show>
                                                        <Show when={viewMode() === "trainer"}>
                                                            <td>
                                                                <div class="badge badge-outline">{schedule.class_name}</div>
                                                            </td>
                                                        </Show>
                                                        <td>
                                                            <Show
                                                                when={schedule.isOnlineBoolean}
                                                                fallback={
                                                                    <div class="flex items-center gap-2">
                                                                        <Icon name="MapPin" size={16} class="text-base-content/60" />
                                                                        <span>{schedule.room_name}</span>
                                                                    </div>
                                                                }
                                                            >
                                                                <div class="badge badge-info gap-1">
                                                                    <Icon name="Wifi" size={14} />
                                                                    {t("entity.online")}
                                                                </div>
                                                            </Show>
                                                        </td>
                                                        <td>
                                                            <span class="badge badge-ghost">
                                                                {schedule.regime_type}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <div class="flex items-center gap-1">
                                                                <Icon name="Clock" size={14} class="text-base-content/60" />
                                                                <span>
                                                                    {schedule.start && schedule.end
                                                                        ? ((schedule.end.getTime() - schedule.start.getTime()) / (1000 * 60 * 60)).toFixed(1)
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
            </div>
        </div>
    );
};

export default Schedules;
