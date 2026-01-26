export enum AvailabilityStatusEnum {
  FREE = "free",
  PARTIAL = "partial",
  FULL = "full",
}

export type AvailabilityResponseData = {
  availability_id: string | undefined;
  trainer_id: string | undefined;
  status: AvailabilityStatusEnum | undefined;
  start_date_timestamp: string | undefined;
  end_date_timestamp: string | undefined;
};

export class Availability {
  availability_id: string | undefined;
  trainer_id: string | undefined;
  status: AvailabilityStatusEnum | undefined;
  start_date_timestamp: string | undefined;
  end_date_timestamp: string | undefined;

  constructor(data: AvailabilityResponseData) {
    this.availability_id = data.availability_id;
    this.trainer_id = data.trainer_id;
    this.status = data.status;
    this.start_date_timestamp = data.start_date_timestamp;
    this.end_date_timestamp = data.end_date_timestamp;
  }

  toJson = (): string => JSON.stringify(this);
}
