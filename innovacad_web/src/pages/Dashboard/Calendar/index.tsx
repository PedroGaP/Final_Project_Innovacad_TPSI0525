import EventCalendar from "@/components/EventCalendar";
import { createSignal } from "solid-js/types/server/reactive.js";

const eventsList = [
  {
    name: "some name",
    start: new Date(" Aug 10 2023 08:00:0"),
    end: new Date(" Aug 10 2023 10:00:00"),
    id: 16123,
    color: "#BF51F9",
    // groups: [2]
  },
  {
    name: "some name",
    start: new Date(" Aug 10 2023 10:00:0"),
    color: "#31B5F7",
    end: new Date(" Aug 10 2023 11:00:00"),
    id: 18123,
    // groups: [1]
  },
];

const Calendar = () => {
  const [initialDate, setInitialDate] = createSignal(
    new Date("Thu Aug 10 2023 15:00:0"),
  );
  const [events, setEvents] = createSignal(eventsList);

  return <EventCalendar></EventCalendar>;
};

export default Calendar;
