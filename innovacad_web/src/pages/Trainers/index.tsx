import { createResource, createSignal, For, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Trainer } from "@/types/user";
import { Icon } from "@/components/Icon";

const Trainers = () => {
  const api = useApi();
  const [trainersData] = createResource<Trainer[]>(api.fetchTrainers);
  const [searchQuery, setSearchQuery] = createSignal("");

  const filteredTrainers = () => {
    const query = searchQuery().toLowerCase();
    const trainers = trainersData();
    if (!trainers) return [];
    if (!query) return trainers;

    return trainers.filter(
      (trainer) =>
        trainer.name?.toLowerCase().includes(query) ||
        trainer.email?.toLowerCase().includes(query) ||
        trainer.username?.toLowerCase().includes(query),
    );
  };

  const formatDate = (timestamp: number | undefined) => {
    if (timestamp !== undefined)
      return new Date(Number(timestamp)).toLocaleDateString();
    return "N/A";
  };

  return (
    <div class="min-h-screen bg-base-200">
      <div class="w-full p-6">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2 text-primary">
            Trainers
          </h1>
          <p class="text-base-content/60">
            View all trainers and their information
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
              placeholder="Search by name, email, or username..."
              class="input input-bordered w-full pl-12 bg-base-100 shadow-sm"
              value={searchQuery()}
              onInput={(e) => setSearchQuery(e.currentTarget.value)}
            />
          </div>
        </div>

        <Show when={trainersData.loading}>
          <div class="flex justify-center items-center py-20">
            <span class="loading loading-spinner loading-lg text-primary"></span>
          </div>
        </Show>

        <Show when={trainersData.error}>
          <div class="alert alert-error shadow-lg">
            <Icon name="CircleAlert" size={24} />
            <span>Failed to load trainers. Please try again later.</span>
          </div>
        </Show>

        <Show when={!trainersData.loading && !trainersData.error}>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <For
              each={filteredTrainers()}
              fallback={
                <div class="col-span-full text-center py-20">
                  <Icon
                    name="Users"
                    size={64}
                    class="mx-auto mb-4 text-base-content/20"
                  />
                  <p class="text-lg text-base-content/60">
                    {searchQuery()
                      ? "No trainers found matching your search"
                      : "No trainers available"}
                  </p>
                </div>
              }
            >
              {(trainer) => (
                <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:-translate-y-1">
                  <div class="card-body">
                    <div class="flex items-start justify-between mb-3">
                      <div
                        class={`badge ${trainer.is_coordinator ? "badge-primary" : "badge-ghost"} badge-lg`}
                      >
                        {trainer.is_coordinator ? "Coordinator" : "Trainer"}
                      </div>
                      <Show when={trainer.verified}>
                        <div class="badge badge-success badge-sm gap-1">
                          <Icon name="CircleCheck" size={12} />
                          Verified
                        </div>
                      </Show>
                    </div>

                    <h2 class="card-title text-xl mb-2 line-clamp-1">
                      {trainer.name}
                    </h2>

                    <div class="space-y-2 mb-4">
                      <div class="flex items-center gap-2">
                        <Icon
                          name="Mail"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80 truncate">
                          {trainer.email}
                        </span>
                      </div>
                      <div class="flex items-center gap-2">
                        <Icon
                          name="User"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80">
                          @{trainer.username}
                        </span>
                      </div>
                      <div class="flex items-center gap-2">
                        <Icon
                          name="Calendar"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80">
                          {formatDate(trainer.birthdayDate)}
                        </span>
                      </div>
                    </div>

                    <Show when={trainer.skills && trainer.skills.length > 0}>
                      <div class="divider my-2">Skills</div>
                      <div class="space-y-2 max-h-32 overflow-y-auto">
                        <For each={trainer.skills}>
                          {(skill) => (
                            <div class="flex items-center justify-between p-2 rounded-lg bg-base-200/50">
                              <span class="text-xs font-medium truncate">
                                Module: {skill.module_id}
                              </span>
                              <div class="badge badge-outline badge-xs">
                                Level {skill.competence_level}
                              </div>
                            </div>
                          )}
                        </For>
                      </div>
                    </Show>

                    <Show
                      when={
                        trainer.is_coordinator &&
                        trainer.coordinated_class_ids &&
                        Object.keys(trainer.coordinated_class_ids).length > 0
                      }
                    >
                      <div class="divider my-2">Coordinated Classes</div>
                      <div class="flex flex-wrap gap-1">
                        <For each={Object.entries(trainer.coordinated_class_ids)}>
                          {([classId, className]) => (
                            <div class="badge badge-primary badge-sm" title={classId}>
                              {className}
                            </div>
                          )}
                        </For>
                      </div>
                    </Show>
                  </div>
                </div>
              )}
            </For>
          </div>

          <Show when={filteredTrainers().length > 0}>
            <div class="mt-6 text-center text-sm text-base-content/60">
              Showing {filteredTrainers().length} of{" "}
              {trainersData()?.length || 0} trainers
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default Trainers;
