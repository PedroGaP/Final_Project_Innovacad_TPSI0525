export enum AvailabilityStatusEnum {
  FREE = "free",
  PARTIAL = "partial",
  FULL = "full",
}

type AvailabilityResponseData = {
  availability_id: string | undefined;
  trainer_id: string | undefined;
  status: AvailabilityStatusEnum | undefined;
};

export class Availability {
  availability_id: string | undefined;
  trainer_id: string | undefined;
  status: AvailabilityStatusEnum | undefined;

  constructor(data: AvailabilityResponseData) {
    this.availability_id = data.availability_id;
    this.trainer_id = data.trainer_id;
    this.status = data.status;
  }

  toJson = (): string => JSON.stringify(this);
}
