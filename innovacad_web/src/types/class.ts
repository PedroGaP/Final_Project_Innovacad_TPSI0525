export enum ClassStatusEnum {
  ON_GOING = "ongoing",
  FINISHED = "finished",
  STARTING = "starting",
}

export const ClassStatusEnumLookUp = {
  ON_GOING: ClassStatusEnum.ON_GOING,
  FINISHED: ClassStatusEnum.FINISHED,
  STARTING: ClassStatusEnum.STARTING,
};

export type ClassModule = {
  classes_modules_id: string;
  courses_modules_id: string;
  current_duration?: number;
  module_name?: string;
  total_duration?: number;
};

export type ClassResponseData = {
  class_id: string | undefined;
  course_id: string | undefined;
  location: string | undefined;
  identifier: string | undefined;
  status: ClassStatusEnum | undefined;
  start_date_timestamp: number | undefined;
  end_date_timestamp: number | undefined;
  modules?: ClassModule[];
};

export class Class {
  class_id: string | undefined;
  course_id: string | undefined;
  location: string | undefined;
  identifier: string | undefined;
  status: ClassStatusEnum | undefined;
  start_date_timestamp: number | undefined;
  end_date_timestamp: number | undefined;
  modules: ClassModule[];

  constructor(data: ClassResponseData) {
    this.class_id = data.class_id;
    this.course_id = data.course_id;
    this.location = data.location;
    this.status = data.status;
    this.identifier = data.identifier;
    this.start_date_timestamp = data.start_date_timestamp;
    this.end_date_timestamp = data.end_date_timestamp;
    this.modules = data.modules || [];
  }

  toJson = (): string => JSON.stringify(this);
}
