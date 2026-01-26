import { CircleQuestionMark } from "lucide-solid";
import { createSignal, Show, For, createEffect } from "solid-js";
import { Portal } from "solid-js/web";

interface ModalEditProps<T> {
  value: T;
  setValue: (value: T | null) => void;
  onSave: (value: T) => Promise<void>;
  onCancel: () => void;
  title: string;
  disabledFields?: string[];
}

const PortalTooltip = (props: { text: string; children: any }) => {
  let ref: HTMLDivElement | undefined;
  const [pos, setPos] = createSignal<{ x: number; y: number } | null>(null);

  const show = () => {
    if (!ref) return;
    const rect = ref.getBoundingClientRect();
    setPos({
      x: rect.left + rect.width / 2,
      y: rect.top - 6,
    });
  };

  const hide = () => setPos(null);

  return (
    <>
      <div
        ref={ref}
        onMouseEnter={show}
        onMouseLeave={hide}
        class="inline-flex cursor-help align-middle"
      >
        {props.children}
      </div>
      <Show when={pos()}>
        <Portal>
          <div
            class="fixed z-9999 px-2 py-1 text-xs font-medium text-neutral-content bg-neutral rounded shadow-sm pointer-events-none transform -translate-x-1/2 -translate-y-full animate-in fade-in zoom-in-95 duration-100"
            style={{ top: `${pos()?.y}px`, left: `${pos()?.x}px` }}
          >
            {props.text}
            <div class="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-neutral"></div>
          </div>
        </Portal>
      </Show>
    </>
  );
};

const getAutocompleteValue = (fieldName: string): string => {
  const f = fieldName.toLowerCase();
  if (f.includes("email")) return "email";
  if (f.includes("password")) return "new-password";
  if (f.includes("username")) return "username";
  if (f.includes("name")) return "name";
  if (f.includes("birth") || f.includes("date")) return "bday";
  return "off";
};

const formatDateForInput = (val: any): string => {
  if (!val) return "";

  const numericVal =
    typeof val === "string" && /^\d+$/.test(val)
      ? Number.parseInt(val, 10)
      : val;

  const date = new Date(numericVal);

  if (isNaN(date.getTime())) return "";

  const YYYY = date.getFullYear();
  const MM = String(date.getMonth() + 1).padStart(2, "0");
  const DD = String(date.getDate()).padStart(2, "0");
  const hh = String(date.getHours()).padStart(2, "0");
  const mm = String(date.getMinutes()).padStart(2, "0");

  return `${YYYY}-${MM}-${DD}T${hh}:${mm}`;
};

const ModalEdit = <T extends Record<string, any>>(props: ModalEditProps<T>) => {
  const [formData, setFormData] = createSignal<T>(props.value);
  const [loading, setLoading] = createSignal(false);

  createEffect(() => {
    setFormData(() => props.value);
  });

  const isFieldDisabled = (fieldName: string): boolean => {
    return props.disabledFields?.includes(fieldName) ?? false;
  };

  const handleInputChange = (field: string, value: any) => {
    if (!isFieldDisabled(field)) {
      setFormData((prev) => ({
        ...prev,
        [field]: value,
      }));
    }
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      await props.onSave(formData());
    } finally {
      setLoading(false);
    }
  };

  const getFieldType = (fieldName: string, value: any): string => {
    const f = fieldName.toLowerCase();
    if (f.includes("email")) return "email";

    if (
      f.includes("date") ||
      f.includes("birthday") ||
      f.includes("time") ||
      f.includes("createdAt") ||
      f.includes("updatedAt")
    ) {
      return "datetime-local";
    }

    if (f.includes("password")) return "password";
    if (typeof value === "boolean") return "checkbox";
    if (typeof value === "number") return "number";
    return "text";
  };

  const getFieldLabel = (fieldName: string): string => {
    return fieldName
      .replace(/([A-Z])/g, " $1")
      .replace(/^./, (str) => str.toUpperCase())
      .trim();
  };

  const shouldExcludeField = (fieldName: string): boolean => {
    const excludedFields = [
      "id",
      "traineeId",
      "trainerId",
      "class_Id",
      "token",
      "session_token",
      "image",
      "verified",
      "role",
      "tojson",
    ];
    return excludedFields.includes(fieldName.toLocaleLowerCase());
  };

  const getEditableFieldKeys = (): string[] => {
    return Object.keys(formData()).filter((key) => !shouldExcludeField(key));
  };

  return (
    <dialog id="edit_modal" class="modal modal-open">
      <div class="modal-box w-11/12 max-w-md p-0 overflow-hidden flex flex-col bg-base-100 rounded-xl">
        <div class="bg-linear-to-r from-primary to-primary/80 px-6 py-4 flex items-center justify-between shrink-0">
          <div class="flex-1">
            <h3 class="font-bold text-lg text-primary-content">
              {props.title}
            </h3>
          </div>
          <button
            onClick={props.onCancel}
            class="btn btn-ghost btn-sm btn-circle text-primary-content hover:bg-white/20"
          >
            ✕
          </button>
        </div>

        <div class="px-6 py-4 overflow-y-auto max-h-[60vh]">
          <For each={getEditableFieldKeys()}>
            {(fieldName) => {
              const fieldValue = () => formData()[fieldName];
              const fieldType = getFieldType(fieldName, fieldValue());

              return (
                <Show
                  when={fieldType !== "checkbox"}
                  fallback={
                    <div class="form-control w-full mb-4">
                      <label
                        class="label cursor-pointer justify-start gap-3"
                        for={`checkbox-${fieldName}`}
                      >
                        <input
                          id={`checkbox-${fieldName}`}
                          type="checkbox"
                          class="checkbox checkbox-primary"
                          checked={Boolean(fieldValue())}
                          onChange={(e) =>
                            handleInputChange(
                              fieldName,
                              e.currentTarget.checked,
                            )
                          }
                          disabled={isFieldDisabled(fieldName)}
                        />
                        <span class="label-text">
                          {getFieldLabel(fieldName)}
                        </span>
                      </label>
                    </div>
                  }
                >
                  <div class="form-control w-full mb-4">
                    <label class="label" for={fieldName}>
                      <span class="label-text">{getFieldLabel(fieldName)}</span>{" "}
                      <Show when={isFieldDisabled(fieldName)}>
                        <PortalTooltip text="Field cannot be changed">
                          <CircleQuestionMark size={14} class="opacity-50" />
                        </PortalTooltip>
                      </Show>
                    </label>
                    <input
                      id={fieldName}
                      name={fieldName}
                      type={fieldType}
                      autocomplete={getAutocompleteValue(fieldName) as string}
                      placeholder={`Enter ${getFieldLabel(fieldName).toLowerCase()}`}
                      class="input input-bordered w-full focus:input-primary"
                      value={
                        fieldType === "datetime-local"
                          ? formatDateForInput(fieldValue())
                          : String(fieldValue() || "")
                      }
                      onInput={(e) => {
                        const val = e.currentTarget.value;
                        if (fieldType === "datetime-local") {
                          const timestamp = new Date(val).getTime();
                          if (!isNaN(timestamp)) {
                            handleInputChange(fieldName, timestamp);
                          }
                        } else {
                          handleInputChange(fieldName, val);
                        }
                      }}
                      disabled={isFieldDisabled(fieldName)}
                    />
                  </div>
                </Show>
              );
            }}
          </For>
        </div>

        <div class="bg-base-200/50 px-6 py-3 flex gap-2 justify-end border-t border-base-300 shrink-0">
          <button
            class="btn btn-ghost btn-sm font-medium"
            onClick={() => {
              props.onCancel();
              setFormData((_) => props.value);
            }}
            disabled={loading()}
          >
            Cancel
          </button>
          <button
            class="btn btn-primary btn-sm font-medium min-w-[80px]"
            onClick={handleSave}
            disabled={loading()}
          >
            {loading() ? (
              <>
                <span class="loading loading-spinner loading-xs"></span>
                Saving
              </>
            ) : (
              "Save"
            )}
          </button>
        </div>
      </div>

      <form method="dialog" class="modal-backdrop bg-black/40">
        <button onClick={props.onCancel}>Close</button>
      </form>
    </dialog>
  );
};

export default ModalEdit;
