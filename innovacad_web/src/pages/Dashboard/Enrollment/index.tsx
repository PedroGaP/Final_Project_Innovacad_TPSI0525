import { createResource } from "solid-js";
import type { Enrollment } from "@/types/enrollment";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import EntityTable from "@/components/EntityTable";

const createEmptyEnrollment = (): Enrollment =>
  ({
    class_id: "",
    trainee_id: "",
    final_grade: "",
  }) as unknown as Enrollment;

const validateEnrollment = (
  enrollment: Enrollment,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const class_id = String(enrollment.class_id || "").trim();
  if (!class_id) {
    errors.push("Class Id is required");
  }

  const trainee_id = String(enrollment.trainee_id || "").trim();
  if (!trainee_id) {
    errors.push("Trainee Id is required");
  }

  const final_grade = String(enrollment.final_grade || "").trim();
  if (!final_grade) {
    errors.push("Final Grade is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldEnrollment: Enrollment,
  newEnrollment: Enrollment,
): {
  class_id?: string;
  trainee_id?: string;
  final_grade?: string;
} => {
  const changes: any = {};

  if (String(oldEnrollment.class_id) !== String(newEnrollment.class_id)) {
    changes.class_id = String(newEnrollment.class_id);
  }

  if (String(oldEnrollment.trainee_id) !== String(newEnrollment.trainee_id)) {
    changes.trainee_id = String(newEnrollment.trainee_id);
  }

  if (String(oldEnrollment.final_grade) !== String(newEnrollment.final_grade)) {
    changes.final_grade = String(newEnrollment.final_grade);
  }

  return changes;
};

const EnrollmentsPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Enrollment[]>(
    api.fetchEnrollments,
  );

  const handleSaveEnrollment = async (
    enrollment: Enrollment,
    original: Enrollment | null,
  ) => {
    try {
      const validation = validateEnrollment(enrollment);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, enrollment);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateEnrollment(
          String(enrollment.enrollment_id),
          changedFields,
        );

        mutate(
          (prev) =>
            prev?.map((u) =>
              u.enrollment_id === enrollment.enrollment_id ? enrollment : u,
            ) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Enrollment updated successfully (${changedFieldNames})`);
      } else {
        const enrollmentObj = {
          class_id: String(enrollment.class_id),
          trainee_id: String(enrollment.trainee_id),
          final_grade: String(enrollment.final_grade),
        };

        const newEnrollment = await api.createEnrollment(enrollmentObj);

        mutate((prev) => [...(prev || []), newEnrollment]);
        toast.success("Enrollment created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save enrollment");
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Enrollment) => {
    await api.deleteEnrollment(String(userToDelete.enrollment_id));
    mutate(
      (prev) =>
        prev?.filter((u) => u.enrollment_id !== userToDelete.enrollment_id) ||
        [],
    );
  };

  return (
    <EntityTable<Enrollment>
      title="Manage Enrollments"
      data={usersData}
      handleEditClick={(enrollment) => ({
        ...enrollment,
      })}
      handleAddClick={() => createEmptyEnrollment()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveEnrollment}
      filter={(e: Enrollment, search: string) => {
        const s = search.toLowerCase();
        return String(e.final_grade)?.toLowerCase().includes(s) ?? false;
      }}
      fields={[
        {
          formattedName: "ID",
          fieldName: "enrollment_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Class Id",
          fieldName: "class_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Trainee Id",
          fieldName: "trainee_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Final Grade",
          fieldName: "final_grade",
          smaller: true,
        },
      ]}
    />
  );
};

export default EnrollmentsPage;
