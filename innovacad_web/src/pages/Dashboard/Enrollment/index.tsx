import { createMemo, createResource, createSignal, Show } from "solid-js";
import type { Enrollment } from "@/types/enrollment";
import type { Trainee } from "@/types/user";
import type { Class } from "@/types/class";
import { useApi } from "@/hooks/useApi";
import { useUserDetails } from "@/providers/UserDetailsProvider";
import toast from "solid-toast";
import EntityTable, { ActionsEnum } from "@/components/EntityTable";
import type { ModalFieldDefinition } from "@/components/Modal/Edit";
import type { Course } from "@/types/course";
import { Icon } from "@/components/Icon";

const createEmptyEnrollment = (): Enrollment =>
  ({
    enrollment_id: "",
    class_id: "",
    trainee_id: "",
    final_grade: "0",
  }) as unknown as Enrollment;

const validateEnrollment = (
  enrollment: Enrollment,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];
  const class_id = String(enrollment.class_id || "").trim();
  if (!class_id) errors.push("Class is required");

  const trainee_id = String(enrollment.trainee_id || "").trim();
  if (!trainee_id) errors.push("Trainee is required");

  const final_grade = String(enrollment.final_grade || "").trim();
  if (
    final_grade &&
    (isNaN(Number(final_grade)) ||
      Number(final_grade) < 0 ||
      Number(final_grade) > 20)
  ) {
    errors.push("Final Grade must be between 0 and 20");
  }

  return { valid: errors.length === 0, errors };
};

const getChangedFields = (
  oldEnrollment: Enrollment,
  newEnrollment: Enrollment,
): Partial<Enrollment> => {
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
  const { user } = useUserDetails();

  const [enrollmentsData, { mutate }] = createResource<Enrollment[]>(
    api.fetchEnrollments,
  );
  const [trainees] = createResource<Trainee[]>(api.fetchTrainees);
  const [classes] = createResource<Class[]>(api.fetchClasses);
  const [courses] = createResource<Course[]>(api.fetchCourses);

  const isTrainee = () => user()?.role === "trainee";

  const tableActions = createMemo(() => {
    if (isTrainee()) return [ActionsEnum.CUSTOM];
    return [ActionsEnum.ADD, ActionsEnum.EDIT, ActionsEnum.DELETE];
  });

  const displayData = createMemo(() => {
    const all = enrollmentsData();
    const currentUser = user();
    if (!all || !currentUser) return [];

    if (currentUser.role === "trainee") {
      const myId = String(
        (currentUser as any).trainee_id || currentUser.id,
      ).toLowerCase();
      return all.filter((e) => String(e.trainee_id).toLowerCase() === myId);
    }

    return all;
  });

  const traineeOptions = createMemo(() => {
    return (trainees() || []).map((t) => ({
      label: `${t.name} (${t.email})`,
      value: t.traineeId!,
    }));
  });

  const classOptions = createMemo(() => {
    return (classes() || []).map((c) => ({
      label: `${c.identifier} - ${c.location} (${c.status})`,
      value: c.class_id!,
    }));
  });

  const getTraineeName = (id: string | undefined) => {
    if (!id || !trainees()) return id || "N/A";
    const found = trainees()?.find((t) => t.traineeId === id);
    return found ? found.name : id;
  };

  const getClassIdentifier = (id: string | undefined) => {
    if (!id || !classes()) return id || "N/A";
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

        await api.updateEnrollment(String(enrollment.enrollment_id), {
          ...changedFields,
          final_grade: String(enrollment.final_grade),
        });
        mutate(
          (prev) =>
            prev?.map((u) =>
              u.enrollment_id === enrollment.enrollment_id ? enrollment : u,
            ) || [],
        );
        toast.success(`Enrollment updated successfully`);
      } else {
        const newEnrollment = await api.createEnrollment({
          class_id: String(enrollment.class_id),
          trainee_id: String(enrollment.trainee_id),
          final_grade: String(enrollment.final_grade),
        });

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

  const confirmDelete = async (item: Enrollment) => {
    try {
      await api.deleteEnrollment(String(item.enrollment_id));
      mutate(
        (prev) =>
          prev?.filter((u) => u.enrollment_id !== item.enrollment_id) || [],
      );
      toast.success("Enrollment removed");
    } catch (e: any) {
      toast.error(e.message);
    }
  };

  const formFieldsConfig = createMemo<ModalFieldDefinition<Enrollment>[]>(
    () => [
      {
        name: "class_id",
        label: "Class",
        type: "select",
        options: classOptions(),
        required: true,
      },
      {
        name: "trainee_id",
        label: "Trainee",
        type: "select",
        options: traineeOptions(),
        required: true,
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
      title={isTrainee() ? "My Enrollments & Grades" : "Manage Enrollments"}
      data={displayData}
      handleAddClick={isTrainee() ? undefined : () => createEmptyEnrollment()}
      handleEditClick={isTrainee() ? undefined : (e) => ({ ...e })}
      confirmDelete={isTrainee() ? undefined : confirmDelete}
      handleSave={handleSaveEnrollment}
      formFields={formFieldsConfig()}
      actions={tableActions()}
      renderCustomAction={(e) => (
        <button
          class="btn btn-primary btn-sm tooltip tooltip-left z-10"
          data-tip={"View Details"}
          onClick={() => {}}
        >
          <Icon name="Eye" size={16} />
        </button>
      )}
      filter={(e: Enrollment, search: string) => {
        const s = search.toLowerCase();
        const traineeName = getTraineeName(e.trainee_id)?.toLowerCase() || "";
        const classIdent = getClassIdentifier(e.class_id)?.toLowerCase() || "";
        return (
          String(e.final_grade).toLowerCase().includes(s) ||
          traineeName.includes(s) ||
          classIdent.includes(s)
        );
      }}
      fields={[
        {
          formattedName: "ID",
          fieldName: "enrollment_id",
          canCopy: true,
          smaller: true,
          hidden: isTrainee(),
        },
        {
          formattedName: "Course",
          fieldName: "class_id",
          customGeneration: (e) => (
            <div class="flex flex-col">
              <span class="font-bold text-sm">
                {
                  courses()?.find(
                    (c) =>
                      c.course_id ===
                      classes()!.find((cl) => cl.class_id === e.class_id)
                        ?.course_id,
                  )?.name
                }
              </span>
              <Show when={!isTrainee()}>
                <span class="text-[10px] opacity-50 font-mono">
                  {e.class_id}
                </span>
              </Show>
            </div>
          ),
        },
        {
          bigger: true,
          formattedName: "Class",
          fieldName: "class_id",
          customGeneration: (e) => (
            <div class="flex flex-col">
              <span class="font-bold text-sm">
                {getClassIdentifier(e.class_id)}
              </span>
              <Show when={!isTrainee()}>
                <span class="text-[10px] opacity-50 font-mono">
                  {e.class_id}
                </span>
              </Show>
            </div>
          ),
        },
        {
          formattedName: "Trainee",
          fieldName: "trainee_id",
          hidden: isTrainee(),
          customGeneration: (e) => (
            <div class="flex flex-col">
              <span class="font-medium">{getTraineeName(e.trainee_id)}</span>
              <span class="text-[10px] opacity-50 font-mono">
                {e.trainee_id?.substring(0, 8)}...
              </span>
            </div>
          ),
        },
        {
          formattedName: "Final Grade",
          fieldName: "final_grade",
          smaller: true,
          customGeneration: (e) => {
            const grade = Number(e.final_grade);
            return (
              <div
                class={`badge ${grade >= 9.5 ? "badge-success" : "badge-error"} badge-md font-bold py-3 px-4`}
              >
                {grade > 0 ? grade.toFixed(2) : "Pending"}
              </div>
            );
          },
        },
      ]}
    />
  );
};

export default EnrollmentsPage;
