export type ModuleResponseData = {
  module_id: string | undefined;
  name: string | undefined;
  duration: number | undefined;
  has_computers: boolean | undefined;
  has_projector: boolean | undefined;
  has_whiteboard: boolean | undefined;
  has_smartboard: boolean | undefined;
};

export class Module {
  module_id: string | undefined;
  name: string | undefined;
  duration: number | undefined;
  has_computers: boolean | undefined;
  has_projector: boolean | undefined;
  has_whiteboard: boolean | undefined;
  has_smartboard: boolean | undefined;

  constructor(data: ModuleResponseData) {
    this.module_id = data.module_id;
    this.name = data.name;
    this.duration = data.duration;
    this.has_computers = data.has_computers;
    this.has_projector = data.has_projector;
    this.has_whiteboard = data.has_whiteboard;
    this.has_smartboard = data.has_smartboard;
  }

  toJson = (): string => JSON.stringify(this);
}
