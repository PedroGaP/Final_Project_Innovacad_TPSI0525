export interface Document {
  document_id: string;
  file_name: string;
  file_path: string;
  mime_type: string;
  file_size_bytes: number;
  type_code: "CV" | "DIPLOMA" | "ID_CARD" | "OTHER";
  created_at: string;
}

export const DocumentTypeLabels: Record<string, string> = {
  CV: "Curriculum Vitae",
  DIPLOMA: "Diploma/Certificate",
  ID_CARD: "ID Card",
  OTHER: "Other",
};
