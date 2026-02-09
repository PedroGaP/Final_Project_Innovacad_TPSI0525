import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { Class } from "@/types/class";
import type { Enrollment } from "@/types/enrollment";
import { GradeTypeEnum, type Grade } from "@/types/grade";
import type { Trainee } from "@/types/user";
import { createMemo, createResource } from "solid-js";
import toast from "solid-toast";

interface GradeForm extends Grade {
  class_id?: string;
}

const normalizeId = (id: any) =>
  String(id || "")
    .trim()
    .toLowerCase();

const getMyTrainerId = (u: any): string => {
  if (!u) return "";
  return normalizeId(u.trainer_id || u.trainerId || u.id);
};

const createEmptyGrade = (): GradeForm =>
  ({
    grade_id: "",
    class_module_id: "",
    trainee_id: "",
    grade: 0,
    start_date_timestamp: "",
    grade_type: GradeTypeEnum.ASSESSMENT,
    class_id: "",
  }) as unknown as GradeForm;

const validateGrade = (grade: Grade): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  if (!String(grade.class_module_id || "").trim())
    errors.push("Class Module is required");
  if (!String(grade.trainee_id || "").trim())
    errors.push("Trainee is required");
  if (
    grade.grade === undefined ||
    grade.grade === null ||
    isNaN(Number(grade.grade))
  ) {
    errors.push("Grade is required and must be a number");
  } else if (Number(grade.grade) < 0 || Number(grade.grade) > 20) {
    errors.push("Grade must be between 0 and 20");
  }
  if (!String(grade.grade_type || "").trim())
    errors.push("Grade Type is required");
  return { valid: errors.length === 0, errors };
};

const getChangedFields = (oldGrade: Grade, newGrade: Grade) => {
  const changes: any = {};
  if (String(oldGrade.class_module_id) !== String(newGrade.class_module_id))
    changes.class_module_id = String(newGrade.class_module_id);
  if (String(oldGrade.trainee_id) !== String(newGrade.trainee_id))
    changes.trainee_id = String(newGrade.trainee_id);
  if (String(oldGrade.grade) !== String(newGrade.grade))
    changes.grade = String(newGrade.grade);
  if (String(oldGrade.grade_type) !== String(newGrade.grade_type))
    changes.grade_type = String(newGrade.grade_type);
  return changes;
};

const GradesPage = () => {
  const api = useApi();
  const { user } = useUserDetails();

  const [gradesData, { mutate }] = createResource<Grade[]>(api.fetchGrades);
  const [trainees] = createResource<Trainee[]>(api.fetchTrainees);
  const [classes] = createResource<Class[]>(api.fetchClasses);
  const [enrollments] = createResource<Enrollment[]>(api.fetchEnrollments);

  const myAllowedModuleIds = createMemo(() => {
    const u = user();
    if (!u) return [];
    if (u.role === "admin" || u.role === "coordinator") return null;

    const allClasses = classes();
    if (!allClasses) return [];

    const myId = getMyTrainerId(u);
    const allowedIds: string[] = [];

    allClasses.forEach((cls) => {
      cls.modules?.forEach((mod: any) => {
        const tId = normalizeId(mod.trainer_id || mod.trainerId);
        if (tId === myId) {
          const mId =
            mod.classes_modules_id ||
            mod.classesModulesId ||
            mod.courses_modules_id;
          if (mId) allowedIds.push(normalizeId(mId));
        }
      });
    });

    return [...new Set(allowedIds)];
  });

  const getTraineeName = (id: string | undefined) => {
    if (!id || !trainees()) return id;
    const found = trainees()?.find((t) => t.traineeId === id);
    return found ? found.name : id;
  };

  const getClassModuleName = (id: string | undefined) => {
    if (!id || !classes()) return id;
    const target = normalizeId(id);
    for (const cls of classes()!) {
      const foundMod = cls.modules?.find(
        (m: any) =>
          normalizeId(m.classes_modules_id || m.courses_modules_id) === target,
      );
      if (foundMod) return `${cls.identifier} - ${foundMod.module_name}`;
    }
    return id;
  };

  const findClassIdByModuleId = (modId: string): string => {
    const list = classes();
    if (!list || !modId) return "";
    const target = normalizeId(modId);
    for (const cls of list) {
      const found = cls.modules?.some(
        (m: any) =>
          normalizeId(m.classes_modules_id || m.courses_modules_id) === target,
      );
      if (found) return String(cls.class_id);
    }
    return "";
  };

  const filteredGradesData = createMemo(() => {
    const list = gradesData();
    const allowed = myAllowedModuleIds();
    if (!list) return [];
    if (allowed === null) return list;
    return list.filter((g) => allowed.includes(normalizeId(g.class_module_id)));
  });

  const simpleFields = createMemo<ModalFieldDefinition<GradeForm>[]>(() => [
    {
      name: "grade",
      label: "Grade (0-20)",
      type: "number",
      required: true,
    },
    {
      name: "grade_type",
      label: "Grade Type",
      type: "select",
      options: Object.values(GradeTypeEnum).map((value) => ({
        label: value,
        value: value,
      })),
      required: true,
    },
  ]);

  const handleSaveGrade = async (grade: GradeForm, original: Grade | null) => {
    const { class_id, ...payload } = grade;

    try {
      const validation = validateGrade(payload);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, payload);
        if (Object.keys(changedFields).length === 0) return;
        await api.updateGrade(String(grade.grade_id), changedFields);
        mutate(
          (prev) =>
            prev?.map((u) => (u.grade_id === grade.grade_id ? payload : u)) ||
            [],
        );
        toast.success(`Grade updated successfully`);
      } else {
        const gradeObj = {
          class_module_id: String(payload.class_module_id),
          trainee_id: String(payload.trainee_id),
          grade: String(payload.grade),
          grade_type: String(payload.grade_type),
        };
        const newGrade = await api.createGrade(gradeObj);
        mutate((prev) => [...(prev || []), newGrade]);
        toast.success("Grade created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save grade");
      }
      throw error;
    }
  };

  const confirmDelete = async (gradeToDelete: Grade) => {
    await api.deleteGrade(String(gradeToDelete.grade_id));
    mutate(
      (prev) =>
        prev?.filter((c) => c.grade_id !== gradeToDelete.grade_id) || [],
    );
    toast.success("Grade deleted");
  };

  return (
    <EntityTable<GradeForm>
      title="Manage Grades"
      data={filteredGradesData}
      handleEditClick={(grade) => ({
        ...grade,
        class_id: findClassIdByModuleId(grade.class_module_id!),
      })}
      handleAddClick={() => createEmptyGrade()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveGrade}
      formFields={simpleFields()}
      renderCustomFields={(formData, setFormData) => {
        const allowedModules = myAllowedModuleIds();

        const classOptions = (() => {
          const all = classes() || [];
          if (allowedModules === null) return all;

          return all.filter((c) =>
            c.modules?.some((m: any) => {
              const id = normalizeId(
                m.classes_modules_id ||
                  m.classesModulesId ||
                  m.courses_modules_id,
              );
              return allowedModules.includes(id);
            }),
          );
        })();

        const moduleOptions = (() => {
          if (!formData.class_id) return [];
          const selectedClass = classes()?.find(
            (c) => normalizeId(c.class_id) === normalizeId(formData.class_id),
          );
          if (!selectedClass || !selectedClass.modules) return [];

          return selectedClass.modules
            .filter((m: any) => {
              const id = normalizeId(
                m.classes_modules_id ||
                  m.classesModulesId ||
                  m.courses_modules_id,
              );
              return allowedModules === null || allowedModules.includes(id);
            })
            .map((m: any) => ({
              label: m.module_name,
              value: m.classes_modules_id || m.courses_modules_id,
            }));
        })();

        const traineeOptions = (() => {
          if (!formData.class_id) return [];
          const enrols = enrollments() || [];
          const studs = trainees() || [];

          return enrols
            .filter(
              (e) => normalizeId(e.class_id) === normalizeId(formData.class_id),
            )
            .map((e) => {
              const t = studs.find(
                (s) => normalizeId(s.traineeId) === normalizeId(e.trainee_id),
              );
              return t
                ? { label: `${t.name} (${t.email})`, value: t.traineeId! }
                : null;
            })
            .filter(Boolean) as { label: string; value: string }[];
        })();

        const isClassSelected = !!formData.class_id && formData.class_id !== "";

        return (
          <>
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text font-bold">Class</span>
              </label>
              <select
                class="select select-bordered w-full"
                value={formData.class_id || ""}
                onChange={(e) => {
                  const newVal = e.currentTarget.value;
                  setFormData((prev) => ({
                    ...prev,
                    class_id: newVal,
                    class_module_id: "",
                    trainee_id: "",
                  }));
                }}
              >
                <option value="" disabled>
                  Select Class
                </option>
                {classOptions.map((c) => (
                  <option value={String(c.class_id)}>
                    {c.identifier} ({c.location})
                  </option>
                ))}
              </select>
            </div>

            <div class="form-control w-full">
              <label class="label">
                <span class="label-text font-bold">Module</span>
              </label>
              <select
                class="select select-bordered w-full"
                value={formData.class_module_id || ""}
                disabled={!isClassSelected}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    class_module_id: e.currentTarget.value,
                  }))
                }
              >
                <option value="" disabled>
                  Select Module
                </option>
                {moduleOptions.map((m) => (
                  <option value={String(m.value)}>{m.label}</option>
                ))}
              </select>
            </div>

            <div class="form-control w-full">
              <label class="label">
                <span class="label-text font-bold">Trainee</span>
              </label>
              <select
                class="select select-bordered w-full"
                value={formData.trainee_id || ""}
                disabled={!isClassSelected}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    trainee_id: e.currentTarget.value,
                  }))
                }
              >
                <option value="" disabled>
                  Select Trainee
                </option>
                {traineeOptions.map((t) => (
                  <option value={String(t.value)}>{t.label}</option>
                ))}
              </select>
            </div>
          </>
        );
      }}
      filter={(e: Grade, search: string) => {
        const s = search.toLowerCase();
        const traineeName = getTraineeName(e.trainee_id)?.toLowerCase() || "";
        const moduleName =
          getClassModuleName(e.class_module_id)?.toLowerCase() || "";
        return (
          (String(e.grade).includes(s) ||
            traineeName.includes(s) ||
            moduleName.includes(s)) ??
          false
        );
      }}
      fields={[
        {
          formattedName: "ID",
          fieldName: "grade_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Class Module",
          fieldName: "class_module_id",
          customGeneration: (e) => (
            <span class="font-mono text-xs">
              {getClassModuleName(e.class_module_id)}
            </span>
          ),
        },
        {
          formattedName: "Trainee",
          fieldName: "trainee_id",
          customGeneration: (e) => (
            <div class="flex flex-col">
              <span class="font-medium">{getTraineeName(e.trainee_id)}</span>
            </div>
          ),
        },
        {
          formattedName: "Grade",
          fieldName: "grade",
          customGeneration: (e) => (
            <div
              class={`badge ${Number(e.grade) >= 10 ? "badge-success" : "badge-error"} badge-outline font-bold`}
            >
              {Number(e.grade).toFixed(1)}
            </div>
          ),
        },
        {
          formattedName: "Type",
          fieldName: "grade_type",
          capitalizeValue: true,
          smaller: true,
        },
      ]}
    />
  );
};

export default GradesPage;
