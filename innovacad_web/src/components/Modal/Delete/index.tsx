import { createSignal, type Accessor, type Setter } from "solid-js";

interface Props<T extends Record<string, any>> {
  value: Accessor<T | null>;
  setValue: Setter<T | null>;
  onConfirm: () => Promise<void>;
  onCancel: () => void;
  title?: string;
  description?: string;
}

export default function ModalDelete<T extends Record<string, any>>(
  props: Props<T>,
) {
  const [isDeleting, setIsDeleting] = createSignal(false);

  const handleConfirm = async () => {
    try {
      setIsDeleting(true);
      await props.onConfirm();
      props.setValue(null);
    } catch (error) {
      console.error("Delete error:", error);
    } finally {
      setIsDeleting(false);
    }
  };

  const handleCancel = () => {
    props.onCancel();
    props.setValue(null);
  };

  return (
    <dialog
      open={props.value() !== null}
      class="modal modal-bottom sm:modal-middle"
    >
      <div class="modal-box w-full max-w-sm bg-base-100 shadow-xl rounded-xl p-0 overflow-hidden">
        {/* Header */}
        <div class="bg-gradient-to-r from-error to-error/80 px-6 py-4 flex items-center justify-between">
          <div class="flex-1">
            <h3 class="font-bold text-lg text-white">
              {props.title || "Delete Item"}
            </h3>
          </div>
          <button
            onClick={handleCancel}
            class="btn btn-ghost btn-sm btn-circle text-white hover:bg-white/20"
            disabled={isDeleting()}
          >
            ✕
          </button>
        </div>

        {/* Content */}
        <div class="px-6 py-4">
          <div class="flex items-start gap-3">
            <div class="flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-error/10">
              {/* Trash/Delete Icon */}
              <svg
                class="h-6 w-6 text-error"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                ></path>
              </svg>
            </div>
            <div class="flex-1">
              <p class="text-sm font-medium text-base-content">
                {props.description ||
                  "Are you sure you want to delete this item?"}
              </p>
              <p class="text-sm text-base-content/60 mt-2">
                This action cannot be undone. All associated data will be
                permanently deleted.
              </p>
              {props.value() && (
                <>
                  <p class="text-sm font-semibold text-base-content mt-3">
                    {props.value()!["name"] || props.value()!["title"]}
                  </p>
                  <p class="text-xs text-base-content/50">
                    {props.value()!["email"] || props.value()!["description"]}
                  </p>
                </>
              )}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div class="bg-base-200/30 px-6 py-3 flex gap-2 justify-end border-t border-base-300">
          <button
            class="btn btn-ghost btn-sm font-medium"
            onClick={handleCancel}
            disabled={isDeleting()}
            type="button"
          >
            Cancel
          </button>
          <button
            class="btn btn-error btn-sm font-medium gap-1"
            onClick={handleConfirm}
            disabled={isDeleting()}
            type="button"
          >
            {isDeleting() ? (
              <>
                <span class="loading loading-spinner loading-xs"></span>
                Deleting
              </>
            ) : (
              "Delete"
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
