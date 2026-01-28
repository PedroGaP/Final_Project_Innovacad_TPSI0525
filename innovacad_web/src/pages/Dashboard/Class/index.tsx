import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { type Class } from "@/types/class";
import { type Course } from "@/types/course";
import { createResource, For, Show, createMemo } from "solid-js";
import toast from "solid-toast";

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

  const handleSaveClass = async (klass: Class, original: Class | null) => {
    try {
      const validation = validateClass(klass);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

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
          changedFields.start_date_timestamp = klass.start_date_timestamp;
        if (klass.end_date_timestamp !== original.end_date_timestamp)
          changedFields.end_date_timestamp = klass.end_date_timestamp;

        const originalIds = (original.modules || []).map(
          (m) => m.courses_modules_id,
        );
        const currentIds = (klass.modules || []).map(
          (m) => m.courses_modules_id,
        );

        const addModulesIds = currentIds.filter(
          (id) => !originalIds.includes(id),
        );
        const removeClassesModulesIds = originalIds.filter(
          (id) => !currentIds.includes(id),
        );

        if (addModulesIds.length > 0)
          changedFields.add_modules_ids = addModulesIds;
        if (removeClassesModulesIds.length > 0)
          changedFields.remove_classes_modules_ids = removeClassesModulesIds;

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
          start_date_timestamp: String(klass.start_date_timestamp),
          end_date_timestamp: String(klass.end_date_timestamp),
          modules_ids: (klass.modules || []).map((m) => m.courses_modules_id),
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

  const renderCustomFields = (formData: Class, setFormData: any) => {
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
            { courses_modules_id: courseModuleId, current_duration: 0 },
          ],
        }));
      }
    };

    return (
      <>
        <div class="form-control w-full mb-4">
          <label class="label">
            <span class="label-text">Course Blueprint</span>
          </label>
          <select
            class="select select-bordered w-full"
            value={formData.course_id}
            onChange={(e) => {
              const newCourseId = e.currentTarget.value;
              if (newCourseId !== formData.course_id) {
                setFormData((prev: Class) => ({
                  ...prev,
                  course_id: newCourseId,
                  modules: [],
                }));
              }
            }}
          >
            <option value="" disabled>
              Select a Course
            </option>
            <For each={courses()}>
              {(course) => (
                <option value={course.course_id}>
                  {course.identifier} - {course.name}
                </option>
              )}
            </For>
          </select>
        </div>

        <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm">
          <header class="mb-4 flex justify-between items-center">
            <div>
              <h3 class="text-lg font-bold">Class Modules</h3>
              <p class="text-xs opacity-60">
                Select modules to include in this class.
              </p>
            </div>
            <Show when={courses.loading}>
              <span class="loading loading-spinner loading-sm text-primary"></span>
            </Show>
          </header>

          <Show
            when={formData.course_id}
            fallback={
              <div class="alert alert-info text-xs">
                Please select a Course Blueprint above.
              </div>
            }
          >
            <div class="space-y-2 max-h-64 overflow-y-auto pr-2">
              <For
                each={availableModules()}
                fallback={
                  <div class="text-sm opacity-50 p-2">
                    This course has no modules defined.
                  </div>
                }
              >
                {(mod) => {
                  const isChecked = () =>
                    formData.modules?.some(
                      (m) => m.courses_modules_id === mod.courses_modules_id,
                    );

                  return (
                    <label class="flex items-center justify-between p-3 rounded-lg border border-base-300 hover:bg-base-200 cursor-pointer transition-all">
                      <div class="flex flex-col">
                        <span class="font-medium text-sm">
                          {mod.module_name || "Unnamed Module"}
                        </span>
                        <div class="flex gap-2 text-[10px] font-mono opacity-50">
                          <span>{mod.duration}h</span>
                          <span>|</span>
                          <span>
                            ID: {mod.courses_modules_id.substring(0, 8)}...
                          </span>
                        </div>
                      </div>
                      <input
                        type="checkbox"
                        class="checkbox checkbox-primary"
                        checked={isChecked()}
                        onChange={() => toggleModule(mod.courses_modules_id)}
                      />
                    </label>
                  );
                }}
              </For>
            </div>

            <div class="mt-4 pt-2 border-t border-base-300 flex justify-between items-center">
              <span class="text-xs font-semibold uppercase opacity-50">
                Selected
              </span>
              <div class="badge badge-secondary">
                {formData.modules?.length || 0}
              </div>
            </div>
          </Show>
        </div>
      </>
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
      renderCustomFields={renderCustomFields}
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
          capitalizeValue: true,
          smaller: true,
          customGeneration: (e) => {
            const colors: Record<string, string> = {
              starting: "badge-info",
              ongoing: "badge-success",
              finished: "badge-ghost",
            };
            const color =
              colors[String(e.status).toLowerCase()] || "badge-ghost";
            return <div class={`badge ${color} badge-sm`}>{e.status}</div>;
          },
        },
        {
          formattedName: "Modules",
          fieldName: "modules",
          customGeneration: (e: Class) => (
            <span class="badge badge-neutral badge-outline">
              {e.modules?.length || 0} Modules
            </span>
          ),
        },
        {
          formattedName: "Start Date",
          fieldName: "start_date_timestamp",
          customGeneration: (e) =>
            epochToDateTime(String(e.start_date_timestamp!)),
        },
        {
          formattedName: "End Date",
          fieldName: "end_date_timestamp",
          customGeneration: (e) =>
            epochToDateTime(String(e.end_date_timestamp!)),
        },
      ]}
    />
  );
};

export default ClassesPage;
