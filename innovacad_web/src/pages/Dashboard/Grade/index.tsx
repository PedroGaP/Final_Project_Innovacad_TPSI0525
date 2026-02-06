import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import type { Class } from "@/types/class";
import type { Enrollment } from "@/types/enrollment";
import { GradeTypeEnum, type Grade } from "@/types/grade";
import type { Schedule } from "@/types/schedule";
import type { Trainee } from "@/types/user";
import { createMemo, createResource } from "solid-js";
import toast from "solid-toast";

const createEmptyGrade = (): Grade =>
  ({
    grade_id: "",
    class_module_id: "",
    trainee_id: "",
    grade: 0,
    start_date_timestamp: "",
    grade_type: GradeTypeEnum.ASSESSMENT,
  }) as unknown as Grade;

const validateGrade = (grade: Grade): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  if (!String(grade.class_module_id || "").trim()) {
    errors.push("Class Module is required");
  }

  if (!String(grade.trainee_id || "").trim()) {
    errors.push("Trainee is required");
  }

  if (
    grade.grade === undefined ||
    grade.grade === null ||
    isNaN(Number(grade.grade))
  ) {
    errors.push("Grade is required and must be a number");
  } else if (Number(grade.grade) < 0 || Number(grade.grade) > 20) {
    errors.push("Grade must be between 0 and 20");
  }

  const grade_type = String(grade.grade_type || "").trim();
  if (!grade_type) {
    errors.push("Grade Type is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
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
  const [mySchedules] = createResource<Schedule[]>(api.fetchUserSchedules);

  const myAllowedModuleIds = createMemo(() => {
    const u = user();
    if (u?.role === "admin" || u?.role === "coordinator") return null;

    const schedules = mySchedules();
    if (!schedules) return [];

    return [...new Set(schedules.map((s) => s.class_module_id))];
  });

  const myAllowedClassIds = createMemo(() => {
    const u = user();
    const allowedModules = myAllowedModuleIds();

    if (allowedModules === null) return null;

    const listClasses = classes();
    if (!listClasses) return [];

    const allowedClassIds: string[] = [];

    listClasses.forEach((cls) => {
      const hasModule = cls.modules?.some((m) => {
        const modId = (m as any).classes_modules_id || m.courses_modules_id;
        return allowedModules.includes(modId);
      });
      if (hasModule && cls.class_id) allowedClassIds.push(cls.class_id);
    });

    return allowedClassIds;
  });

  const moduleOptions = createMemo(() => {
    const list = classes();
    const allowedModules = myAllowedModuleIds();

    if (!list) return [];

    const options: { label: string; value: string }[] = [];

    list.forEach((cls) => {
      if (cls.modules && cls.modules.length > 0) {
        cls.modules.forEach((mod) => {
          const valueId =
            (mod as any).classes_modules_id || mod.courses_modules_id;

          if (allowedModules === null || allowedModules.includes(valueId)) {
            options.push({
              label: `${cls.identifier} - ${mod.module_name} (${cls.location})`,
              value: valueId,
            });
          }
        });
      }
    });

    return options;
  });

  const studentOptions = createMemo(() => {
    const allTrainees = trainees();
    const allEnrollments = enrollments();
    const allowedClasses = myAllowedClassIds();

    if (!allTrainees || !allEnrollments) return [];

    const validEnrollments = allEnrollments.filter((e) => {
      return allowedClasses === null || allowedClasses.includes(e.class_id!);
    });

    return validEnrollments
      .map((enrol) => {
        const t = allTrainees.find((u) => u.traineeId === enrol.trainee_id);
        if (!t) return null;
        return {
          label: `${t.name} (${t.email})`,
          value: t.traineeId!,
        };
      })
      .filter((opt) => opt !== null) as { label: string; value: string }[];
  });

  const filteredGradesData = createMemo(() => {
    const list = gradesData();
    const allowedModules = myAllowedModuleIds();

    if (!list) return [];
    if (allowedModules === null) return list;

    return list.filter((g) => allowedModules.includes(g.class_module_id));
  });

  const formFieldsConfig = createMemo<ModalFieldDefinition<Grade>[]>(() => [
    {
      name: "class_module_id",
      label: "Class Module",
      type: "select",
      options: moduleOptions(),
      required: true,
      placeholder: classes.loading ? "Loading modules..." : "Select Module",
    },
    {
      name: "trainee_id",
      label: "Trainee",
      type: "select",
      options: studentOptions(),
      required: true,
      placeholder: trainees.loading ? "Loading trainees..." : "Select Trainee",
    },
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

  const handleSaveGrade = async (grade: Grade, original: Grade | null) => {
    try {
      const validation = validateGrade(grade);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, grade);
        if (Object.keys(changedFields).length === 0) return;

        await api.updateGrade(String(grade.grade_id), changedFields);
        mutate(
          (prev) =>
            prev?.map((u) => (u.grade_id === grade.grade_id ? grade : u)) || [],
        );
        toast.success(`Grade updated successfully`);
      } else {
        const gradeObj = {
          class_module_id: String(grade.class_module_id),
          trainee_id: String(grade.trainee_id),
          grade: String(grade.grade),
          grade_type: String(grade.grade_type),
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

  const getTraineeName = (id: string | undefined) => {
    if (!id || !trainees()) return id;
    const found = trainees()?.find((t) => t.traineeId === id);
    return found ? found.name : id;
  };

  const getClassModuleName = (id: string | undefined) => {
    if (!id || !classes()) return id;
    for (const cls of classes()!) {
      const foundMod = cls.modules?.find(
        (m: any) => m.classes_modules_id === id || m.courses_modules_id === id,
      );
      if (foundMod) {
        return `${cls.identifier} - ${foundMod.module_name}`;
      }
    }
    return id;
  };

  return (
    <EntityTable<Grade>
      title="Manage Grades"
      data={filteredGradesData}
      handleEditClick={(grade) => ({ ...grade })}
      handleAddClick={() => createEmptyGrade()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveGrade}
      formFields={formFieldsConfig()}
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
              class={`badge ${
                Number(e.grade) >= 10 ? "badge-success" : "badge-error"
              } badge-outline font-bold`}
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
