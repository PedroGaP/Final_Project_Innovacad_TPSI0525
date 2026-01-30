type CourseModuleResponseData = {
  courses_modules_id: string | undefined;
  module_id: string | undefined;
  sequence_course_module_id: string | undefined;
  module_name: string | undefined;
  duration: number | undefined;
};

export type CourseModule = {
  courses_modules_id?: string;
  module_id: string;
  sequence_course_module_id?: string | null;
  module_name?: string;
  duration?: number;
};
