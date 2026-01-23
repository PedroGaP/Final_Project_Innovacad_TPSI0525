type ClassModuleResponseData = {
  classes_modules_id: string | undefined;
  class_id: string | undefined;
  courses_modules_id: string | undefined;
  current_duration: number | undefined;
};

export class ClassModule {
  classes_modules_id: string | undefined;
  class_id: string | undefined;
  courses_modules_id: string | undefined;
  current_duration: number | undefined;

  constructor(data: ClassModuleResponseData) {
    this.classes_modules_id = data.classes_modules_id;
    this.class_id = data.class_id;
    this.courses_modules_id = data.courses_modules_id;
    this.current_duration = data.current_duration;
  }

  toJson = (): string => JSON.stringify(this);
}
