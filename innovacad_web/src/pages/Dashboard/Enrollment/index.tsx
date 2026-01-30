import { createMemo, createResource } from "solid-js";
import type { Enrollment } from "@/types/enrollment";
import type { Trainee } from "@/types/user";
import type { Class } from "@/types/class";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import EntityTable from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";

const createEmptyEnrollment = (): Enrollment =>
  ({
    enrollment_id: "",
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
    errors.push("Class is required");
  }

  const trainee_id = String(enrollment.trainee_id || "").trim();
  if (!trainee_id) {
    errors.push("Trainee is required");
  }

  const final_grade = String(enrollment.final_grade || "").trim();
  if (
    final_grade &&
    (isNaN(Number(final_grade)) ||
      Number(final_grade) < 0 ||
      Number(final_grade) > 20)
  ) {
    errors.push("Final Grade must be between 0 and 20");
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

  const [enrollmentsData, { mutate }] = createResource<Enrollment[]>(
    api.fetchEnrollments,
  );

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

  const classOptions = createMemo(() => {
    const list = classes();
    if (!list) return [];
    return list.map((c) => ({
      label: `${c.identifier} - ${c.location} (${c.status})`,
      value: c.class_id!,
    }));
  });

  const getTraineeName = (id: string | undefined) => {
    if (!id || !trainees()) return id;
    const found = trainees()?.find((t) => t.traineeId === id);
    return found ? found.name : id;
  };

  const getClassIdentifier = (id: string | undefined) => {
    if (!id || !classes()) return id;
    const found = classes()?.find((c) => c.class_id === id);
    return found ? `${found.identifier} (${found.location})` : id;
  };

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
          final_grade: enrollment.final_grade
            ? String(enrollment.final_grade)
            : "0",
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
    toast.success("Enrollment deleted successfully");
  };

  const formFieldsConfig = createMemo<ModalFieldDefinition<Enrollment>[]>(
    () => [
      {
        name: "class_id",
        label: "Class",
        type: "select",
        options: classOptions(),
        required: true,
        placeholder: classes.loading ? "Loading Classes..." : "Select Class",
      },
      {
        name: "trainee_id",
        label: "Trainee",
        type: "select",
        options: traineeOptions(),
        required: true,
        placeholder: trainees.loading
          ? "Loading Trainees..."
          : "Select Trainee",
      },
      {
        name: "final_grade",
        label: "Final Grade (0-20)",
        type: "number",
      },
    ],
  );

  return (
    <EntityTable<Enrollment>
      title="Manage Enrollments"
      data={enrollmentsData}
      handleEditClick={(enrollment) => ({
        ...enrollment,
      })}
      handleAddClick={() => createEmptyEnrollment()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveEnrollment}
      formFields={formFieldsConfig()}
      filter={(e: Enrollment, search: string) => {
        const s = search.toLowerCase();
        
        const traineeName = getTraineeName(e.trainee_id)?.toLowerCase() || "";
        const classIdent = getClassIdentifier(e.class_id)?.toLowerCase() || "";

        return (
          (String(e.final_grade)?.toLowerCase().includes(s) ||
            traineeName.includes(s) ||
            classIdent.includes(s)) ??
          false
        );
      }}
      fields={[
        {
          formattedName: "ID",
          fieldName: "enrollment_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Class",
          fieldName: "class_id",
          
          customGeneration: (e) => (
            <span class="font-mono text-xs">
              {getClassIdentifier(e.class_id)}
            </span>
          ),
          smaller: true,
        },
        {
          formattedName: "Trainee",
          fieldName: "trainee_id",
          
          customGeneration: (e) => (
            <div class="flex flex-col">
              <span class="font-medium">{getTraineeName(e.trainee_id)}</span>
              <span class="text-[10px] opacity-50 font-mono">
                {e.trainee_id?.substring(0, 8)}...
              </span>
            </div>
          ),
          canCopy: true,
        },
        {
          formattedName: "Final Grade",
          fieldName: "final_grade",
          smaller: true,
          customGeneration: (e) => (
            <div
              class={`badge ${Number(e.final_grade) >= 10 ? "badge-success" : "badge-error"} badge-outline`}
            >
              {e.final_grade}
            </div>
          ),
        },
      ]}
    />
  );
};

export default EnrollmentsPage;
