type ModuleResponseData = {
  module_id: string | undefined;
  name: string | undefined;
  duration: number | undefined;
};

export class Module {
  module_id: string | undefined;
  name: string | undefined;
  duration: number | undefined;

  constructor(data: ModuleResponseData) {
    this.module_id = data.module_id;
    this.name = data.name;
    this.duration = data.duration;
  }

  toJson = (): string => JSON.stringify(this);
}
