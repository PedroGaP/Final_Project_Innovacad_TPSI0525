import { CircleQuestionMark } from "lucide-solid";
import {
  createSignal,
  Show,
  For,
  createEffect,
  type JSXElement,
  createMemo,
} from "solid-js";
import { Portal } from "solid-js/web";

export type ModalFieldType =
  | "text"
  | "number"
  | "email"
  | "password"
  | "datetime-local"
  | "date"
  | "checkbox"
  | "select"
  | "textarea";

export interface ModalFieldDefinition<T> {
  name: keyof T & string;
  label?: string;
  type?: ModalFieldType;
  placeholder?: string;
  disabled?: boolean;
  hidden?: boolean;
  options?: { label: string; value: string | number }[];
  required?: boolean;
}

interface ModalEditProps<T> {
  value: T;
  setValue: (value: T | null) => void;
  onSave: (value: T) => Promise<void>;
  onCancel: () => void;
  title: string;

  fields?: ModalFieldDefinition<T>[];

  disabledFields?: string[];

  renderCustomFields?: (
    formData: T,
    setFormData: (prev: (prev: T) => T) => void,
  ) => JSXElement;
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

const formatDateForInput = (val: any): string => {
  if (!val) return "";
  const numericVal =
    typeof val === "string" && /^\d+$/.test(val) ? parseInt(val, 10) : val;
  const date = new Date(numericVal);
  if (isNaN(date.getTime())) return "";

  const YYYY = date.getFullYear();
  const MM = String(date.getMonth() + 1).padStart(2, "0");
  const DD = String(date.getDate()).padStart(2, "0");
  const hh = String(date.getHours()).padStart(2, "0");
  const mm = String(date.getMinutes()).padStart(2, "0");
  return `${YYYY}-${MM}-${DD}T${hh}:${mm}`;
};

const getFieldLabel = (fieldName: string): string => {
  return fieldName
    .replace(/([A-Z])/g, " $1")
    .replace(/^./, (str) => str.toUpperCase())
    .trim();
};


const ModalEdit = <T extends Record<string, any>>(props: ModalEditProps<T>) => {
  const [formData, setFormData] = createSignal<T>(props.value);
  const [loading, setLoading] = createSignal(false);

  createEffect(() => {
    setFormData(() => props.value);
  });

  const handleInputChange = (field: keyof T, value: any) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      await props.onSave(formData());
    } finally {
      setLoading(false);
    }
  };

  const displayFields = createMemo(() => {
    if (props.fields && props.fields.length > 0) {
      return props.fields.filter((f) => !f.hidden);
    }

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
      "modules",
      "modules_ids",
    ];

    return Object.keys(formData())
      .filter((key) => !excludedFields.includes(key.toLowerCase()))
      .map((key) => {
        const val = formData()[key];
        const fKey = key.toLowerCase();
        let type: ModalFieldType = "text";

        if (fKey.includes("email")) type = "email";
        else if (fKey.includes("password")) type = "password";
        else if (
          fKey.includes("date") ||
          fKey.includes("time") ||
          fKey.includes("at")
        )
          type = "datetime-local";
        else if (typeof val === "boolean") type = "checkbox";
        else if (typeof val === "number") type = "number";

        return {
          name: key as keyof T & string,
          label: getFieldLabel(key),
          type,
          disabled: props.disabledFields?.includes(key),
        } as ModalFieldDefinition<T>;
      });
  });

  return (
    <dialog id="edit_modal" class="modal modal-open">
      <div class="modal-box w-11/12 max-w-md p-0 overflow-hidden flex flex-col bg-base-100 rounded-xl">
        {/* Header */}
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

        {/* Body */}
        <div class="px-6 py-4 overflow-y-auto max-h-[60vh] space-y-4">
          <For each={displayFields()}>
            {(field) => {
              const value = () => formData()[field.name];
              const isDisabled = field.disabled ?? false;
              const label = field.label || getFieldLabel(field.name);

              if (field.type === "checkbox") {
                return (
                  <div class="form-control w-full">
                    <label
                      class="label cursor-pointer justify-start gap-3"
                      for={`field-${field.name}`}
                    >
                      <input
                        id={`field-${field.name}`}
                        type="checkbox"
                        class="checkbox checkbox-primary"
                        checked={Boolean(value())}
                        disabled={isDisabled}
                        onChange={(e) =>
                          handleInputChange(field.name, e.currentTarget.checked)
                        }
                      />
                      <span class="label-text">{label}</span>
                    </label>
                  </div>
                );
              }

              if (field.type === "select") {
                return (
                  <div class="form-control w-full">
                    <FieldLabel field={field} label={label} />
                    <select
                      class="select select-bordered w-full focus:select-primary"
                      value={String(value() || "")}
                      disabled={isDisabled}
                      onChange={(e) =>
                        handleInputChange(field.name, e.currentTarget.value)
                      }
                    >
                      <option value="" disabled>
                        Select {label}
                      </option>
                      <For each={field.options}>
                        {(opt) => (
                          <option value={opt.value}>{opt.label}</option>
                        )}
                      </For>
                    </select>
                  </div>
                );
              }

              if (field.type === "textarea") {
                return (
                  <div class="form-control w-full">
                    <FieldLabel field={field} label={label} />
                    <textarea
                      class="textarea textarea-bordered h-24 focus:textarea-primary"
                      placeholder={
                        field.placeholder || `Enter ${label.toLowerCase()}`
                      }
                      value={String(value() || "")}
                      disabled={isDisabled}
                      onInput={(e) =>
                        handleInputChange(field.name, e.currentTarget.value)
                      }
                    />
                  </div>
                );
              }

              return (
                <div class="form-control w-full">
                  <FieldLabel field={field} label={label} />
                  <input
                    id={`field-${field.name}`}
                    type={field.type || "text"}
                    placeholder={
                      field.placeholder || `Enter ${label.toLowerCase()}`
                    }
                    class="input input-bordered w-full focus:input-primary"
                    disabled={isDisabled}
                    value={
                      field.type === "datetime-local" || field.type === "date"
                        ? formatDateForInput(value())
                        : String(value() || "")
                    }
                    onInput={(e) => {
                      const val = e.currentTarget.value;
                      if (
                        field.type === "datetime-local" ||
                        field.type === "date"
                      ) {
                        const timestamp = new Date(val).getTime();
                        if (!isNaN(timestamp))
                          handleInputChange(field.name, timestamp);
                      } else if (field.type === "number") {
                        handleInputChange(field.name, Number(val));
                      } else {
                        handleInputChange(field.name, val);
                      }
                    }}
                  />
                </div>
              );
            }}
          </For>

          {/* Custom Fields (Like Modules Manager) */}
          <Show when={props.renderCustomFields}>
            <div class="divider text-xs uppercase opacity-50 font-bold tracking-widest mt-6">
              Configuration
            </div>
            {props.renderCustomFields!(formData(), setFormData)}
          </Show>
        </div>

        {/* Footer */}
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
            class="btn btn-primary btn-sm font-medium min-w-20"
            onClick={handleSave}
            disabled={loading()}
          >
            {loading() ? (
              <span class="loading loading-spinner loading-xs"></span>
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

const FieldLabel = (props: {
  field: ModalFieldDefinition<any>;
  label: string;
}) => (
  <label class="label" for={`field-${props.field.name}`}>
    <span class="label-text">
      {props.label}
      {props.field.required && <span class="text-error ml-1">*</span>}
    </span>
    <Show when={props.field.disabled}>
      <PortalTooltip text="Field cannot be changed">
        <CircleQuestionMark size={14} class="opacity-50" />
      </PortalTooltip>
    </Show>
  </label>
);

export default ModalEdit;
