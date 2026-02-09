import { CircleQuestionMark } from "lucide-solid";
import {
  createSignal,
  Show,
  For,
  createMemo,
  type JSXElement,
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
  setValue: (value: T) => void;
  onDelete?: () => Promise<void>;
  onSave: (value: T) => Promise<void>;
  onCancel: () => void;
  title: string;
  fields?: ModalFieldDefinition<T>[];
  disabledFields?: string[];
  renderCustomFields?: (
    formData: T,
    setFormData: (prev: T | ((p: T) => T)) => void,
  ) => JSXElement;
}

const PortalTooltip = (props: { text: string; children: any }) => {
  let ref: HTMLDivElement | undefined;
  const [pos, setPos] = createSignal<{ x: number; y: number } | null>(null);
  return (
    <>
      <div
        ref={ref}
        onMouseEnter={() => {
          if (ref) {
            const r = ref.getBoundingClientRect();
            setPos({ x: r.left + r.width / 2, y: r.top - 6 });
          }
        }}
        onMouseLeave={() => setPos(null)}
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

const formatDateForInput = (val: any, type: ModalFieldType): string => {
  if (!val) return "";
  if (typeof val === "string" && type === "date" && val.includes("T"))
    return val.split("T")[0];
  const numericVal =
    typeof val === "string" && /^\d+$/.test(val) ? parseInt(val, 10) : val;
  const date = new Date(numericVal);
  if (isNaN(date.getTime())) return "";
  const pad = (n: number) => n.toString().padStart(2, "0");
  const YYYY = date.getFullYear();
  const MM = pad(date.getMonth() + 1);
  const DD = pad(date.getDate());
  if (type === "date") return `${YYYY}-${MM}-${DD}`;
  const hh = pad(date.getHours());
  const mm = pad(date.getMinutes());
  return `${YYYY}-${MM}-${DD}T${hh}:${mm}`;
};

const getFieldLabel = (fieldName: string) =>
  fieldName
    .replace(/([A-Z])/g, " $1")
    .replace(/^./, (str) => str.toUpperCase())
    .trim();

const ModalEdit = <T extends Record<string, any>>(props: ModalEditProps<T>) => {
  const [loading, setLoading] = createSignal(false);

  const handleInputChange = (field: keyof T, value: any) => {
    props.setValue({ ...props.value, [field]: value } as T);
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      await props.onSave(props.value);
    } finally {
      setLoading(false);
    }
  };

  const visibleFields = createMemo(() => {
    if (props.fields && props.fields.length > 0)
      return props.fields.filter((f) => !f.hidden);
    return Object.keys(props.value).map(
      (key) =>
        ({
          name: key as keyof T & string,
          label: getFieldLabel(key),
          type: "text",
        }) as ModalFieldDefinition<T>,
    );
  });

  return (
    <dialog id="edit_modal" class="modal modal-open">
      <div class="modal-box w-11/12 max-w-md p-0 overflow-hidden flex flex-col bg-base-100 rounded-xl">
        <div class="bg-gradient-to-r from-primary to-primary/80 px-6 py-4 flex items-center justify-between shrink-0">
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

        <div class="px-6 py-4 overflow-y-auto max-h-[60vh] space-y-4">
          <For each={visibleFields()}>
            {(field) => {
              const value = () => props.value[field.name];
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
                        {field.placeholder || `Select ${label}`}
                      </option>
                      <For each={field.options}>
                        {(opt) => (
                          <option value={String(opt.value)}>{opt.label}</option>
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
                      field.type?.includes("date")
                        ? formatDateForInput(value(), field.type!)
                        : String(value() || "")
                    }
                    onInput={(e) => {
                      const val = e.currentTarget.value;
                      if (field.type?.includes("date")) {
                        const ts = new Date(val).getTime();
                        if (!isNaN(ts)) handleInputChange(field.name, ts);
                      } else if (field.type === "number")
                        handleInputChange(field.name, Number(val));
                      else handleInputChange(field.name, val);
                    }}
                  />
                </div>
              );
            }}
          </For>

          <Show when={props.renderCustomFields}>
            <div class="divider text-xs uppercase opacity-50 font-bold tracking-widest mt-6">
              Configuration
            </div>
            {props.renderCustomFields!(props.value, (newVal) => {
              const res =
                typeof newVal === "function"
                  ? (newVal as Function)(props.value)
                  : newVal;
              props.setValue(res);
            })}
          </Show>
        </div>

        <div class="bg-base-200/50 px-6 py-3 flex gap-2 justify-end border-t border-base-300 shrink-0">
          <button
            class="btn btn-ghost btn-sm font-medium"
            onClick={props.onCancel}
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
