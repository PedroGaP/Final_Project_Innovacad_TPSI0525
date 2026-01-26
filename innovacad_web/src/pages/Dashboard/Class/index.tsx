import EntityTable from "@/components/EntityTable";
import { useApi } from "@/hooks/useApi";
import { type Class } from "@/types/class";
import { createEffect, createResource } from "solid-js";
import toast from "solid-toast";

const createEmptyClass = (): Class =>
  ({
    course_id: "",
    location: "",
    identifier: "",
    status: "",
    start_date_timestamp: "",
    end_date_timestamp: "",
  }) as unknown as Class;

const epochToDateTime = (epoch: number | string): string => {
  if (!epoch || isNaN(Number(epoch)) || Number(epoch) <= 0) return "";

  const date = new Date(Number(epoch));
  if (isNaN(date.getTime())) return "";

  const pad = (n: number) => n.toString().padStart(2, "0");

  const yyyy = date.getFullYear();
  const mm = pad(date.getMonth() + 1);
  const dd = pad(date.getDate());
  const hh = pad(date.getHours());
  const min = pad(date.getMinutes());

  return `${yyyy}-${mm}-${dd}T${hh}:${min}`;
};

const validateClass = (klass: Class): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const course_id = String(klass.course_id || "").trim();
  if (!course_id) {
    errors.push("Course is required");
  }

  const location = String(klass.location || "").trim();
  if (!location) {
    errors.push("Location is required");
  }

  const identifier = String(klass.identifier || "").trim();
  if (!identifier) {
    errors.push("Identifier is required");
  }

  const status = String(klass.status || "")
    .trim()
    .toLocaleLowerCase();
  console.log(status);
  if (!status) {
    errors.push("Birthday date is required");
  } else if (
    status != "starting" &&
    status != "ongoing" &&
    status != "finished"
  ) {
    errors.push("Status is invalid");
  }

  const start_date_timestamp = String(klass.start_date_timestamp || "").trim();
  if (!start_date_timestamp) {
    errors.push("Start Date is required");
  }

  const end_date_timestamp = String(klass.end_date_timestamp || "").trim();
  if (!end_date_timestamp) {
    errors.push("End Date is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldClass: Class,
  newClass: Class,
): {
  course_id?: string;
  location?: string;
  identifier?: string;
  status?: string;
  start_date_timestamp?: string;
  end_date_timestamp?: string;
} => {
  const changes: any = {};

  if (String(oldClass.status) !== String(newClass.status)) {
    changes.status = String(newClass.status);
  }

  if (String(oldClass.location) !== String(newClass.location)) {
    changes.location = String(newClass.location);
  }

  if (String(oldClass.identifier) !== String(newClass.identifier)) {
    changes.identifier = String(newClass.identifier);
  }

  return changes;
};

const ClassesPage = () => {
  const api = useApi();

  const [classesData, { mutate }] = createResource<Class[]>(api.fetchClasses);

  createEffect(() => console.log(classesData()));

  const handleSaveClass = async (klass: Class, original: Class | null) => {
    try {
      const validation = validateClass(klass);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, klass);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateClass(String(klass.class_id), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) => (u.class_id === klass.class_id ? klass : u)) || [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Class updated successfully (${changedFieldNames})`);
      } else {
        const classObj = {
          course_id: String(klass.course_id),
          location: String(klass.location),
          identifier: String(klass.identifier),
          status: String(klass.status),
          start_date_timestamp: String(klass.start_date_timestamp),
          end_date_timestamp: String(klass.end_date_timestamp),
        };

        const newClass = await api.createClass(classObj);

        mutate((prev: Class[] | undefined) => [...(prev || []), newClass]);
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
      (prev: Class[] | undefined) =>
        prev?.filter((c: Class) => c.class_id !== classToDelete.class_id) || [],
    );
  };

  return (
    <EntityTable<Class>
      title="Manage Classes"
      data={classesData}
      handleEditClick={(klass) => ({
        ...klass,
      })}
      handleAddClick={() => createEmptyClass()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveClass}
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
        {
          formattedName: "Class ID",
          fieldName: "class_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Course ID",
          fieldName: "course_id",
          canCopy: true,
          bigger: true,
        },
        {
          formattedName: "Location",
          fieldName: "location",
          canCopy: true,
        },
        {
          formattedName: "Identifier",
          fieldName: "identifier",
        },
        {
          formattedName: "Status",
          fieldName: "status",
          capitalizeValue: true,
          smaller: true,
        },
        {
          formattedName: "Start Date",
          fieldName: "start_date_timestamp",
          customGeneration: (e: Class) =>
            epochToDateTime(String(e.start_date_timestamp!)),
        },
        {
          formattedName: "End Date",
          fieldName: "end_date_timestamp",
          customGeneration: (e: Class) =>
            epochToDateTime(String(e.end_date_timestamp!)),
        },
      ]}
    ></EntityTable>
  );
};

export default ClassesPage;
