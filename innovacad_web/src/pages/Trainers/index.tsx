import { createResource, createSignal, For, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Trainer } from "@/types/user";
import { Icon } from "@/components/Icon";
import { useI18n } from "@/hooks/useL18N";

const Trainers = () => {
  const api = useApi();
  const { t } = useI18n();
  const [trainersData] = createResource<Trainer[]>(api.fetchTrainersPublic);
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
            {t("public.trainers.title")}
          </h1>
          <p class="text-base-content/60">{t("public.trainers.desc")}</p>
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
              placeholder={t("public.trainers.search_placeholder")}
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
            <span>{t("common.error_loading")}</span>
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
                      ? t("public.trainers.no_results")
                      : t("public.trainers.no_data")}
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
                        {trainer.is_coordinator
                          ? t("entity.coordinator")
                          : t("entity.trainer")}
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
                      <div class="divider my-2">{t("entity.modules")}</div>
                      <div class="space-y-2 max-h-32 overflow-y-auto">
                        <For each={trainer.skills}>
                          {(skill) => (
                            <div class="flex items-center justify-between p-2 rounded-lg bg-base-200/50">
                              <span class="text-xs font-medium truncate">
                                {t("entity.module")}: {skill.module_id}
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
                      <div class="divider my-2">
                        {t("public.trainers.coordinated_classes")}
                      </div>
                      <div class="flex flex-wrap gap-1">
                        <For
                          each={Object.entries(trainer.coordinated_class_ids)}
                        >
                          {([classId, className]) => (
                            <div
                              class="badge badge-primary badge-sm"
                              title={classId}
                            >
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
              {t("public.trainers.showing_results", {
                count: filteredTrainers().length,
                total: trainersData()?.length || 0,
              })}
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default Trainers;
