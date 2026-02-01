export type ScheduleResponseData = {
  schedule_id?: string;
  regime_type?: string;
  module_name?: string;
  trainer_name?: string;
  date_day?: string;
  start_time?: string;
  end_time?: string;
  is_online?: boolean;
  room_name?: string;

  class_module_id?: string;
  trainer_id?: string;
  room_id?: number;
  total_hours?: number;

  start_date_timestamp?: string;
  end_date_timestamp?: string;
};

export class Schedule {
  schedule_id: string | undefined;
  regime_type: string | undefined;
  module_name: string | undefined;
  trainer_name: string | undefined;
  is_online: boolean | undefined;
  room_name: string | undefined;

  start: Date | undefined;
  end: Date | undefined;

  class_module_id: string | undefined;
  trainer_id: string | undefined;
  room_id: number | undefined;

  constructor(data: ScheduleResponseData) {
    this.schedule_id = data.schedule_id;
    this.regime_type = data.regime_type;
    this.module_name = data.module_name;
    this.trainer_name = data.trainer_name;
    this.is_online = data.is_online;
    this.room_name = data.room_name;

    this.class_module_id = data.class_module_id;
    this.trainer_id = data.trainer_id;
    this.room_id = data.room_id;

    if (data.start_date_timestamp && data.end_date_timestamp) {
      this.start = new Date(data.start_date_timestamp);
      this.end = new Date(data.end_date_timestamp);
    }
    else if (data.date_day && data.start_time && data.end_time) {
      try {
        const timestamp = parseInt(data.date_day, 10);

        if (isNaN(timestamp)) {
          console.error("[Schedule Error] Invalid Timestamp:", data.date_day);
        } else {
          const baseDate = new Date(timestamp);

          const [sh, sm] = data.start_time.split(":").map(Number);
          const [eh, em] = data.end_time.split(":").map(Number);

          const startDate = new Date(baseDate);
          startDate.setHours(sh, sm, 0);

          const endDate = new Date(baseDate);
          endDate.setHours(eh, em, 0);

          this.start = startDate;
          this.end = endDate;

        }
      } catch (e) {
        console.error("[Schedule Error] Parsing failed:", e);
      }
    } else {
      console.warn(
        "[Schedule Warning] Missing date/time data for:",
        data.schedule_id,
      );
    }
  }

  get isOnlineBoolean(): boolean {
    return !!this.is_online;
  }
}
