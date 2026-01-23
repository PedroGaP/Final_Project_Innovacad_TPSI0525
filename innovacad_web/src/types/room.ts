type RoomResponseData = {
  room_id: number | undefined;
  room_name: string | undefined;
  capacity: number | undefined;
  has_computers: boolean | undefined;
  has_projector: boolean | undefined;
  has_whiteboard: boolean | undefined;
  has_smartboard: boolean | undefined;
};

export class Room {
  room_id: number | undefined;
  room_name: string | undefined;
  capacity: number | undefined;
  has_computers: boolean | undefined;
  has_projector: boolean | undefined;
  has_whiteboard: boolean | undefined;
  has_smartboard: boolean | undefined;

  constructor(data: RoomResponseData) {
    this.room_id = data.room_id;
    this.room_name = data.room_name;
    this.capacity = data.capacity;
    this.has_computers = data.has_computers;
    this.has_projector = data.has_projector;
    this.has_whiteboard = data.has_whiteboard;
    this.has_smartboard = data.has_smartboard;
  }

  toJson = (): string => JSON.stringify(this);
}
