type ScheduleResponseData = {
  schedule_id: string | undefined;
  class_module_id: string | undefined;
  availability_id: string | undefined;
  room_id: number | undefined;
  online: boolean | undefined;
  start_date_timestamp: Date | undefined;
  end_date_timestamp: Date | undefined;
};

export class Scheudle {
  schedule_id: string | undefined;
  class_module_id: string | undefined;
  availability_id: string | undefined;
  room_id: number | undefined;
  online: boolean | undefined;
  start_date_timestamp: Date | undefined;
  end_date_timestamp: Date | undefined;

  constructor(data: ScheduleResponseData) {
    this.schedule_id = data.schedule_id;
    this.class_module_id = data.class_module_id;
    this.availability_id = data.availability_id;
    this.room_id = data.room_id;
    this.online = data.online;
    this.start_date_timestamp = data.start_date_timestamp;
    this.end_date_timestamp = data.end_date_timestamp;
  }

  toJson = (): string => JSON.stringify(this);
}
