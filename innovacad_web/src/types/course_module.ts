type CourseModuleResponseData = {
  courses_modules_id: string | undefined;
  course_id: string | undefined;
  module_id: string | undefined;
  sequence_course_module_id: string | undefined;
};

export class CourseModule {
  courses_modules_id: string | undefined;
  course_id: string | undefined;
  module_id: string | undefined;
  sequence_course_module_id: string | undefined;

  constructor(data: CourseModuleResponseData) {
    this.courses_modules_id = data.courses_modules_id;
    this.course_id = data.course_id;
    this.module_id = data.module_id;
    this.sequence_course_module_id = data.sequence_course_module_id;
  }

  toJson = (): string => JSON.stringify(this);
}
