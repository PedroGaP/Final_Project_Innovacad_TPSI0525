import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import type { Course } from "@/types/course";
import { createResource } from "solid-js";
import toast from "solid-toast";

const createEmptyCourse = (): Course =>
  ({
    identifier: "",
    name: "",
  }) as unknown as Course;

const validateCourse = (
  course: Course,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const identifier = String(course.identifier || "").trim();
  if (!identifier) {
    errors.push("Identifier is required");
  }

  const name = String(course.name || "").trim();
  if (!name) {
    errors.push("name is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldCourse: Course,
  newCourse: Course,
): {
  identifier?: string;
  name?: string;
} => {
  const changes: any = {};

  if (String(oldCourse.identifier) !== String(newCourse.identifier)) {
    changes.status = String(newCourse.identifier);
  }

  if (String(oldCourse.name) !== String(newCourse.name)) {
    changes.name = String(newCourse.name);
  }

  return changes;
};

const CoursesPage = () => {
  const api = useApi();

  const [coursesData, { mutate }] = createResource<Course[]>(api.fetchCourses);

  const handleSaveCourse = async (course: Course, original: Course | null) => {
    try {
      const validation = validateCourse(course);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, course);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateCourse(String(course.course_id), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) => (u.course_id === course.course_id ? course : u)) ||
            [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Course updated successfully (${changedFieldNames})`);
      } else {
        const courseObj = {
          identifier: String(course.identifier),
          name: String(course.name),
        };

        const newCourse = await api.createCourse(courseObj);

        mutate((prev: Course[] | undefined) => [...(prev || []), newCourse]);
        toast.success("Course created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save course");
      }
      throw error;
    }
  };

  const confirmDelete = async (courseToDelete: Course) => {
    await api.deleteCourse(String(courseToDelete.course_id));
    mutate(
      (prev: Course[] | undefined) =>
        prev?.filter((c: Course) => c.course_id !== courseToDelete.course_id) ||
        [],
    );
  };

  return (
    <EntityTable<Course>
      title="Manage Courses"
      data={coursesData}
      handleEditClick={(course) => ({
        ...course,
      })}
      handleAddClick={() => createEmptyCourse()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveCourse}
      filter={(e: Course, search: string) => {
        const s = search.toLowerCase();
        return (
          (e.identifier?.toLowerCase().includes(s) ||
            e.name?.toLowerCase().includes(s)) ??
          false
        );
      }}
      fields={[
        {
          formattedName: "Course ID",
          fieldName: "course_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Identifier",
          fieldName: "identifier",
        },
        {
          formattedName: "Name",
          fieldName: "name",
        },
      ]}
    ></EntityTable>
  );
};

export default CoursesPage;
