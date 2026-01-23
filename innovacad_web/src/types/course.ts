export type CourseResponseData = {
  course_id: string | undefined;
  identifier: string | undefined;
  name: string | undefined;
};

export class Course {
  course_id: string | undefined;
  identifier: string | undefined;
  name: string | undefined;

  constructor(data: CourseResponseData) {
    this.course_id = data.course_id;
    this.identifier = data.identifier;
    this.name = data.name;
  }

  toJson = (): string => JSON.stringify(this);
}
