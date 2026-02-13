import { createResource, createSignal, For, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Class } from "@/types/class";
import { Icon } from "@/components/Icon";
import capitalize from "@/utils/capitalize";

const Classes = () => {
  const api = useApi();
  const [classesData] = createResource<Class[]>(api.fetchClasses);
  const [searchQuery, setSearchQuery] = createSignal("");

  const filteredClasses = () => {
    const query = searchQuery().toLowerCase();
    const classes = classesData();
    if (!classes) return [];
    if (!query) return classes;

    return classes.filter(
      (cls) =>
        cls.identifier?.toLowerCase().includes(query) ||
        cls.location?.toLowerCase().includes(query) ||
        cls.status?.toLowerCase().includes(query) ||
        cls.course_identifier?.toLowerCase().includes(query),
    );
  };

  const formatDate = (timestamp: number | undefined) => {
    if (timestamp !== undefined)
      return new Date(Number(timestamp)).toLocaleDateString();
    return "N/A";
  };

  const getStatusColor = (status: string | undefined) => {
    const statusMap: Record<string, string> = {
      starting: "badge-info",
      ongoing: "badge-success",
      finished: "badge-ghost",
    };
    return statusMap[status?.toLowerCase() || ""] || "badge-ghost";
  };

  return (
    <div class="min-h-screen bg-base-200 p-6">
      <div class="w-full">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2 text-primary">Classes</h1>
          <p class="text-base-content/60">
            View all classes, their status, and modules
          </p>
        </div>

        <div class="mb-6">
          <div class="relative">
            <Icon
              name="Search"
              size={20}
              class="absolute left-4 top-1/2 -translate-y-1/2 text-base-content/40"
            />
            <input
              type="text"
              placeholder="Search by identifier, location, or status..."
              class="input input-bordered w-full pl-12 bg-base-100 shadow-sm"
              value={searchQuery()}
              onInput={(e) => setSearchQuery(e.currentTarget.value)}
            />
          </div>
        </div>

        <Show when={classesData.loading}>
          <div class="flex justify-center items-center py-20">
            <span class="loading loading-spinner loading-lg text-primary"></span>
          </div>
        </Show>

        <Show when={classesData.error}>
          <div class="alert alert-error shadow-lg">
            <Icon name="CircleAlert" size={24} />
            <span>Failed to load classes. Please try again later.</span>
          </div>
        </Show>

        <Show when={!classesData.loading && !classesData.error}>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <For
              each={filteredClasses()}
              fallback={
                <div class="col-span-full text-center py-20">
                  <Icon
                    name="GraduationCap"
                    size={64}
                    class="mx-auto mb-4 text-base-content/20"
                  />
                  <p class="text-lg text-base-content/60">
                    {searchQuery()
                      ? "No classes found matching your search"
                      : "No classes available"}
                  </p>
                </div>
              }
            >
              {(cls) => (
                <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:-translate-y-1">
                  <div class="card-body">
                    <div class="flex items-start justify-between mb-3">
                      <div class="badge badge-primary badge-lg font-mono">
                        {cls.identifier}
                      </div>
                      <div
                        class={`badge ${getStatusColor(cls.status)} badge-sm`}
                      >
                        {capitalize(cls.status?.toString() || "")}
                      </div>
                    </div>

                    <Show when={cls.course_identifier}>
                      <div class="flex items-center gap-2 mb-2">
                        <Icon
                          name="BookOpen"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm font-medium text-base-content/80">
                          {cls.course_identifier}
                        </span>
                      </div>
                    </Show>

                    <div class="flex items-center gap-2 mb-4">
                      <Icon
                        name="MapPin"
                        size={16}
                        class="text-base-content/60"
                      />
                      <span class="text-sm text-base-content/80">
                        {cls.location}
                      </span>
                    </div>

                    <div class="grid grid-cols-2 gap-2 mb-4">
                      <div class="bg-base-200/50 rounded-lg p-2">
                        <p class="text-xs text-base-content/60 mb-1">Start</p>
                        <p class="text-sm font-medium">
                          {formatDate(cls.start_date_timestamp!)}
                        </p>
                      </div>
                      <div class="bg-base-200/50 rounded-lg p-2">
                        <p class="text-xs text-base-content/60 mb-1">End</p>
                        <p class="text-sm font-medium">
                          {formatDate(cls.end_date_timestamp)}
                        </p>
                      </div>
                    </div>

                    <Show when={cls.modules && cls.modules.length > 0}>
                      <div class="divider my-2">Modules</div>
                      <div class="space-y-2 max-h-48 overflow-y-auto">
                        <For each={cls.modules}>
                          {(module) => (
                            <div class="p-2 rounded-lg bg-base-200/50 hover:bg-base-200 transition-colors">
                              <div class="flex items-center justify-between mb-1">
                                <p class="text-sm font-medium line-clamp-1">
                                  {module.module_name || "Unnamed Module"}
                                </p>
                                <Show when={module.trainer_id}>
                                  <Icon
                                    name="User"
                                    size={14}
                                    class="text-primary"
                                  />
                                </Show>
                              </div>
                              <Show when={module.trainer_name}>
                                <p class="text-xs text-base-content/60">
                                  Trainer: {module.trainer_name}
                                </p>
                              </Show>
                              <Show
                                when={
                                  module.current_duration !== undefined &&
                                  module.total_duration !== undefined
                                }
                              >
                                <div class="flex items-center gap-2 mt-1">
                                  <progress
                                    class="progress progress-primary w-full h-1"
                                    value={module.current_duration}
                                    max={module.total_duration}
                                  ></progress>
                                  <span class="text-xs text-base-content/60 whitespace-nowrap">
                                    {module.current_duration}h /{" "}
                                    {module.total_duration}h
                                  </span>
                                </div>
                              </Show>
                            </div>
                          )}
                        </For>
                      </div>
                      <div class="mt-3 flex gap-2">
                        <div class="badge badge-neutral badge-sm">
                          {cls.modules.length} modules
                        </div>
                        <div class="badge badge-primary badge-sm">
                          {cls.modules.filter((m) => m.trainer_id).length}{" "}
                          assigned
                        </div>
                      </div>
                    </Show>

                    <Show when={!cls.modules || cls.modules.length === 0}>
                      <div class="alert alert-info text-xs mt-2">
                        <Icon name="Info" size={14} />
                        <span>No modules assigned yet</span>
                      </div>
                    </Show>
                  </div>
                </div>
              )}
            </For>
          </div>

          <Show when={filteredClasses().length > 0}>
            <div class="mt-6 text-center text-sm text-base-content/60">
              Showing {filteredClasses().length} of {classesData()?.length || 0}{" "}
              classes
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default Classes;
