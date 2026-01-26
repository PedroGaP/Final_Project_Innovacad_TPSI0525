export type EnrollmentResponseData = {
  enrollment_id: string | undefined;
  class_id: string | undefined;
  trainee_id: string | undefined;
  final_grade: number | undefined;
};

export class Enrollment {
  enrollment_id: string | undefined;
  class_id: string | undefined;
  trainee_id: string | undefined;
  final_grade: number | undefined;

  constructor(data: EnrollmentResponseData) {
    this.enrollment_id = data.enrollment_id;
    this.class_id = data.class_id;
    this.trainee_id = data.trainee_id;
    this.final_grade = data.final_grade;
  }

  toJson = (): string => JSON.stringify(this);
}
