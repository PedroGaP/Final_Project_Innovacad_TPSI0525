export type AvailabilityResponseData = {
  availability_id?: string;
  trainer_id?: string;
  date_day?: string | number;
  slot_number?: number;
  is_booked?: boolean | number;
};

export class Availability {
  availability_id: string | undefined;
  trainer_id: string | undefined;
  date_day: string | undefined;
  slot_number: number | undefined;
  is_booked: boolean | undefined;

  constructor(data: AvailabilityResponseData) {
    this.availability_id = data.availability_id;
    this.trainer_id = data.trainer_id;

    if (data.date_day) {
      const strVal = String(data.date_day);
      if (!isNaN(Number(strVal)) && !strVal.includes("-")) {
        let ts = Number(strVal);
        if (ts < 100000000000) ts *= 1000;
        this.date_day = new Date(ts).toISOString().split("T")[0];
      }
      else if (strVal.includes("T")) {
        this.date_day = strVal.split("T")[0];
      }
      else {
        this.date_day = strVal;
      }
    } else {
      this.date_day = "";
    }

    this.slot_number = data.slot_number;
    this.is_booked = !!data.is_booked;
  }
}
