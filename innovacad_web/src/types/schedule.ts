export type ScheduleResponseData = {
  schedule_id?: string;
  regime_type?: string;
  module_name?: string;
  trainer_name?: string;
  date_day?: string;
  start_time?: string;
  end_time?: string;
  is_online?: string;
  room_name?: string;
};

export class Schedule {
  schedule_id: string | undefined;
  regime_type: string | undefined;
  module_name: string | undefined;
  trainer_name: string | undefined;
  date_day: Date | undefined;
  start_time: string | undefined;
  end_time: string | undefined;
  is_online: string | undefined;
  room_name: string | undefined;

  constructor(data: ScheduleResponseData) {
    this.schedule_id = data.schedule_id;
    this.regime_type = data.regime_type;
    this.module_name = data.module_name;
    this.trainer_name = data.trainer_name;

    this.date_day = data.date_day ? new Date(data.date_day) : undefined;

    this.start_time = data.start_time;
    this.end_time = data.end_time;
    this.is_online = data.is_online;
    this.room_name = data.room_name;
  }

  toJson = (): string => JSON.stringify(this);

  get isOnlineBoolean(): boolean {
    return this.is_online === "true" || this.is_online === "1";
  }
}
