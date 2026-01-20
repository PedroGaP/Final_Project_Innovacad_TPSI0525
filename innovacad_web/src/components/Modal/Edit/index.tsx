import {
  createEffect,
  createSignal,
  type Accessor,
  type Setter,
} from "solid-js";

interface Props<T extends Record<string, any>> {
  value: Accessor<T | null>;
  setValue: Setter<T | null>;
  onSave: (data: T) => Promise<void>;
  onCancel: () => void;
  title?: string;
  isLoading?: Accessor<boolean>;
}

export default function ModalEdit<T extends Record<string, any>>(
  props: Props<T>,
) {
  const [entity, setEntity] = createSignal<T | null>(null);
  const [isSaving, setIsSaving] = createSignal(false);

  createEffect(() => {
    if (props.value()) {
      setEntity(() => ({ ...props.value()! }) as T);
    }
  });

  const isEditing = () => {
    const current = entity();
    if (!current) return false;
    return (
      (current["traineeId"] && current["traineeId"].length > 0) ||
      (current["trainerId"] && current["trainerId"].length > 0) ||
      (current["id"] && current["id"].length > 0)
    );
  };

  const handleSave = async () => {
    const currentEntity = entity();
    if (!currentEntity) return;

    try {
      setIsSaving(true);
      await props.onSave(currentEntity);
      props.setValue(null);
      setEntity(() => null);
    } catch (error) {
      console.error("Save error:", error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = () => {
    props.onCancel();
    props.setValue(null);
    setEntity(() => null);
  };

  const updateField = <K extends keyof T>(field: K, value: T[K]) => {
    setEntity((current) => {
      if (!current) return null;
      return {
        ...current,
        [field]: value,
      } as T;
    });
  };

  return (
    <dialog
      open={props.value() !== null}
      class="modal modal-bottom sm:modal-middle"
    >
      <div class="modal-box w-full max-w-md bg-base-100 shadow-xl rounded-xl p-0 overflow-hidden">
        {/* Header */}
        <div class="bg-gradient-to-r from-primary to-primary/80 px-6 py-4 flex items-center justify-between">
          <div class="flex-1">
            <h3 class="font-bold text-lg text-white">
              {isEditing()
                ? `Edit ${props.title || "User"}`
                : `Create ${props.title || "User"}`}
            </h3>
          </div>
          <button
            onClick={handleCancel}
            class="btn btn-ghost btn-sm btn-circle text-white hover:bg-white/20"
          >
            ✕
          </button>
        </div>

        {/* Content */}
        {entity() && (
          <div class="px-6 py-4 space-y-3 max-h-[50vh] overflow-y-auto scrollbar-thin scrollbar-thumb-base-300">
            {/* Name Field */}
            <div class="form-control w-full">
              <label class="label py-1">
                <span class="label-text text-sm font-medium">Full Name</span>
              </label>
              <input
                class="input input-bordered input-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                placeholder="John Doe"
                type="text"
                value={entity()!["name"] || ""}
                onInput={(e) =>
                  updateField("name" as any, e.currentTarget.value as any)
                }
              />
            </div>

            {/* Email Field */}
            <div class="form-control w-full">
              <label class="label py-1">
                <span class="label-text text-sm font-medium">Email</span>
              </label>
              <input
                class="input input-bordered input-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                placeholder="john@example.com"
                type="email"
                value={entity()!["email"] || ""}
                onInput={(e) =>
                  updateField("email" as any, e.currentTarget.value as any)
                }
              />
            </div>

            {/* Username Field */}
            {entity()!["username"] !== undefined && (
              <div class="form-control w-full">
                <label class="label py-1">
                  <span class="label-text text-sm font-medium">Username</span>
                </label>
                <input
                  class="input input-bordered input-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                  placeholder="johndoe"
                  type="text"
                  value={entity()!["username"] || ""}
                  onInput={(e) =>
                    updateField("username" as any, e.currentTarget.value as any)
                  }
                />
              </div>
            )}

            {/* Role Field */}
            {entity()!["role"] && (
              <div class="form-control w-full">
                <label class="label py-1">
                  <span class="label-text text-sm font-medium">Role</span>
                </label>
                <select
                  class="select select-bordered select-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                  value={entity()!["role"] || ""}
                  onChange={(e) =>
                    updateField("role" as any, e.currentTarget.value as any)
                  }
                >
                  <option disabled>Select role</option>
                  <option value="trainee">Trainee</option>
                  <option value="trainer">Trainer</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
            )}

            {/* Specialization Field */}
            {entity()!["specialization"] !== undefined && (
              <div class="form-control w-full">
                <label class="label py-1">
                  <span class="label-text text-sm font-medium">
                    Specialization
                  </span>
                </label>
                <input
                  class="input input-bordered input-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                  placeholder="Web Development"
                  type="text"
                  value={entity()!["specialization"] || ""}
                  onInput={(e) =>
                    updateField(
                      "specialization" as any,
                      e.currentTarget.value as any,
                    )
                  }
                />
              </div>
            )}

            {/* Birthday Date Field */}
            {entity()!["birthdayDate"] !== undefined && (
              <div class="form-control w-full">
                <label class="label py-1">
                  <span class="label-text text-sm font-medium">Birthday</span>
                </label>
                <input
                  class="input input-bordered input-sm w-full bg-base-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-150"
                  type="date"
                  value={entity()!["birthdayDate"] || ""}
                  onInput={(e) =>
                    updateField(
                      "birthdayDate" as any,
                      e.currentTarget.value as any,
                    )
                  }
                />
              </div>
            )}
          </div>
        )}

        {/* Footer */}
        <div class="bg-base-200/30 px-6 py-3 flex gap-2 justify-end border-t border-base-300">
          <button
            class="btn btn-ghost btn-sm font-medium"
            onClick={handleCancel}
            disabled={isSaving()}
            type="button"
          >
            Cancel
          </button>
          <button
            class="btn btn-primary btn-sm font-medium gap-1"
            onClick={handleSave}
            disabled={isSaving() || !entity()}
            type="button"
          >
            {isSaving() ? (
              <>
                <span class="loading loading-spinner loading-xs"></span>
                Saving
              </>
            ) : isEditing() ? (
              "Update"
            ) : (
              "Create"
            )}
          </button>
        </div>
      </div>

      {/* Backdrop */}
      <form method="dialog" class="modal-backdrop bg-black/30">
        <button onClick={handleCancel}>close</button>
      </form>
    </dialog>
  );
}
