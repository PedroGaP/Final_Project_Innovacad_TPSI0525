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

const AccountSettingsPage = () => {
  const { user } = useUserDetails();
  const { listAccounts, fetchDocuments, uploadDocument, deleteDocument } =
    useApi();

  const [accounts] = createResource(async () => listAccounts());

  const getOwnerId = () => {
    const u = user();
    if (!u) return "";

    console.log(`ID DO USER: ${u.id}`);

    return u.id;
  };

  const [documents, { refetch: refetchDocs }] = createResource(
    getOwnerId,
    fetchDocuments,
  );

  const [isUploading, setIsUploading] = createSignal(false);
  const [selectedDocType, setSelectedDocType] = createSignal("CV");
  let fileInputRef: HTMLInputElement | undefined;

  const formatDateForInput = (epoch: number | undefined | null) => {
    if (!epoch) return "";
    const d = new Date(0);
    d.setUTCSeconds(epoch);
    return d.toISOString().split("T")[0];
  };

  const getUserBirthday = () => {
    const currentUser = user();
    if (!currentUser) return "";
    if ("birthdayDate" in currentUser) {
      return formatDateForInput((currentUser as any).birthdayDate);
    }
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
      toast.error("File is too large. Max 5MB.");
      return;
    }

    setIsUploading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("type", selectedDocType());

    try {
      await uploadDocument(getOwnerId()!, formData);
      toast.success("Document uploaded successfully!");
      refetchDocs();

      if (fileInputRef) fileInputRef.value = "";
    } catch (error: any) {
      toast.error(error.message || "Failed to upload document");
    } finally {
      setIsUploading(false);
    }
  };

  const handleDeleteDoc = async (docId: string) => {
    if (!confirm("Are you sure you want to delete this document?")) return;
    try {
      await deleteDocument(docId);
      toast.success("Document deleted");
      refetchDocs();
    } catch (error: any) {
      toast.error("Failed to delete document");
    }
  };

  const openFileSelector = () => {
    fileInputRef?.click();
  };

  const handleDownload = async (doc: Document) => {
    const toastId = toast.loading(`Downloading ${doc.file_name}...`);

    try {
      const cleanPath = doc.file_path.replace(/^public[\\/]/, "");

      const backendUrl = API_ENDPOINTS.BASE;
      const fileUrl = `${backendUrl}/${cleanPath}`;

      const response = await fetch(fileUrl);

      if (!response.ok) {
        throw new Error(`File not found (Status: ${response.status})`);
      }

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
      toast.success("Download completed");
    } catch (error) {
      console.error("Download error:", error);
      toast.dismiss(toastId);
      toast.error(
        "Failed to download file. It might be missing from the server.",
      );
    }
  };

  return (
    <>
      <div class="w-full flex-1 min-h-full border-base-300 bg-base-100">
        {/* Header */}
        <div class="flex justify-between items-center p-6 border-b border-base-200">
          <div>
            <h3 class="text-lg font-bold">Personal Info</h3>
            <p class="text-sm opacity-60">Update your personal details</p>
          </div>
          <div class="flex gap-3">
            <button class="btn btn-sm btn-ghost opacity-70 hover:opacity-100">
              Cancel
            </button>
            <button class="btn btn-sm btn-accent text-white px-6 shadow-md">
              Save
            </button>
          </div>
        </div>

        <div class="p-6 space-y-8">
          {/* Avatar Section */}
          <div class="form-control">
            <label class="label pt-0">
              <span class="label-text opacity-70 font-medium">Your photo</span>
            </label>
            <div class="flex items-center gap-6">
              <div class="avatar">
                <div class="w-16 h-16 rounded-full ring ring-base-200 ring-offset-2 ring-offset-base-100">
                  <Show
                    when={!!user()?.image}
                    fallback={
                      <img
                        src={"https://ui-avatars.com/api/?name=" + user()!.name}
                        alt="User avatar"
                      />
                    }
                  >
                    <img src={user()!.image!} alt="avatar" />
                  </Show>
                </div>
              </div>
              <div class="flex flex-col gap-1">
                <div class="flex items-center gap-3">
                  <button class="btn btn-sm btn-outline border-base-300 hover:border-base-content hover:bg-base-200 hover:text-base-content normal-case font-normal">
                    <Upload size={14} class="mr-1" /> Upload Image
                  </button>
                  <span class="text-xs opacity-50">JPG or PNG. 1MB max</span>
                </div>
              </div>
            </div>
          </div>

          {/* Form Fields */}
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">Full name</span>
              </label>
              <input
                type="text"
                value={user()!.name || ""}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
              />
            </div>

            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">Username</span>
              </label>
              <input
                type="text"
                value={user()!.username || ""}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
                disabled
              />
            </div>

            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">Email</span>
              </label>
              <input
                type="email"
                value={user()!.email || ""}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary transition-colors"
                disabled
              />
            </div>

            <div class="form-control w-full">
              <label class="label">
                <span class="label-text opacity-70 font-medium">
                  Date of birth
                </span>
              </label>
              <input
                type="date"
                value={getUserBirthday()}
                class="input input-bordered w-full bg-base-200 focus:bg-base-100 focus:border-primary"
              />
            </div>
          </div>

          <div class="divider"></div>

          {/* --- DOCUMENTS SECTION --- */}
          <div>
            <div class="flex justify-between items-end mb-4">
              <div>
                <h3 class="text-md font-bold flex items-center gap-2">
                  <FileCheck size={18} class="text-primary" />
                  Documents
                </h3>
                <p class="text-xs opacity-60 mt-1">
                  Manage your CVs, Certificates, and IDs.
                </p>
              </div>

              {/* Upload Controls */}
              <div class="flex items-center gap-2">
                <select
                  class="select select-bordered select-sm text-xs w-32"
                  value={selectedDocType()}
                  onInput={(e) => setSelectedDocType(e.currentTarget.value)}
                >
                  {Object.entries(DocumentTypeLabels).map(([key, label]) => (
                    <option value={key}>{label}</option>
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
                  onClick={openFileSelector}
                  disabled={isUploading()}
                >
                  {isUploading() ? (
                    <span class="loading loading-spinner loading-xs"></span>
                  ) : (
                    <Upload size={14} />
                  )}
                  Upload
                </button>
              </div>
            </div>

            <div class="bg-base-200/50 rounded-xl border border-base-200 overflow-hidden">
              <Show
                when={!documents.loading}
                fallback={
                  <div class="p-8 text-center text-sm opacity-50">
                    Loading documents...
                  </div>
                }
              >
                <Show
                  when={documents() && documents()!.length > 0}
                  fallback={
                    <div class="p-8 text-center flex flex-col items-center gap-2 opacity-50">
                      <FileText size={32} class="opacity-30" />
                      <span class="text-sm">No documents uploaded yet.</span>
                    </div>
                  }
                >
                  <div class="divide-y divide-base-200">
                    <For each={documents()}>
                      {(doc) => (
                        <div class="flex items-center justify-between p-4 hover:bg-base-100 transition-colors group">
                          <div class="flex items-center gap-4">
                            <div class="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-primary">
                              <FileText size={20} />
                            </div>
                            <div class="flex flex-col">
                              <span
                                class="font-medium text-sm truncate max-w-50 sm:max-w-xs"
                                title={doc.file_name}
                              >
                                {doc.file_name}
                              </span>
                              <div class="flex gap-2 text-[10px] opacity-60 font-mono uppercase">
                                <span class="badge badge-xs badge-ghost font-normal">
                                  {DocumentTypeLabels[doc.type_code] ||
                                    doc.type_code}
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
                              class="btn btn-ghost btn-sm btn-square text-base-content/70 hover:text-primary tooltip tooltip-left"
                              data-tip="Download"
                              onClick={() => handleDownload(doc)}
                            >
                              <Download size={16} />
                            </button>
                            <button
                              class="btn btn-ghost btn-sm btn-square text-error/70 hover:text-error hover:bg-error/10 tooltip tooltip-left"
                              data-tip="Delete"
                              onClick={() => handleDeleteDoc(doc.document_id)}
                            >
                              <Trash2 size={16} />
                            </button>
                          </div>
                        </div>
                      )}
                    </For>
                  </div>
                </Show>
              </Show>
            </div>
          </div>

          <div class="divider"></div>

          {/* Social Accounts */}
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">
                Linked Accounts
              </span>
            </label>

            <div class="flex flex-col gap-4">
              <SocialAuthCard
                logo={GoogleLogo}
                logo_alt="Google Logo"
                title="Google"
                is_linked={
                  accounts()?.find((a) => a.providerId == "google") != null
                }
                provider="google"
              />
              <SocialAuthCard
                logo={FacebookLogo}
                logo_alt="Facebook Logo"
                title="Facebook"
                is_linked={
                  accounts()?.find((a) => a.providerId == "facebook") != null
                }
                provider="facebook"
              />
            </div>
          </div>

          <div class="divider pt-2"></div>

          {/* Security */}
          <div class="form-control w-full">
            <label class="label">
              <span class="label-text opacity-70 font-medium">
                Security Settings
              </span>
            </label>
            <TwoFactorCard />
          </div>
        </div>
      </div>
    </>
  );
};

export default AccountSettingsPage;
