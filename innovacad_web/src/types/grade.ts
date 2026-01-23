export enum GradeTypeEnum {
  FINAL = "final",
  ASSESSMENT = "assessment",
}

export type GradeResponseData = {
  grade_id: string | undefined;
  class_module_id: string | undefined;
  trainee_id: string | undefined;
  grade: string | undefined;
  grade_type: GradeTypeEnum | undefined;
};

export class Grade {
  grade_id: string | undefined;
  class_module_id: string | undefined;
  trainee_id: string | undefined;
  grade: string | undefined;
  grade_type: GradeTypeEnum | undefined;

  constructor(data: GradeResponseData) {
    this.grade_id = data.grade_id;
    this.class_module_id = data.class_module_id;
    this.trainee_id = data.trainee_id;
    this.grade = data.grade;
    this.grade_type = data.grade_type;
  }

  toJson = (): string => JSON.stringify(this);
}
