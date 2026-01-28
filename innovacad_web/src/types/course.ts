import { type CourseModule } from "@/types/course_module";

export type CourseResponseData = {
  course_id: string | undefined;
  identifier: string | undefined;
  name: string | undefined;
  modules: CourseModule[] | undefined;
};

export class Course {
  course_id: string | undefined;
  identifier: string | undefined;
  name: string | undefined;
  modules: CourseModule[] | undefined;

  constructor(data: CourseResponseData) {
    this.course_id = data.course_id;
    this.identifier = data.identifier;
    this.name = data.name;
    this.modules = data.modules;
  }

  toJson = (): string => JSON.stringify(this);
}
