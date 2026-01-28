import { createMemo, createSignal, For, Show, type JSXElement } from "solid-js";
import CopyToClipboard from "../CopyToClipboard";
import capitalize from "@/utils/capitalize";
import { Icon } from "../Icon";
import ModalDelete from "../Modal/Delete";
import ModalEdit from "../Modal/Edit";
import { Toaster } from "solid-toast";

const PAGE_SIZE = 10;

type FieldType<T> = {
  formattedName: string;
  fieldName: string;
  canCopy?: boolean;
  capitalizeValue?: boolean;
  bigger?: boolean;
  smaller?: boolean;
  customGeneration?: (entity: T) => JSXElement;
};

interface Props<T> {
  title: string;
  data: any;
  fields: FieldType<T>[];
  handleAddClick: (entity: T) => any;
  handleEditClick: (entity: T) => any;
  handleSave: (entity: T, original: T | null) => any;
  confirmDelete: (entity: T) => any;
  filter?: (entity: T, search: string) => boolean;

  renderCustomFields?: (
    formData: T,
    setFormData: (prev: (prev: T) => T) => void,
  ) => JSXElement;
}

export default function EntityTable<T>({
  data,
  fields,
  title,
  handleEditClick,
  handleAddClick,
  confirmDelete,
  handleSave,
  filter,
  renderCustomFields,
}: Props<T>) {
  const [page, setPage] = createSignal(!data() ? 1 : 0);
  const [search, setSearch] = createSignal("");
  const [editingEntity, setEditingEntity] = createSignal<T | null>(null);
  const [deletingEntity, setDeletingEntity] = createSignal<T | null>(null);
  const [originalEntity, setOriginalEntity] = createSignal<T | null>(null);

  const filteredEntity = createMemo(() => {
    const list = data() || [];
    return list.filter((e: any) => (!filter ? true : filter(e, search())));
  });

  const totalPages = createMemo(() =>
    Math.ceil(filteredEntity().length / PAGE_SIZE),
  );

  const paginatedEntity = createMemo(() => {
    const start = (page() - 1) * PAGE_SIZE;
    return filteredEntity().slice(start, start + PAGE_SIZE);
  });

  const generateTableData = (field: FieldType<T>, entity: any) => {
    const customGeneration = field.customGeneration;
    let tableData: any = customGeneration && customGeneration(entity);
    const fieldValue = entity[field.fieldName];
    const fieldValueType = typeof fieldValue;

    if (!tableData) tableData = fieldValue;

    if (field.capitalizeValue) tableData = capitalize(String(tableData));

    if (!fieldValue && fieldValueType != "boolean") return <td>N/A</td>;

    if (!customGeneration && fieldValueType == "boolean")
      return (
        <td>
          <div
            class="badge"
            classList={{
              "badge-warning": !fieldValue,
              "badge-success": fieldValue,
            }}
          >
            {fieldValue ? "Yes" : "No"}
          </div>
        </td>
      );

    if (field.canCopy)
      tableData = (
        <CopyToClipboard val={String(entity[field.fieldName])}>
          <div class="overflow-x-auto whitespace-nowrap scrollbar-thin scrollbar-thumb-slate-300 pb-1 text-xs font-mono max-w-52">
            {tableData}
          </div>
        </CopyToClipboard>
      );

    return (
      <td
        classList={{
          "w-53": field.bigger ?? false,
          "w-28": field.smaller ?? false,
        }}
      >
        {tableData}
      </td>
    );
  };

  return (
    <>
      <div class="card bg-base-100 shadow h-full flex flex-col">
        <Toaster />
        <div class="card-body gap-4 flex-1 flex flex-col overflow-hidden min-h-0 p-6">
          <div class="flex justify-between items-center shrink-0">
            <h2 class="card-title">{capitalize(title)}</h2>
            <button
              class="btn btn-primary btn-sm"
              onClick={() => {
                const newItem = handleAddClick(null as any);
                setEditingEntity(() => newItem);
                setOriginalEntity(null);
              }}
            >
              <Icon name="Plus" size={16} />
              Add
            </button>
          </div>
          <div class="shrink-0">
            <input
              type="text"
              placeholder="Search..."
              class="input input-bordered input-sm w-full max-w-xs"
              onInput={(e) => {
                setSearch(e.currentTarget.value);
                setPage(1);
              }}
            />
          </div>
          <div class="overflow-auto flex-1 border border-base-200 rounded-lg">
            <table class="table table-zebra table-pin-rows table-auto w-full ">
              <thead>
                <tr class="z-10">
                  {" "}
                  <For each={fields}>
                    {(field) => (
                      <th
                        class="bg-base-100"
                        classList={{
                          "w-52": field.bigger ?? false,
                          "w-28": field.smaller ?? false,
                        }}
                      >
                        {field.formattedName}
                      </th>
                    )}
                  </For>
                  <th class="w-28 text-right bg-base-100">Actions</th>
                </tr>
              </thead>
              <tbody>
                <For each={paginatedEntity()}>
                  {(entity) => (
                    <tr>
                      <For each={fields}>
                        {(field) => generateTableData(field, entity)}
                      </For>
                      <td class="text-right space-x-2">
                        <button
                          class="btn btn-ghost btn-sm"
                          onClick={() => {
                            const prepared = handleEditClick(entity);
                            setEditingEntity(() => prepared);
                            setOriginalEntity(() => prepared);
                          }}
                        >
                          <Icon name="Pencil" size={16} />
                        </button>
                        <button
                          class="btn btn-ghost btn-sm text-error"
                          onClick={() => setDeletingEntity(() => entity)}
                        >
                          <Icon name="Trash" size={16} />
                        </button>
                      </td>
                    </tr>
                  )}
                </For>
              </tbody>
            </table>
          </div>

          <div class="flex justify-between items-center shrink-0 pt-2">
            <span class="text-sm opacity-60">
              Page {page()} of {totalPages()}
            </span>
            <div class="join">
              <button
                class="join-item btn btn-sm"
                disabled={page() === 1}
                onClick={() => setPage(page() - 1)}
              >
                «
              </button>
              <For each={Array.from({ length: totalPages() })}>
                {(_, i) => (
                  <button
                    class="join-item btn btn-sm"
                    classList={{ "btn-active": page() === i() + 1 }}
                    onClick={() => setPage(i() + 1)}
                  >
                    {i() + 1}
                  </button>
                )}
              </For>
              <button
                class="join-item btn btn-sm"
                disabled={page() === totalPages()}
                onClick={() => setPage(page() + 1)}
              >
                »
              </button>
            </div>
          </div>
        </div>

        <Show when={editingEntity()}>
          {(u) => (
            <ModalEdit<any>
              value={u()}
              setValue={setEditingEntity}
              onSave={async (val) => {
                await handleSave(val, originalEntity());
                setEditingEntity(null);
              }}
              onCancel={() => setEditingEntity(null)}
              title={originalEntity() ? "Edit" : "Add"}
              disabledFields={originalEntity() ? ["class_id"] : []}
              renderCustomFields={renderCustomFields}
            />
          )}
        </Show>

        <Show when={deletingEntity()}>
          {(u) => (
            <ModalDelete<any>
              value={u}
              setValue={setDeletingEntity}
              onConfirm={async () => {
                await confirmDelete(u());
                setDeletingEntity(null);
              }}
              onCancel={() => setDeletingEntity(null)}
              title="Confirm Delete"
              description="Are you sure? This action is irreversible."
            />
          )}
        </Show>
      </div>
    </>
  );
}
