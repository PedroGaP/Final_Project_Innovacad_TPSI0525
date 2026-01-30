import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import type { Course } from "@/types/course";
import type { CourseModule } from "@/types/course_module";
import type { Module } from "@/types/module";
import { createMemo, createResource, For, Show } from "solid-js";
import toast from "solid-toast";

const unwrap = <T,>(data: T): T => JSON.parse(JSON.stringify(data));

const isSame = (a: any, b: any) => (a ?? "") === (b ?? "");

const createEmptyCourse = (): Course =>
  ({
    identifier: "",
    name: "",
    modules: [],
  }) as unknown as Course;

const validateCourse = (
  course: Course,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  if (!String(course.identifier || "").trim())
    errors.push("Identifier is required");
  if (!String(course.name || "").trim()) errors.push("Name is required");
  return { valid: errors.length === 0, errors };
};

const CoursesPage = () => {
  const api = useApi();

  const [coursesData, { mutate }] = createResource<Course[]>(api.fetchCourses);
  const [modulesData] = createResource<Module[]>(api.fetchModules);

  const findParentModuleId = (
    relationUuidOrId: string | null | undefined,
    allModules: CourseModule[],
  ) => {
    if (!relationUuidOrId) return null;

    const parentByUuid = allModules.find(
      (m) => m.courses_modules_id === relationUuidOrId,
    );
    if (parentByUuid) return parentByUuid.module_id;

    const parentById = allModules.find((m) => m.module_id === relationUuidOrId);
    if (parentById) return parentById.module_id;

    return null;
  };

  const handleSaveCourse = async (course: Course, original: Course | null) => {
    try {
      const validation = validateCourse(course);
      if (!validation.valid) {
        validation.errors.forEach((err) => toast.error(err));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields: any = {};

        if (course.identifier !== original.identifier)
          changedFields.identifier = course.identifier;
        if (course.name !== original.name) changedFields.name = course.name;

        const originalModules = original.modules || [];
        const currentModules = course.modules || [];

        const addedModules = currentModules.filter(
          (curr) =>
            !originalModules.some((orig) => orig.module_id === curr.module_id),
        );

        const removedModules = originalModules.filter(
          (orig) =>
            !currentModules.some((curr) => curr.module_id === orig.module_id),
        );

        const updatedModules = currentModules.filter((curr) => {
          const orig = originalModules.find(
            (o) => o.module_id === curr.module_id,
          );
          return (
            orig &&
            !isSame(
              curr.sequence_course_module_id,
              orig.sequence_course_module_id,
            )
          );
        });

        const modulesToSync = [...addedModules, ...updatedModules];

        if (modulesToSync.length > 0) {
          changedFields.add_modules_ids = modulesToSync.map((m) => ({
            module_id: m.module_id,
            sequence_course_module_id: findParentModuleId(
              m.sequence_course_module_id,
              currentModules,
            ),
          }));
        }

        if (removedModules.length > 0) {
          changedFields.remove_modules_ids = removedModules
            .map((m) => m.courses_modules_id)
            .filter(Boolean);
        }

        if (Object.keys(changedFields).length === 0) {
          toast.success("No changes detected");
          return;
        }

        const cleanPayload = unwrap(changedFields);
        console.log("Sending Payload:", cleanPayload);

        await api.updateCourse(String(course.course_id), cleanPayload);

        mutate(
          (prev) =>
            prev?.map((c) => (c.course_id === course.course_id ? course : c)) ||
            [],
        );
        toast.success("Course updated successfully");
      } else {
        const newCourseObj = {
          identifier: course.identifier,
          name: course.name,
          add_modules_ids: (course.modules || []).map((m) => ({
            module_id: m.module_id,
            sequence_course_module_id: m.sequence_course_module_id || null,
          })),
        };

        const cleanPayload = unwrap(newCourseObj);
        const created = await api.createCourse(cleanPayload);
        mutate((prev) => [...(prev || []), created]);
        toast.success("Course created successfully");
      }
    } catch (error) {
      console.error(error);
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error("Failed to save course.");
      }
      throw error;
    }
  };

  const confirmDelete = async (courseToDelete: Course) => {
    await api.deleteCourse(String(courseToDelete.course_id));
    mutate(
      (prev) =>
        prev?.filter((c) => c.course_id !== courseToDelete.course_id) || [],
    );
    toast.success("Course deleted");
  };

  const renderModulesManager = (formData: Course, setFormData: any) => {
    // Lista de módulos disponíveis (vem da API)
    const availableModules = createMemo(() => modulesData() || []);

    // Lista de alvos válidos para sequência (usamos os módulos já selecionados na checkbox)
    const validSequenceTargets = createMemo(() => formData.modules || []);

    /**
     * TRADUTOR DE LEITURA (State -> UI)
     * Converte o valor "estranho" que está no estado (UUID da relação ou ID temporário)
     * para o module_id que a Select Box entende.
     */
    const getSelectValue = (savedValue: string | null | undefined): string => {
      if (!savedValue) return ""; // Se for null na BD, devolve vazio (None)

      // CASO 1: O valor guardado é um UUID de Relação (Vem da BD)
      // Temos de encontrar a qual módulo este UUID pertence.
      const parentByUuid = formData.modules?.find(
        (m) => m.courses_modules_id === savedValue,
      );
      if (parentByUuid) return parentByUuid.module_id;

      // CASO 2: O valor guardado já é um module_id (Seleção local recente)
      // Isto acontece quando acabas de selecionar um módulo que ainda não foi à BD.
      const parentById = formData.modules?.find(
        (m) => m.module_id === savedValue,
      );
      if (parentById) return parentById.module_id;

      // Fallback: Se não encontrarmos nada (ex: dados inconsistentes), devolve vazio
      return "";
    };

    /**
     * TRADUTOR DE ESCRITA (UI -> State)
     * Quando o user escolhe uma opção, tentamos guardar o UUID da relação (se existir).
     * Se não existir (módulo novo), guardamos o module_id temporariamente.
     */
    const handleSequenceChange = (
      currentModuleId: string,
      targetParentModuleId: string | null, // O user selecionou um module_id na combobox
    ) => {
      // Encontrar o objeto completo do "Pai" escolhido
      const targetParent = formData.modules?.find(
        (m) => m.module_id === targetParentModuleId,
      );

      // Decidir o que guardar:
      // 1. O UUID da relação (se o pai já existir na BD)
      // 2. O ID do módulo (se o pai for novo e ainda não tiver UUID)
      // 3. Null (se escolheu "None")
      const valueToSave =
        targetParent?.courses_modules_id || targetParentModuleId || null;

      setFormData((prev: Course) => ({
        ...prev,
        modules: (prev.modules || []).map((m) =>
          m.module_id === currentModuleId
            ? { ...m, sequence_course_module_id: valueToSave }
            : m,
        ),
      }));
    };

    const toggleModule = (selectedModule: Module) => {
      const currentModules = formData.modules || [];
      const exists = currentModules.some(
        (m) => m.module_id === selectedModule.module_id,
      );

      let updatedModules: CourseModule[];
      if (exists) {
        updatedModules = currentModules.filter(
          (m) => m.module_id !== selectedModule.module_id,
        );
      } else {
        updatedModules = [
          ...currentModules,
          {
            module_id: selectedModule.module_id,
            module_name: selectedModule.name,
            duration: selectedModule.duration,
            sequence_course_module_id: null,
          } as CourseModule,
        ];
      }
      setFormData((prev: Course) => ({ ...prev, modules: updatedModules }));
    };

    return (
      <div class="form-control w-full border p-4 rounded-xl bg-base-100 shadow-sm mt-6">
        <header class="mb-4 flex justify-between items-center">
          <div>
            <h3 class="text-lg font-bold">Course Modules</h3>
            <p class="text-xs opacity-60">
              {formData.modules?.length || 0} modules selected
            </p>
          </div>
        </header>

        <div class="space-y-3 max-h-80 overflow-y-auto pr-2">
          <For each={availableModules()}>
            {(mod) => {
              const selectedEntry = () =>
                formData.modules?.find((m) => m.module_id === mod.module_id);
              const isChecked = () => !!selectedEntry();

              return (
                <div
                  class={`flex flex-col p-3 rounded-lg border transition-all ${
                    isChecked()
                      ? "border-primary bg-primary/5"
                      : "border-base-300"
                  }`}
                >
                  <div class="flex items-center justify-between">
                    <div class="flex flex-col">
                      <span class="font-medium text-sm">{mod.name}</span>
                      <span class="text-[10px] opacity-50">
                        {mod.duration} hours
                      </span>
                    </div>
                    <input
                      type="checkbox"
                      class="checkbox checkbox-primary checkbox-sm"
                      checked={isChecked()}
                      onChange={() => toggleModule(mod)}
                    />
                  </div>

                  <Show when={isChecked()}>
                    <div class="mt-3 flex items-center gap-2 animate-in fade-in slide-in-from-top-1">
                      <span class="text-[10px] font-bold uppercase opacity-40">
                        Previous:
                      </span>

                      {/* AQUI ESTÁ O SELECT FIXADO */}
                      <select
                        class="select select-bordered select-xs flex-1"
                        // 1. O value passa pelo Tradutor de Leitura
                        // Isto garante que o select nunca recebe um UUID estranho
                        value={getSelectValue(
                          selectedEntry()?.sequence_course_module_id,
                        )}
                        // 2. O onChange usa o Tradutor de Escrita
                        onChange={(e) =>
                          handleSequenceChange(
                            mod.module_id!,
                            e.currentTarget.value || null,
                          )
                        }
                      >
                        <option value="">None</option>
                        <For each={validSequenceTargets()}>
                          {(m) => (
                            <Show when={m.module_id !== mod.module_id}>
                              {/* 3. A Option usa SEMPRE o module_id como chave estável */}
                              <option value={m.module_id}>
                                After {m.module_name}
                              </option>
                            </Show>
                          )}
                        </For>
                      </select>
                    </div>
                  </Show>
                </div>
              );
            }}
          </For>
        </div>
      </div>
    );
  };

  const formFieldsConfig = createMemo<ModalFieldDefinition<Course>[]>(() => [
    { label: "Identifier", name: "identifier", required: true, type: "text" },
    { label: "Course Name", name: "name", required: true, type: "text" },
  ]);

  return (
    <EntityTable<Course>
      title="Manage Courses"
      data={coursesData}
      handleEditClick={(course) => ({ ...course })}
      handleAddClick={() => createEmptyCourse()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveCourse}
      renderCustomFields={renderModulesManager}
      formFields={formFieldsConfig()}
      filter={(e: Course, search: string) => {
        const s = search.toLowerCase();
        return (
          (e.identifier?.toLowerCase().includes(s) ||
            e.name?.toLowerCase().includes(s)) ??
          false
        );
      }}
      fields={[
        { formattedName: "Identifier", fieldName: "identifier", bigger: true },
        { formattedName: "Name", fieldName: "name" },
        {
          formattedName: "Modules",
          fieldName: "modules",
          customGeneration: (e: Course) => (
            <span class="badge badge-neutral badge-outline">
              {e.modules?.length || 0} Modules
            </span>
          ),
        },
      ]}
    />
  );
};

export default CoursesPage;
