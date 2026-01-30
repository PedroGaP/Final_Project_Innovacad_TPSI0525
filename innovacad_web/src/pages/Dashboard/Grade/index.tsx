import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { GradeTypeEnum, type Grade } from "@/types/grade";
import { createResource } from "solid-js";
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

  const grade_module_id = String(grade.grade || "").trim();
  if (!grade_module_id) {
    errors.push("Class Module Id is required");
  }

  const trainee_id = String(grade.trainee_id || "").trim();
  if (!trainee_id) {
    errors.push("Trainee Id is required");
  }

  const grade_val = String(grade.grade || "").trim();
  if (!grade_val) {
    errors.push("Grade is required");
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

  const [gradeesData, { mutate }] = createResource<Grade[]>(api.fetchGrades);

  const handleSaveTrainee = async (grade: Grade, original: Grade | null) => {
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
        toast.success(`Trainee updated successfully (${changedFieldNames})`);
      } else {
        const gradeObj = {
          class_module_id: String(grade.class_module_id),
          trainee_id: String(grade.trainee_id),
          grade: grade.grade,
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
      title="Manage Gradees"
      data={gradeesData}
      handleEditClick={(grade) => ({
        ...grade,
      })}
      handleAddClick={() => createEmptyGrade()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveTrainee}
      formFields={[
        {
          label: "Class Module ID",
          name: "class_module_id",
          type: "text",
          required: true,
        },
        {
          label: "Trainee Id",
          name: "trainee_id",
          type: "text",
          required: true,
        },
        {
          label: "Grade",
          name: "grade",
          type: "number",
          required: false,
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
          bigger: true,
        },
        {
          formattedName: "Class Module ID",
          fieldName: "class_module_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Trainee Id",
          fieldName: "trainee_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Grade",
          fieldName: "grade",
        },
        {
          formattedName: "Grade Type",
          fieldName: "grade_type",
          capitalizeValue: true,
        },
      ]}
    ></EntityTable>
  );
};

export default GradesPage;
