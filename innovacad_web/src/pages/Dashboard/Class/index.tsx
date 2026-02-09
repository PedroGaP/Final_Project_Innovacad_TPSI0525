import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { type Class } from "@/types/class";
import { type Course } from "@/types/course";
import { type ModalFieldDefinition } from "@/components/Modal/Edit";
import { createResource, For, Show, createMemo } from "solid-js";
import toast from "solid-toast";
import capitalize from "@/utils/capitalize";
import type { Trainer } from "@/types/user";

const createEmptyClass = (): Class =>
  ({
    class_id: "",
    course_id: "",
    location: "",
    identifier: "",
    status: "starting",
    start_date_timestamp: Date.now(),
    end_date_timestamp: Date.now(),
    modules: [],
  }) as unknown as Class;

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";
  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";
  const pad = (n: number) => n.toString().padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
};

const validateClass = (klass: Class): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  if (!String(klass.course_id || "").trim()) errors.push("Course is required");
  if (!String(klass.location || "").trim()) errors.push("Location is required");
  if (!String(klass.identifier || "").trim())
    errors.push("Identifier is required");

  const status = String(klass.status || "")
    .trim()
    .toLowerCase();
  if (!status || !["starting", "ongoing", "finished"].includes(status)) {
    errors.push("Status is invalid");
  }

  if (!klass.start_date_timestamp) errors.push("Start Date is required");
  if (!klass.end_date_timestamp) errors.push("End Date is required");

  return { valid: errors.length === 0, errors };
};

const ClassesPage = () => {
  const api = useApi();

  const [classesData, { mutate }] = createResource<Class[]>(api.fetchClasses);
  const [courses] = createResource<Course[]>(api.fetchCourses);
  const [trainers] = createResource<Trainer[]>(api.fetchTrainers);

  const courseOptions = createMemo(() => {
    const list = courses();
    if (!list) return [];
    return list.map((course) => ({
      label: `${course.identifier} - ${course.name}`,
      value: course.course_id!,
    }));
  });

  const trainerOptions = createMemo(() => {
    const list = trainers();
    if (!list) return [];
    return list.map((t) => ({
      label: `${t.name} (${t.email})`,
      value: t.trainerId!,
    }));
  });

  const formFieldsConfig = createMemo<ModalFieldDefinition<Class>[]>(() => [
    {
      name: "course_id",
      label: "Course",
      type: "select",
      options: courseOptions(),
      required: true,
      placeholder: courses.loading ? "Loading courses..." : "Select a Course",
    },
    {
      name: "identifier",
      label: "Class Identifier",
      required: true,
    },
    {
      name: "location",
      label: "Location",
    },
    {
      name: "status",
      label: "Current Status",
      type: "select",
      options: [
        { label: "Starting", value: "starting" },
        { label: "On Going", value: "ongoing" },
        { label: "Finished", value: "finished" },
      ],
    },
    {
      name: "start_date_timestamp",
      label: "Start Date",
      type: "datetime-local",
    },
    {
      name: "end_date_timestamp",
      label: "End Date",
      type: "datetime-local",
    },
  ]);

  const handleSaveClass = async (klass: Class, original: Class | null) => {
    try {
      const validation = validateClass(klass);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      const modulesDto = (klass.modules || []).map((m: any) => ({
        course_module_id: m.courses_modules_id,
        trainer_id: m.trainer_id || null,
      }));

      if (original) {
        const changedFields: any = {};

        if (klass.course_id !== original.course_id)
          changedFields.course_id = klass.course_id;
        if (klass.location !== original.location)
          changedFields.location = klass.location;
        if (klass.identifier !== original.identifier)
          changedFields.identifier = klass.identifier;
        if (klass.status !== original.status)
          changedFields.status = klass.status;

        if (klass.start_date_timestamp !== original.start_date_timestamp)
          changedFields.start_date_timestamp = epochToDateTime(
            klass.start_date_timestamp!,
          );
        if (klass.end_date_timestamp !== original.end_date_timestamp)
          changedFields.end_date_timestamp = epochToDateTime(
            klass.end_date_timestamp!,
          );

        const currentIds = (klass.modules || []).map(
          (m) => m.courses_modules_id,
        );
        const originalIds = (original.modules || []).map(
          (m) => m.courses_modules_id,
        );

        const removeModulesIds = originalIds.filter(
          (id) => !currentIds.includes(id),
        );

        if (modulesDto.length > 0) {
          changedFields.add_modules = modulesDto;
        }

        if (removeModulesIds.length > 0) {
          changedFields.remove_modules_ids = removeModulesIds;
        }

        if (Object.keys(changedFields).length === 0) return;

        await api.updateClass(String(klass.class_id), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) => (u.class_id === klass.class_id ? klass : u)) || [],
        );
        toast.success(`Class updated successfully`);
      } else {
        const classObj = {
          course_id: String(klass.course_id),
          location: String(klass.location),
          identifier: String(klass.identifier),
          status: String(klass.status),
          start_date_timestamp: epochToDateTime(
            String(klass.start_date_timestamp),
          ),
          end_date_timestamp: epochToDateTime(String(klass.end_date_timestamp)),
          modules: modulesDto,
        };

        const newClass = await api.createClass(classObj);
        mutate((prev) => [...(prev || []), newClass]);
        toast.success("Class created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save class");
      }
      throw error;
    }
  };

  const confirmDelete = async (classToDelete: Class) => {
    await api.deleteClass(String(classToDelete.class_id));
    mutate(
      (prev) =>
        prev?.filter((c) => c.class_id !== classToDelete.class_id) || [],
    );
  };

  const renderModulesManager = (formData: Class, setFormData: any) => {
    const availableModules = createMemo(() => {
      const allCourses = courses();
      if (!allCourses || !formData.course_id) return [];

      const selectedCourse = allCourses.find(
        (c) => c.course_id === formData.course_id,
      );
      return selectedCourse?.modules || [];
    });

    const toggleModule = (courseModuleId: string) => {
      const currentModules = formData.modules || [];
      const exists = currentModules.some(
        (m) => m.courses_modules_id === courseModuleId,
      );

      if (exists) {
        setFormData((prev: Class) => ({
          ...prev,
          modules: prev.modules.filter(
            (m) => m.courses_modules_id !== courseModuleId,
          ),
        }));
      } else {
        setFormData((prev: Class) => ({
          ...prev,
          modules: [
            ...prev.modules,
            {
              courses_modules_id: courseModuleId,
              current_duration: 0,
              trainer_id: null,
            },
          ],
        }));
      }
    };

    const updateModuleTrainer = (courseModuleId: string, trainerId: string) => {
      setFormData((prev: Class) => ({
        ...prev,
        modules: prev.modules.map((m) =>
          m.courses_modules_id === courseModuleId
            ? { ...m, trainer_id: trainerId || null }
            : m,
        ),
      }));
    };

    return (
      <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm mt-6">
        <header class="mb-4 flex justify-between items-center">
          <div>
            <h3 class="text-lg font-bold">Class Modules & Trainers</h3>
            <p class="text-xs opacity-60">
              Select modules to include and assign a default trainer.
            </p>
          </div>
          <Show when={courses.loading || trainers.loading}>
            <span class="loading loading-spinner loading-sm text-primary"></span>
          </Show>
        </header>

        <Show
          when={formData.course_id}
          fallback={
            <div class="alert alert-info text-xs">
              Please select a Course Blueprint above first.
            </div>
          }
        >
          <div class="space-y-2 max-h-96 overflow-y-auto pr-2">
            <For
              each={availableModules()}
              fallback={
                <div class="text-sm opacity-50 p-2">
                  This course has no modules defined.
                </div>
              }
            >
              {(mod) => {
                const selectedModule = formData.modules?.find(
                  (m) => m.courses_modules_id === mod.courses_modules_id,
                );
                const isChecked = !!selectedModule;

                return (
                  <div
                    class={`p-3 rounded-lg border transition-all duration-200 ${isChecked ? "bg-base-200 border-primary shadow-sm" : "border-base-300"}`}
                  >
                    <div class="flex items-center justify-between">
                      <label class="flex items-center gap-3 cursor-pointer flex-1">
                        <input
                          type="checkbox"
                          class="checkbox checkbox-primary checkbox-sm"
                          checked={isChecked}
                          onChange={() => toggleModule(mod.courses_modules_id!)}
                        />
                        <div class="flex flex-col">
                          <span class="font-medium text-sm">
                            {mod.module_name || "Unnamed Module"}
                          </span>
                          <div class="flex gap-2 text-[10px] font-mono opacity-50">
                            <span>{mod.duration}h</span>
                          </div>
                        </div>
                      </label>
                    </div>

                    <Show when={isChecked}>
                      <div class="pl-8 mt-3 animate-fadeIn">
                        <div class="flex flex-col gap-1">
                          <span class="text-[10px] font-bold opacity-60 uppercase">
                            Assigned Trainer
                          </span>
                          <select
                            class="select select-bordered select-xs w-full max-w-xs"
                            value={selectedModule?.trainer_id || ""}
                            onChange={(e) =>
                              updateModuleTrainer(
                                mod.courses_modules_id!,
                                e.currentTarget.value,
                              )
                            }
                          >
                            <option value="">-- No Default Trainer --</option>
                            <For each={trainerOptions()}>
                              {(t) => (
                                <option value={t.value}>{t.label}</option>
                              )}
                            </For>
                          </select>
                        </div>
                      </div>
                    </Show>
                  </div>
                );
              }}
            </For>
          </div>

          <div class="mt-4 pt-2 border-t border-base-300 flex justify-between items-center">
            <span class="text-xs font-semibold uppercase opacity-50">
              Selected Modules
            </span>
            <div class="flex gap-2">
              <div class="badge badge-neutral badge-outline text-xs">
                {formData.modules?.length || 0} Total
              </div>
              <div class="badge badge-primary badge-outline text-xs">
                {formData.modules?.filter((m: any) => m.trainer_id).length || 0}{" "}
                w/ Trainer
              </div>
            </div>
          </div>
        </Show>
      </div>
    );
  };

  return (
    <EntityTable<Class>
      title="Manage Classes"
      data={classesData}
      handleEditClick={(klass) => ({ ...klass })}
      handleAddClick={() => createEmptyClass()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveClass}
      renderCustomFields={renderModulesManager}
      formFields={formFieldsConfig()}
      filter={(e: Class, search: string) => {
        const s = search.toLowerCase();
        return (
          (e.identifier?.toLowerCase().includes(s) ||
            e.location?.toLowerCase().includes(s) ||
            e.status?.toLowerCase().includes(s)) ??
          false
        );
      }}
      fields={[
        { formattedName: "Identifier", fieldName: "identifier", bigger: true },
        { formattedName: "Location", fieldName: "location" },
        {
          formattedName: "Status",
          fieldName: "status",
          capitalizeValue: false,
          smaller: true,
          customGeneration: (e) => {
            const colors: Record<string, string> = {
              starting: "badge-info",
              ongoing: "badge-success",
              finished: "badge-ghost",
            };
            const color =
              colors[String(e.status).toLowerCase()] || "badge-ghost";
            return (
              <div class={`badge ${color} badge-sm`}>
                {capitalize(e.status?.toString() || "")}
              </div>
            );
          },
        },
        {
          formattedName: "Modules Info",
          fieldName: "modules",
          customGeneration: (e: Class) => (
            <div class="flex flex-col items-end gap-1">
              <span class="badge badge-neutral badge-sm">
                {e.modules?.length || 0} Mods
              </span>
              <span class="text-[9px] opacity-50">
                {e.modules?.filter((m: any) => m.trainer_id).length || 0}{" "}
                Assigned
              </span>
            </div>
          ),
        },
        {
          formattedName: "Start Date",
          fieldName: "start_date_timestamp",
          customGeneration: (e) =>
            epochToDateTime(String(e.start_date_timestamp!)).split("T")[0],
        },
        {
          formattedName: "End Date",
          fieldName: "end_date_timestamp",
          customGeneration: (e) =>
            epochToDateTime(String(e.end_date_timestamp!)).split("T")[0],
        },
      ]}
    />
  );
};

export default ClassesPage;
