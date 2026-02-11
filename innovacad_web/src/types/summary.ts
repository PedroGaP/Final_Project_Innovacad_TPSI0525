export interface StudentAttendance {
  trainee_id: string;
  name: string;
  image: string | null;
  is_absent: boolean;
}

export interface SummaryGridResponse {
  summary_id: string | null;
  schedule_id: string;
  contents: string | null;
  students: StudentAttendance[];
}

export interface SaveSummaryPayload {
  schedule_id: string;
  contents: string;
  attendances: {
    trainee_id: string;
    is_absent: boolean;
  }[];
}
