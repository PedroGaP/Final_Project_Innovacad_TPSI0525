import { createResource, createSignal, For, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Trainee } from "@/types/user";
import { Icon } from "@/components/Icon";
import { useI18n } from "@/hooks/useL18N";

const Trainees = () => {
  const api = useApi();
  const { t } = useI18n();
  const [traineesData] = createResource<Trainee[]>(api.fetchTraineesPublic);
  const [searchQuery, setSearchQuery] = createSignal("");

  const filteredTrainees = () => {
    const query = searchQuery().toLowerCase();
    const trainees = traineesData();
    if (!trainees) return [];
    if (!query) return trainees;

    return trainees.filter(
      (trainee) =>
        trainee.name?.toLowerCase().includes(query) ||
        trainee.email?.toLowerCase().includes(query) ||
        trainee.username?.toLowerCase().includes(query),
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
            {t("public.trainees.title")}
          </h1>
          <p class="text-base-content/60">{t("public.trainees.desc")}</p>
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
              placeholder={t("public.trainees.search_placeholder")}
              class="input input-bordered w-full pl-12 bg-base-100 shadow-sm"
              value={searchQuery()}
              onInput={(e) => setSearchQuery(e.currentTarget.value)}
            />
          </div>
        </div>

        <Show when={traineesData.loading}>
          <div class="flex justify-center items-center py-20">
            <span class="loading loading-spinner loading-lg text-primary"></span>
          </div>
        </Show>

        <Show when={traineesData.error}>
          <div class="alert alert-error shadow-lg">
            <Icon name="CircleAlert" size={24} />
            <span>{t("common.error_loading")}</span>
          </div>
        </Show>

        <Show when={!traineesData.loading && !traineesData.error}>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <For
              each={filteredTrainees()}
              fallback={
                <div class="col-span-full text-center py-20">
                  <Icon
                    name="Users"
                    size={64}
                    class="mx-auto mb-4 text-base-content/20"
                  />
                  <p class="text-lg text-base-content/60">
                    {searchQuery()
                      ? t("public.trainees.no_results")
                      : t("public.trainees.no_data")}
                  </p>
                </div>
              }
            >
              {(trainee) => (
                <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:-translate-y-1">
                  <div class="card-body">
                    <div class="flex items-start justify-between mb-3">
                      <div class="badge badge-ghost badge-lg">
                        {t("entity.trainee")}
                      </div>
                      <Show when={trainee.verified}>
                        <div class="badge badge-success badge-sm gap-1">
                          <Icon name="CircleCheck" size={12} />
                          Verified
                        </div>
                      </Show>
                    </div>

                    <h2 class="card-title text-xl mb-2 line-clamp-1">
                      {trainee.name}
                    </h2>

                    <div class="space-y-2 mb-4">
                      <div class="flex items-center gap-2">
                        <Icon
                          name="Mail"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80 truncate">
                          {trainee.email}
                        </span>
                      </div>
                      <div class="flex items-center gap-2">
                        <Icon
                          name="User"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80">
                          @{trainee.username}
                        </span>
                      </div>
                      <div class="flex items-center gap-2">
                        <Icon
                          name="Calendar"
                          size={16}
                          class="text-base-content/60"
                        />
                        <span class="text-sm text-base-content/80">
                          {formatDate(trainee.birthdayDate)}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </For>
          </div>

          <Show when={filteredTrainees().length > 0}>
            <div class="mt-6 text-center text-sm text-base-content/60">
              {t("public.trainees.showing_results", {
                count: filteredTrainees().length,
                total: traineesData()?.length || 0,
              })}
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default Trainees;
