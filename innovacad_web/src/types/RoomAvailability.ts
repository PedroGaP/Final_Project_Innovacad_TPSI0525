export type RoomBusySlotResponseDto = {
    start?: string | number;
    end?: string | number;
    start_time?: string;
    end_time?: string;
    description?: string;
    module_name?: string;
    schedule_id?: string;
};

export class RoomBusySlot {
    start: Date;
    end: Date;
    description?: string;

    constructor(data: RoomBusySlotResponseDto) {
        const start = data.start_time ? parseInt(data.start_time) : data.start;
        const end = data.end_time ? parseInt(data.end_time) : data.end;

        this.start = new Date(start || 0);
        this.end = new Date(end || 0);

        this.description = data.module_name || data.description;
    }
}
