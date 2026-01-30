import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { GradeTypeEnum, type Grade } from "@/types/grade";
import type { Trainee } from "@/types/user";
import type { Class } from "@/types/class";
import { createMemo, createResource } from "solid-js";
import toast from "solid-toast";

const createEmptyGrade = (): Grade =>
  ({
    grade_id: "",
    class_module_id: "",
    trainee_id: "",
    grade: 0,
    start_date_timestamp: "",
    grade_type: GradeTypeEnum.FINAL,
  }) as unknown as Grade;

const validateGrade = (grade: Grade): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const grade_module_id = String(grade.class_module_id || "").trim();
  if (!grade_module_id) {
    errors.push("Class Module is required");
  }

  const trainee_id = String(grade.trainee_id || "").trim();
  if (!trainee_id) {
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
  } else if (
    !Object.values(GradeTypeEnum).includes(grade_type as GradeTypeEnum)
  ) {
    errors.push("Grade Type is invalid");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldGrade: Grade,
  newGrade: Grade,
): {
  class_module_id?: string;
  trainee_id?: string;
  grade?: string;
  grade_type?: string;
} => {
  const changes: any = {};

  if (String(oldGrade.class_module_id) !== String(newGrade.class_module_id)) {
    changes.class_module_id = String(newGrade.class_module_id);
  }

  if (String(oldGrade.trainee_id) !== String(newGrade.trainee_id)) {
    changes.trainee_id = String(newGrade.trainee_id);
  }

  if (String(oldGrade.grade) !== String(newGrade.grade)) {
    changes.grade = String(newGrade.grade);
  }

  if (String(oldGrade.grade_type) !== String(newGrade.grade_type)) {
    changes.grade_type = String(newGrade.grade_type);
  }

  return changes;
};

const GradesPage = () => {
  const api = useApi();

  const [gradesData, { mutate }] = createResource<Grade[]>(api.fetchGrades);

  const [trainees] = createResource<Trainee[]>(api.fetchTrainees);
  const [classes] = createResource<Class[]>(api.fetchClasses);

  const traineeOptions = createMemo(() => {
    const list = trainees();
    if (!list) return [];
    return list.map((t) => ({
      label: `${t.name} (${t.email})`,
      value: t.traineeId!,
    }));
  });

  const classModuleOptions = createMemo(() => {
    const list = classes();
    if (!list) return [];
    
    const options: { label: string; value: string }[] = [];
    
    list.forEach(cls => {
        if(cls.modules && cls.modules.length > 0) {
            cls.modules.forEach(mod => {

                const valueId = (mod as any).classes_modules_id || mod.courses_modules_id; 
                
                options.push({
                    label: `${cls.identifier} - ${mod.module_name} (${cls.location})`,
                    value: valueId
                });
            })
        }
    });
    
    return options;
  });

  const getTraineeName = (id: string | undefined) => {
    if (!id || !trainees()) return id;
    const found = trainees()?.find((t) => t.traineeId === id);
    return found ? found.name : id;
  };

  const getClassModuleName = (id: string | undefined) => {
    if (!id || !classes()) return id;
    for (const cls of classes()!) {
        const foundMod = cls.modules?.find((m: any) => 
            m.classes_modules_id === id || m.courses_modules_id === id
        );
        if(foundMod) {
            return `${cls.identifier} - ${foundMod.module_name}`;
        }
    }
    return id;
  };


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

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Grade updated successfully (${changedFieldNames})`);
      } else {
        const gradeObj = {
          class_module_id: String(grade.class_module_id),
          trainee_id: String(grade.trainee_id),
          grade: String(grade.grade),
          grade_type: String(grade.grade_type),
        };

        const newGrade = await api.createGrade(gradeObj);

        mutate((prev: Grade[] | undefined) => [...(prev || []), newGrade]);
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
      (prev: Grade[] | undefined) =>
        prev?.filter((c: Grade) => c.grade_id !== gradeToDelete.grade_id) || [],
    );
  };

  return (
    <EntityTable<Grade>
      title="Manage Grades"
      data={gradesData}
      handleEditClick={(grade) => ({
        ...grade,
      })}
      handleAddClick={() => createEmptyGrade()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveGrade}
      filter={(e: Grade, search: string) => {
        const s = search.toLowerCase();
        const traineeName = getTraineeName(e.trainee_id)?.toLowerCase() || "";
        const moduleName = getClassModuleName(e.class_module_id)?.toLowerCase() || "";

        return (
             String(e.grade).includes(s) ||
             traineeName.includes(s) ||
             moduleName.includes(s)
        ) ?? false;
      }}
      formFields={[
        {
          label: "Class Module",
          name: "class_module_id",
          type: "select",
          options: classModuleOptions(),
          required: true,
          placeholder: classes.loading ? "Loading modules..." : "Select Class Module"
        },
        {
          label: "Trainee",
          name: "trainee_id",
          type: "select",
          options: traineeOptions(),
          required: true,
          placeholder: trainees.loading ? "Loading trainees..." : "Select Trainee"
        },
        {
          label: "Grade (0-20)",
          name: "grade",
          type: "number",
          required: true,
        },
        {
          label: "Grade Type",
          name: "grade_type",
          type: "select",
          options: Object.values(GradeTypeEnum).map((value) => ({
            label: value,
            value: value,
          })),
          required: true,
        },
      ]}
      fields={[
        {
          formattedName: "Grade ID",
          fieldName: "grade_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Class Module",
          fieldName: "class_module_id",
          customGeneration: (e) => (
             <span class="font-mono text-xs">{getClassModuleName(e.class_module_id)}</span>
          ),
          smaller: true,
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
            <div class={`badge ${Number(e.grade) >= 10 ? 'badge-success' : 'badge-error'} badge-outline`}>
                {e.grade}
            </div>
          )
        },
        {
          formattedName: "Type",
          fieldName: "grade_type",
          capitalizeValue: true,
          smaller: true,
        },
      ]}
    ></EntityTable>
  );
};

export default GradesPage;