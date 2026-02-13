import { useUserDetails } from "@/providers/UserDetailsProvider";
import { Upload, FileText, Trash2, Download, FileCheck } from "lucide-solid";
import { createResource, createSignal, For, Show } from "solid-js";
import GoogleLogo from "@/assets/google.svg";
import SocialAuthCard from "@/components/SocialAuthCard";
import TwoFactorCard from "@/components/TwoFactorCard";
import FacebookLogo from "@/assets/facebook.svg";
import { API_ENDPOINTS, useApi } from "@/hooks/useApi";
import { type Document, DocumentTypeLabels } from "@/types/document";
import toast from "solid-toast";
import type { Trainee, Trainer, User } from "@/types/user";
import useI18n from "@/hooks/useL18N";

const AccountSettingsPage = () => {
  const { user, setUser } = useUserDetails();
  const { t } = useI18n();
  const {
    listAccounts,
    fetchDocuments,
    uploadDocument,
    deleteDocument,
    updateTrainer,
    updateTrainee,
  } = useApi();

  const [imageKey, setImageKey] = createSignal(Date.now());
  const [accounts] = createResource(async () => listAccounts());

  const getOwnerId = () => user()?.id || "";

  const [documents, { refetch: refetchDocs }] = createResource(
    getOwnerId,
    fetchDocuments,
  );

  const [isUploading, setIsUploading] = createSignal(false);
  const [selectedDocType, setSelectedDocType] = createSignal("CV");

  let fileInputRef: HTMLInputElement | undefined;
  let avatarInputRef: HTMLInputElement | undefined;

  const formatDateForInput = (epoch: number | undefined | null) => {
    if (!epoch) return "";
    const d = new Date(0);
    d.setUTCSeconds(epoch);
    return d.toISOString().split("T")[0];
  };

  const getUserBirthday = () => {
    const currentUser = user();
    if (!currentUser) return "";
    const bday =
      (currentUser as any).birthday_date || (currentUser as any).birthdayDate;
    if (bday) return formatDateForInput(Number(bday) / 1000);
    return "";
  };

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return "0 Bytes";
    const k = 1024;
    const sizes = ["Bytes", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
  };

  const handleFileChange = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;

    if (file.size > 5 * 1024 * 1024) {
      toast.error(
        t("dashboard.documents.file_too_large") || "File too large (Max 5MB)",
      );
      return;
    }

    setIsUploading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("type", selectedDocType());

    try {
      await uploadDocument(getOwnerId()!, formData);
      toast.success(t("dashboard.documents.upload_successful"));
      refetchDocs();
      if (fileInputRef) fileInputRef.value = "";
    } catch (error: any) {
      toast.error(error.message || t("dashboard.documents.upload_fail_other"));
    } finally {
      setIsUploading(false);
    }
  };

  const handleAvatarChange = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    const u = user();

    if (!file || !u) return;
    if (!file.type.startsWith("image/")) {
      toast.error(t("dashboard.documents.upload_fail_profile_pic"));
      return;
    }

    const toastId = toast.loading(
      t("dashboard.documents.updating_profile_pic") || "Updating...",
    );
    const formData = new FormData();
    formData.append("file", file);
    formData.append("type", "PROFILE_PIC");

    try {
      await uploadDocument(u.id!, formData);
      await new Promise((r) => setTimeout(r, 800));

      const updatedDocs = await fetchDocuments(u.id!);
      const newPic = updatedDocs.find((d) => d.type_code === "PROFILE_PIC");

      if (!newPic) throw new Error("Image uploaded but not found.");

      let imagePath = newPic.file_path
        .replace(/^public[\\/]/, "")
        .replace(/\\/g, "/");

      if (u.role === "trainer" || u.role === "coordinator") {
        await updateTrainer((u as Trainer).trainerId!, {
          image: imagePath,
        } as any);
      } else if (u.role === "trainee") {
        await updateTrainee((u as Trainee).traineeId!, {
          image: imagePath,
        } as any);
      }

      const updatedUser = Object.assign(
        Object.create(Object.getPrototypeOf(u)),
        u,
      );
      updatedUser.image = imagePath;

      setUser(updatedUser as User | Trainer | Trainee);
      setImageKey(Date.now());
      toast.success(t("dashboard.documents.upload_successful_profile_pic"), {
        id: toastId,
      });
      refetchDocs();
    } catch (error: any) {
      toast.error(t("dashboard.documents.upload_fail_profile_pic"), {
        id: toastId,
      });
    } finally {
      if (avatarInputRef) avatarInputRef.value = "";
    }
  };

  const handleDeleteDoc = async (docId: string) => {
    if (!confirm(t("dashboard.documents.are_you_sure"))) return;
    try {
      await deleteDocument(docId);
      toast.success(t("dashboard.documents.delete_successful"));
      refetchDocs();
    } catch (error: any) {
      toast.error(t("dashboard.documents.delete_fail"));
    }
  };

  const handleDownload = async (doc: Document) => {
    const toastId = toast.loading(t("general.loading"));
    try {
      const cleanPath = doc.file_path.replace(/^public[\\/]/, "");
      const fileUrl = `${API_ENDPOINTS.BASE}/resource/${cleanPath}`;
      const response = await fetch(fileUrl);
      if (!response.ok) throw new Error(`File not found`);
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", doc.file_name);
      document.body.appendChild(link);
      link.click();
      link.parentNode?.removeChild(link);
      window.URL.revokeObjectURL(url);
      toast.dismiss(toastId);
    } catch (error) {
      toast.dismiss(toastId);
      toast.error(t("common.error_loading"));
    }
  };

  return (
    <>
      <div class="w-full flex-1 min-h-full border-base-300 bg-base-100">
        <div class="flex justify-between items-center p-6 border-b border-base-200">
          <div>
            <h3 class="text-lg font-bold">
              {t("dashboard.profiles.personal_info")}
            </h3>
            <p class="text-sm opacity-60">
              {t("dashboard.profiles.update_details")}
            </p>
          </div>
          <div class="flex gap-3">
            <button class="btn btn-sm btn-ghost opacity-70 hover:opacity-100">
              {t("general.cancel")}
            </button>
            <button class="btn btn-sm btn-accent text-white px-6 shadow-md">
              {t("general.save")}
            </button>
          </div>
        </div>

        <div class="p-6 space-y-8">
          <div class="form-control">
            <label class="label pt-0">
              <span class="label-text opacity-70 font-medium">
                {t("general.profile_pic")}
              </span>
            </label>
            <div class="flex items-center gap-6">
              <div class="avatar">
                <div class="w-16 h-16 rounded-full ring ring-base-200 ring-offset-2 ring-offset-base-100 overflow-hidden bg-base-300 flex items-center justify-center">
                  <Show
                    when={user()?.image && user()?.image !== "null"}
                    fallback={
                      <img
                        src={`https://ui-avatars.com/api/?name=${user()?.name || "User"}&background=random&color=fff`}
                        alt="Avatar"
                      />
                    }
                  >
                    <img
                      src={`${API_ENDPOINTS.BASE}/resource/${user()?.image}?t=${imageKey()}`}
                      alt="Avatar"
                    />
                  </Show>
                </div>
              </div>
              <div class="flex flex-col gap-1">
                <div class="flex items-center gap-3">
                  <input
                    type="file"
                    class="hidden"
                    accept="image/*"
                    ref={avatarInputRef}
                    onChange={handleAvatarChange}
                  />
                  <button
                    onClick={() => avatarInputRef?.click()}
                    class="btn btn-sm btn-outline border-base-300 normal-case font-normal"
                  >
                    <Upload size={14} class="mr-1" /> {t("general.upload_file")}
                  </button>
                  <span class="text-xs opacity-50">JPG, PNG. 1MB max</span>
                </div>
              </div>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  {t("general.name")}
                </span>
              </label>
              <input
                type="text"
                value={user()?.name || ""}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100 transition-colors"
              />
            </div>
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  {t("general.username")}
                </span>
              </label>
              <input
                type="text"
                value={user()?.username || ""}
                class="input input-bordered w-full bg-base-200 disabled:opacity-50"
                disabled
              />
            </div>
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  {t("general.email")}
                </span>
              </label>
              <input
                type="email"
                value={user()?.email || ""}
                class="input input-bordered w-full bg-base-200 disabled:opacity-50"
                disabled
              />
            </div>
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  {t("general.birthday_date")}
                </span>
              </label>
              <input
                type="date"
                value={getUserBirthday()}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100"
              />
            </div>
          </div>

          <div class="divider"></div>

          <div>
            <div class="flex justify-between items-end mb-4">
              <div>
                <h3 class="text-md font-bold flex items-center gap-2">
                  <FileCheck size={18} class="text-primary" />{" "}
                  {t("entity.documents")}
                </h3>
                <p class="text-xs opacity-60 mt-1">
                  {t("dashboard.documents.manage_desc")}
                </p>
              </div>
              <div class="flex items-center gap-2">
                <select
                  class="select select-bordered select-sm text-xs w-32"
                  value={selectedDocType()}
                  onInput={(e) => setSelectedDocType(e.currentTarget.value)}
                >
                  {Object.entries(DocumentTypeLabels).map(([key, label]) => (
                    <option value={key}>
                      {t(`general.${key.toLowerCase()}`) || label}
                    </option>
                  ))}
                </select>
                <input
                  type="file"
                  class="hidden"
                  ref={fileInputRef}
                  onChange={handleFileChange}
                />
                <button
                  class="btn btn-sm btn-primary"
                  onClick={() => fileInputRef?.click()}
                  disabled={isUploading()}
                >
                  <Show when={isUploading()} fallback={<Upload size={14} />}>
                    <span class="loading loading-spinner loading-xs"></span>
                  </Show>{" "}
                  {t("general.upload_file")}
                </button>
              </div>
            </div>
            <div class="bg-base-200/50 rounded-xl border border-base-200 overflow-hidden">
              <Show
                when={!documents.loading}
                fallback={
                  <div class="p-8 text-center text-sm opacity-50">
                    {t("general.loading")}
                  </div>
                }
              >
                <Show
                  when={documents() && documents()!.length > 0}
                  fallback={
                    <div class="p-8 text-center flex flex-col items-center gap-2 opacity-50">
                      <FileText size={32} class="opacity-30" />
                      <span>{t("general.no_data")}</span>
                    </div>
                  }
                >
                  <div class="divide-y divide-base-200">
                    <For each={documents()}>
                      {(doc) =>
                        doc.type_code !== "PROFILE_PIC" && (
                          <div class="flex items-center justify-between p-4 hover:bg-base-100 transition-colors group">
                            <div class="flex items-center gap-4">
                              <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                                <FileText size={20} />
                              </div>
                              <div class="flex flex-col">
                                <span class="font-medium text-sm truncate max-w-50 sm:max-w-xs">
                                  {doc.file_name}
                                </span>
                                <div class="flex gap-2 text-[10px] opacity-60 font-mono uppercase">
                                  <span class="badge badge-xs badge-ghost font-normal">
                                    {t(
                                      `general.${doc.type_code.toLowerCase()}`,
                                    ) || doc.type_code}
                                  </span>
                                  <span>
                                    {formatFileSize(doc.file_size_bytes)}
                                  </span>
                                  <span class="hidden sm:inline">
                                    •{" "}
                                    {new Date(
                                      doc.created_at,
                                    ).toLocaleDateString()}
                                  </span>
                                </div>
                              </div>
                            </div>
                            <div class="flex items-center gap-1 opacity-100 sm:opacity-0 group-hover:opacity-100 transition-opacity">
                              <button
                                class="btn btn-ghost btn-sm btn-square"
                                onClick={() => handleDownload(doc)}
                                title={t("general.download_file")}
                              >
                                <Download size={16} />
                              </button>
                              <button
                                class="btn btn-ghost btn-sm btn-square text-error"
                                onClick={() => handleDeleteDoc(doc.document_id)}
                                title={t("general.delete")}
                              >
                                <Trash2 size={16} />
                              </button>
                            </div>
                          </div>
                        )
                      }
                    </For>
                  </div>
                </Show>
              </Show>
            </div>
          </div>

          <div class="divider"></div>

          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">
                {t("dashboard.setting.linked_accounts")}
              </span>
            </label>
            <div class="flex flex-col gap-4">
              <SocialAuthCard
                logo={GoogleLogo}
                logo_alt="Google"
                title="Google"
                is_linked={!!accounts()?.find((a) => a.providerId == "google")}
                provider="google"
              />
              <SocialAuthCard
                logo={FacebookLogo}
                logo_alt="Facebook"
                title="Facebook"
                is_linked={
                  !!accounts()?.find((a) => a.providerId == "facebook")
                }
                provider="facebook"
              />
            </div>
          </div>

          <div class="divider pt-2"></div>
          <TwoFactorCard />
        </div>
      </div>
    </>
  );
};

export default AccountSettingsPage;
