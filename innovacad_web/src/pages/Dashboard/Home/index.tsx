import { Icon } from "@/components/Icon";
import { useApi } from "@/hooks/useApi";
import { createResource, For, Show } from "solid-js";

const StatCard = (props: {
  title: string;
  value: number | string;
  icon: string;
  color: string;
}) => (
  <div class="stats shadow bg-base-100 border border-base-200">
    <div class="stat">
      <div class={`stat-figure text-${props.color}`}>
        <Icon name={props.icon as any} size={32} />
      </div>
      <div class="stat-title">{props.title}</div>
      <div class={`stat-value text-${props.color}`}>{props.value}</div>
      <div class="stat-desc">Atualizado agora</div>
    </div>
  </div>
);

const DashboardHome = () => {
  const { fetchStatistics } = useApi();
  const [stats] = createResource(fetchStatistics);

  return (
    <div class="space-y-8 p-2">
      <div class="flex justify-between items-center">
        <Show when={stats.loading}>
          <span class="loading loading-spinner text-primary"></span>
        </Show>
      </div>

      <Show
        when={!stats.loading && stats()}
        fallback={<div class="skeleton h-32 w-full"></div>}
      >
        {(data) => (
          <>
            <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <StatCard
                title="Cursos Terminados"
                value={data().total_finished_classes}
                icon="CheckCircle"
                color="success"
              />
              <StatCard
                title="Cursos a Decorrer"
                value={data().total_ongoing_classes}
                icon="Clock"
                color="info"
              />
              <StatCard
                title="Formandos Ativos"
                value={data().total_active_trainees}
                icon="Users"
                color="primary"
              />
            </section>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
              <section class="card bg-base-100 shadow border border-base-200">
                <div class="card-body">
                  <h3 class="card-title text-sm uppercase opacity-70 mb-4">
                    <Icon name="ChartPie" size={18} /> Cursos por Área
                  </h3>
                  <div class="flex flex-col gap-4">
                    <For each={data().courses_by_area}>
                      {(area: any) => (
                        <div class="w-full">
                          <div class="flex justify-between mb-1">
                            <span class="text-sm font-semibold">
                              {area.area}
                            </span>
                            <span class="text-sm opacity-70">
                              {area.count} curso(s)
                            </span>
                          </div>
                          <progress
                            class="progress progress-primary w-full"
                            value={area.count}
                            max={
                              Math.max(
                                ...data().courses_by_area.map(
                                  (a: any) => a.count,
                                ),
                              ) + 2
                            }
                          />
                        </div>
                      )}
                    </For>
                    <Show when={data().courses_by_area.length === 0}>
                      <p class="text-sm opacity-50 italic">
                        Sem dados de cursos.
                      </p>
                    </Show>
                  </div>
                </div>
              </section>

              <section class="card bg-base-100 shadow border border-base-200">
                <div class="card-body p-0">
                  <div class="p-6 pb-2">
                    <h3 class="card-title text-sm uppercase opacity-70">
                      <Icon name="Award" size={18} /> Top 10 Formadores (Horas)
                    </h3>
                  </div>
                  <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                      <thead>
                        <tr>
                          <th>#</th>
                          <th>Nome</th>
                          <th class="text-right">Horas Lecionadas</th>
                        </tr>
                      </thead>
                      <tbody>
                        <For each={data().top_trainers}>
                          {(trainer: any, index) => (
                            <tr class="hover">
                              <th class="opacity-50 w-12">{index() + 1}</th>
                              <td class="font-medium">{trainer.name}</td>
                              <td class="text-right font-mono">
                                {Number(trainer.total_hours).toFixed(1)}h
                              </td>
                            </tr>
                          )}
                        </For>
                        <Show when={data().top_trainers.length === 0}>
                          <tr>
                            <td colspan={3} class="text-center opacity-50 py-4">
                              Ainda sem registo de aulas.
                            </td>
                          </tr>
                        </Show>
                      </tbody>
                    </table>
                  </div>
                </div>
              </section>
            </div>
          </>
        )}
      </Show>
    </div>
  );
};

export default DashboardHome;
