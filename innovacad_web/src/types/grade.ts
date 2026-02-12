export enum GradeTypeEnum {
  ATTENDANCE = "attendance",
  BEHAVIOR = "behavior",
  WORK = "work",
  TEST = "test",
  FINAL = "final",
}

export enum GradeStatusEnum {
  DRAFT = "draft",
  FINALIZED = "finalized",
}

export interface GradeResponseData {
  grade_id: string;
  class_module_id: string;
  trainee_id: string;
  trainee_name?: string;
  grade: number;
  grade_type: string;
  status: string;
  created_at?: string;
  updated_at?: string;
  module_id?: string;
}

export class Grade {
  grade_id: string;
  class_module_id: string;
  trainee_id: string;
  trainee_name?: string;
  grade: number;
  grade_type: GradeTypeEnum;
  status: GradeStatusEnum;
  module_id: string;

  constructor(data: GradeResponseData) {
    this.grade_id = data.grade_id;
    this.class_module_id = data.class_module_id;
    this.trainee_id = data.trainee_id;
    this.trainee_name = data.trainee_name;
    this.grade = Number(data.grade);
    this.grade_type = data.grade_type as GradeTypeEnum;
    this.status = (data.status as GradeStatusEnum) || GradeStatusEnum.DRAFT;
    this.module_id = data.module_id || "";
  }
}
