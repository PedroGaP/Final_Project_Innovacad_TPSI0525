import { createResource, createSignal, For, Show } from "solid-js";
import { useApi } from "@/hooks/useApi";
import type { Course } from "@/types/course";
import { Icon } from "@/components/Icon";
import { useI18n } from "@/hooks/useL18N";

const CoursesPage = () => {
  const api = useApi();
  const { t } = useI18n();
  const [coursesData] = createResource<Course[]>(api.fetchCourses);
  const [searchQuery, setSearchQuery] = createSignal("");

  const filteredCourses = () => {
    const query = searchQuery().toLowerCase();
    const courses = coursesData();
    if (!courses) return [];
    if (!query) return courses;

    return courses.filter(
      (course) =>
        course.identifier?.toLowerCase().includes(query) ||
        course.name?.toLowerCase().includes(query) ||
        course.area?.toLowerCase().includes(query),
    );
  };

  return (
    <div class="min-h-screen bg-base-200 p-6">
      <div class="w-full">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2 text-primary">
            {t("public.courses.title")}
          </h1>
          <p class="text-base-content/60">
            {t("public.courses.desc")}
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
              placeholder={t("public.courses.search_placeholder")}
              class="input input-bordered w-full pl-12 bg-base-100 shadow-sm"
              value={searchQuery()}
              onInput={(e) => setSearchQuery(e.currentTarget.value)}
            />
          </div>
        </div>

        <Show when={coursesData.loading}>
          <div class="flex justify-center items-center py-20">
            <span class="loading loading-spinner loading-lg text-primary"></span>
          </div>
        </Show>

        <Show when={coursesData.error}>
          <div class="alert alert-error shadow-lg">
            <Icon name="CircleAlert" size={24} />
            <span>{t("common.error_loading")}</span>
          </div>
        </Show>

        <Show when={!coursesData.loading && !coursesData.error}>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <For
              each={filteredCourses()}
              fallback={
                <div class="col-span-full text-center py-20">
                  <Icon
                    name="BookOpen"
                    size={64}
                    class="mx-auto mb-4 text-base-content/20"
                  />
                  <p class="text-lg text-base-content/60">
                    {searchQuery()
                      ? t("public.courses.no_results")
                      : t("public.courses.no_data")}
                  </p>
                </div>
              }
            >
              {(course) => (
                <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300 hover:-translate-y-1">
                  <div class="card-body">
                    <div class="flex items-start justify-between mb-3">
                      <div class="badge badge-primary badge-lg font-mono">
                        {course.identifier}
                      </div>
                      <div class="badge badge-ghost badge-sm">
                        {course.modules?.length || 0} {t("public.courses.modules")}
                      </div>
                    </div>

                    <h2 class="card-title text-xl mb-2 line-clamp-2">
                      {course.name}
                    </h2>

                    <div class="flex items-center gap-2 mb-4">
                      <Icon name="Tag" size={16} class="text-base-content/60" />
                      <span class="text-sm text-base-content/80">
                        {course.area}
                      </span>
                    </div>

                    <Show when={course.modules && course.modules.length > 0}>
                      <div class="divider my-2">{t("public.courses.modules_title")}</div>
                      <div class="space-y-2 max-h-48 overflow-y-auto">
                        <For each={course.modules}>
                          {(module) => (
                            <div class="flex items-center justify-between p-2 rounded-lg bg-base-200/50 hover:bg-base-200 transition-colors">
                              <div class="flex-1">
                                <p class="text-sm font-medium line-clamp-1">
                                  {module.module_name}
                                </p>
                              </div>
                              <div class="badge badge-outline badge-sm">
                                {module.duration}h
                              </div>
                            </div>
                          )}
                        </For>
                      </div>
                    </Show>

                    <Show when={!course.modules || course.modules.length === 0}>
                      <div class="alert alert-info text-xs mt-2">
                        <Icon name="Info" size={14} />
                        <span>{t("public.courses.no_modules")}</span>
                      </div>
                    </Show>
                  </div>
                </div>
              )}
            </For>
          </div>

          <Show when={filteredCourses().length > 0}>
            <div class="mt-6 text-center text-sm text-base-content/60">
              {t("public.courses.showing_results", {
                count: filteredCourses().length,
                total: coursesData()?.length || 0,
              })}
            </div>
          </Show>
        </Show>
      </div>
    </div>
  );
};

export default CoursesPage;
