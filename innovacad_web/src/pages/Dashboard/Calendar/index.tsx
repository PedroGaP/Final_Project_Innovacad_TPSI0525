import { EventCalendar } from "@/components/EventCalendar";
import { useApi } from "@/hooks/useApi";
import type { Class } from "@/types/class";
import { createEffect, createResource, createSignal, For } from "solid-js";

const Calendar = () => {
  const { fetchClasses } = useApi();
  const [classes, { refetch }] = createResource(fetchClasses);
  const [selectedClass, setSelectedClass] = createSignal(null as Class | null);

  createEffect(() => {});

  return (
    <div class="card w-full h-[80vh] bg-base-100 shadow-xl border border-base-300">
      <div class="card-body p-4 relative">
        <select value="Select a class" class="select">
          <option disabled={true}>Pick a color</option>
          <For each={classes()}>
            {(klass) => (
              <option
                value={klass.class_id}
                onClick={() => {
                  setSelectedClass(klass);
                }}
              >
                {klass.identifier}
              </option>
            )}
          </For>
        </select>
        <EventCalendar selectedClass={selectedClass()} />
      </div>
    </div>
  );
};

export default Calendar;
