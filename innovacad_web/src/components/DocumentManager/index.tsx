import { createSignal, createResource, For, Show } from "solid-js";
import { API_ENDPOINTS, useApi } from "@/hooks/useApi";
import toast from "solid-toast";
import { Icon } from "../Icon";
import useI18n from "@/hooks/useL18N";

const { t } = useI18n();

const DOCUMENT_TYPES = [
  { code: "PROFILE_PIC", label: t("general.profile_pic") },
  { code: "CV", label: t("general.cv") },
  { code: "DIPLOMA", label: t("general.diploma") },
  { code: "ID_CARD", label: t("general.id_card") },
  { code: "OTHER", label: t("general.other") },
];

interface Props {
  userId: string;
}

export default function UserDocumentsManager(props: Props) {
  const api = useApi();
  const [uploading, setUploading] = createSignal<string | null>(null);

  const [documents, { mutate, refetch }] = createResource(
    () => props.userId,
    api.fetchDocuments,
  );

  const handleUpload = async (e: Event, typeCode: string) => {
    const input = e.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) return;

    const file = input.files[0];
    const formData = new FormData();
    formData.append("file", file);
    formData.append("type", typeCode);

    setUploading(typeCode);
    try {
      await api.uploadDocument(props.userId, formData);
      toast.success(
        t(`dashboard.documents.upload_successful_${typeCode.toLowerCase()}`),
      );
      refetch();
    } catch (err: any) {
      toast.error(
        t(`dashboard.documents.upload_fail_${typeCode.toLowerCase()}`),
      );
    } finally {
      setUploading(null);
      input.value = "";
    }
  };

  const handleDelete = async (docId: string) => {
    if (!confirm(t("dashboard.documents.are_you_sure"))) return;

    try {
      await api.deleteDocument(docId);
      mutate((prev) => prev?.filter((d) => d.document_id !== docId) || []);
      toast.success(t("dashboard.documents.delete_successful"));
    } catch (err: any) {
      toast.error(t("dashboard.documents.delete_fail"));
    }
  };

  const openFile = (path: string) => {
    const cleanPath = path.startsWith("public/")
      ? path.replace("public/", "")
      : path;
    window.open(`${API_ENDPOINTS.BASE}/${cleanPath}`, "_blank");
  };

  return (
    <div class="mt-4 border-t border-base-300 pt-4">
      <h3 class="font-semibold mb-4 text-sm uppercase opacity-70">
        {t("dashboard.documents.title")}
      </h3>

      <div class="space-y-3">
        <For each={DOCUMENT_TYPES}>
          {(docType) => {
            const existingDoc = () =>
              documents()?.find((d) => d.type_code === docType.code);

            return (
              <div class="flex items-center justify-between p-3 bg-base-200 rounded-lg border border-base-300">
                <div class="flex items-center gap-3">
                  <div
                    class="w-10 h-10 rounded-full flex items-center justify-center"
                    classList={{
                      "bg-success/20 text-success": !!existingDoc(),
                      "bg-base-300 text-base-content/50": !existingDoc(),
                    }}
                  >
                    <Icon
                      name={existingDoc() ? "Check" : "FileText"}
                      size={20}
                    />
                  </div>
                  <div>
                    <p class="font-medium text-sm">{docType.label}</p>
                    <p class="text-xs opacity-60">
                      {existingDoc()
                        ? existingDoc()!.file_name
                        : t("dashboard.documents.missing")}
                    </p>
                  </div>
                </div>

                <div class="flex items-center gap-2">
                  <Show
                    when={existingDoc()}
                    fallback={
                      <div
                        class="tooltip tooltip-left"
                        data-tip={t("general.upload_file")}
                      >
                        <label
                          class={`btn btn-sm btn-ghost btn-square ${
                            uploading() === docType.code
                              ? t("general.loading")
                              : ""
                          }`}
                        >
                          {!uploading() && <Icon name="Upload" size={18} />}
                          <input
                            type="file"
                            class="hidden"
                            onChange={(e) => handleUpload(e, docType.code)}
                            disabled={!!uploading()}
                          />
                        </label>
                      </div>
                    }
                  >
                    <button
                      class="btn btn-sm btn-ghost btn-square text-info"
                      onClick={() => openFile(existingDoc()!.file_path)}
                      title={t("general.view_file")}
                    >
                      <Icon name="Eye" size={18} />
                    </button>

                    <button
                      class="btn btn-sm btn-ghost btn-square text-error"
                      onClick={() => handleDelete(existingDoc()!.document_id)}
                      title={t("general.delete")}
                    >
                      <Icon name="Trash" size={18} />
                    </button>
                  </Show>
                </div>
              </div>
            );
          }}
        </For>
      </div>
    </div>
  );
}
