import { createResource } from "solid-js";
import type { Module } from "@/types/module";
import { useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import EntityTable from "@/components/EntityTable";

const createEmptyModule = (): Module =>
  ({
    name: "",
    duration: 0,
    has_computers: false,
    has_projector: false,
    has_whiteboard: false,
    has_smartboard: false,
  }) as unknown as Module;

const validateModule = (
  module: Module,
): { valid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const name = String(module.name || "").trim();
  if (!name) {
    errors.push("Name is required");
  }

  const duration = String(module.duration || "").trim();
  if (!duration) {
    errors.push("Duration is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

const getChangedFields = (
  oldModule: Module,
  newModule: Module,
): {
  name?: string;
  duration?: number;
  has_computers?: boolean;
  has_projector?: boolean;
  has_whiteboard?: boolean;
  has_smartboard?: boolean;
} => {
  const changes: any = {};

  if (String(oldModule.name) !== String(newModule.name)) {
    changes.name = String(newModule.name);
  }

  if (String(oldModule.duration) !== String(newModule.duration)) {
    changes.duration = Number(newModule.duration);
  }

  if (String(oldModule.has_computers) !== String(newModule.has_computers)) {
    changes.has_computers = Boolean(newModule.has_computers);
  }

  if (String(oldModule.has_projector) !== String(newModule.has_projector)) {
    changes.has_projector = Boolean(newModule.has_projector);
  }

  if (String(oldModule.has_whiteboard) !== String(newModule.has_whiteboard)) {
    changes.has_whiteboard = Boolean(newModule.has_whiteboard);
  }

  if (String(oldModule.has_smartboard) !== String(newModule.has_smartboard)) {
    changes.has_smartboard = Boolean(newModule.has_smartboard);
  }

  return changes;
};

const ModulesPage = () => {
  const api = useApi();

  const [usersData, { mutate }] = createResource<Module[]>(api.fetchModules);

  const handleSaveModule = async (module: Module, original: Module | null) => {
    try {
      const validation = validateModule(module);
      if (!validation.valid) {
        validation.errors.forEach((error) => toast.error(error));
        throw new Error("Validation failed");
      }

      if (original) {
        const changedFields = getChangedFields(original, module);

        if (Object.keys(changedFields).length === 0) return;

        await api.updateModule(String(module.module_id), changedFields);

        mutate(
          (prev) =>
            prev?.map((u) => (u.module_id === module.module_id ? module : u)) ||
            [],
        );

        const changedFieldNames = Object.keys(changedFields).join(", ");
        toast.success(`Module updated successfully (${changedFieldNames})`);
      } else {
        const moduleObj = {
          name: String(module.name),
          duration: Number(module.duration),
          has_computers: Boolean(module.has_computers),
          has_projector: Boolean(module.has_projector),
          has_whiteboard: Boolean(module.has_whiteboard),
          has_smartboard: Boolean(module.has_smartboard),
        };

        const newModule = await api.createModule(moduleObj);

        mutate((prev) => [...(prev || []), newModule]);
        toast.success("Module created successfully.");
      }
    } catch (error) {
      if (error instanceof Error && error.message !== "Validation failed") {
        toast.error(error.message || "Failed to save module");
      }
      throw error;
    }
  };

  const confirmDelete = async (userToDelete: Module) => {
    await api.deleteModule(String(userToDelete.module_id));
    mutate(
      (prev) =>
        prev?.filter((u) => u.module_id !== userToDelete.module_id) || [],
    );
  };

  return (
    <EntityTable<Module>
      title="Manage Modules"
      data={usersData}
      handleEditClick={(module) => ({
        ...module,
      })}
      handleAddClick={() => createEmptyModule()}
      confirmDelete={confirmDelete}
      handleSave={handleSaveModule}
      filter={(e: Module, search: string) => {
        const s = search.toLowerCase();
        return e.name?.toLowerCase().includes(s) ?? false;
      }}
      formFields={[
        {
          name: "duration",
          label: "Duration",
          type: "number",
        },
        {
          name: "name",
          label: "Name",
          type: "text",
        },
        {
          label: "Has Computers ?",
          name: "has_computers",
          type: "checkbox",
        },
        {
          label: "Has Projector ?",
          name: "has_projector",
          type: "checkbox",
        },
        {
          label: "Has Whiteboard ?",
          name: "has_whiteboard",
          type: "checkbox",
        },
        {
          label: "Has Smartboard ?",
          name: "has_smartboard",
          type: "checkbox",
        },
      ]}
      fields={[
        {
          formattedName: "ID",
          fieldName: "module_id",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Name",
          fieldName: "name",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Duration",
          fieldName: "duration",
          canCopy: true,
          smaller: true,
        },
        {
          formattedName: "Has Computers ?",
          fieldName: "has_computers",
          smaller: true,
        },
        {
          formattedName: "Has Projector ?",
          fieldName: "has_projector",
          smaller: true,
        },
        {
          formattedName: "Has Whiteboard ?",
          fieldName: "has_whiteboard",
          smaller: true,
        },
        {
          formattedName: "Has Smartboard ?",
          fieldName: "has_smartboard",
          smaller: true,
        },
      ]}
    />
  );
};

export default ModulesPage;
