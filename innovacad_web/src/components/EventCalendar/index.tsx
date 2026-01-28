import {
  onMount,
  onCleanup,
  createSignal,
  createResource,
  createEffect,
  Show,
} from "solid-js";
import { Calendar, type EventInput } from "@fullcalendar/core";
import timeGridPlugin from "@fullcalendar/timegrid";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import type { Class } from "@/types/class";
import { useApi } from "@/hooks/useApi";

type Props = {
  selectedClass: Class | null;
};

const createEvent = (
  title: string,
  start: string,
  end: string,
  classNames: string[],
  room?: string,
  instructor?: string,
): EventInput => {
  return {
    title,
    start,
    end,
    classNames,
    extendedProps: {
      room: room || "Sala Indefinida",
      instructor: instructor || "Instrutor N/A",
    },
  };
};

export const EventCalendar = (props: Props) => {
  const { selectedClass } = props;
  const { fetchSchedules } = useApi();
  const [loading, setLoading] = createSignal(false);
  const [events, setEvents] = createSignal([] as EventInput[]);
  const [schedules, { refetch }] = createResource(
    () =>
      fetchSchedules(selectedClass?.class_id ?? null) || Promise.resolve([]),
  );

  createEffect(async () => {
    if (!selectedClass) return;

    setLoading(true);

    const fetchedSchedules = await refetch();

    if (!fetchedSchedules) {
      setLoading(false);
      return;
    }

    const newEvents: EventInput[] = fetchedSchedules.map((schedule) => {
      const start = schedule.start_time ?? "";
      const end = schedule.end_time ?? "";
      const classNames = [
        "bg-primary/20",
        "border-primary",
        "text-primary-content",
      ];
      return createEvent(
        schedule.module_name || "Sessão Sem Nome",
        start,
        end,
        classNames,
        schedule.room_name,
        schedule.trainer_name,
      );
    });

    setEvents(newEvents);

    setLoading(false);
  });

  let calendarEl: HTMLDivElement | undefined;
  let calendar: Calendar | undefined;

  onMount(() => {
    if (!calendarEl) return;

    calendar = new Calendar(calendarEl, {
      plugins: [timeGridPlugin, dayGridPlugin, interactionPlugin],
      timeZone: "Europe/Lisbon",

      slotLabelFormat: {
        hour: "2-digit",
        minute: "2-digit",
        omitZeroMinute: false,
        meridiem: false,
        hour12: false,
      },
      slotMinTime: "07:00:00",
      slotMaxTime: "24:00:00",
      initialView: "timeGridWeek",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay",
      },
      height: "100%",
      allDaySlot: false,
      weekends: true,
      nowIndicator: true,

      events: events(),

      eventContent: function (arg) {
        const props = arg.event.extendedProps;

        return {
          html: `
            <div class="fc-event-main-frame h-full flex flex-col justify-start p-1 gap-0.5 overflow-hidden">
              <div class="font-bold text-xs opacity-80 mb-0.5">${arg.timeText}</div>
              <div class="font-bold leading-tight text-sm">${arg.event.title}</div>
              
              ${
                props.room
                  ? `
                <div class="flex items-center gap-1 text-xs opacity-90 mt-1">
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3 flex-shrink-0">
                     <path fill-rule="evenodd" d="M9.69 18.933l.003.001C9.89 19.02 10 19 10 19s.11.02.308-.066l.002-.001.006-.003.018-.008a5.741 5.741 0 00.281-.14c.186-.096.446-.24.757-.433.62-.384 1.445-.966 2.274-1.765C15.302 14.988 17 12.493 17 9A7 7 0 103 9c0 3.492 1.698 5.988 3.355 7.584a13.731 13.731 0 002.273 1.765 11.842 11.842 0 00.976.544l.062.029.006.003.002.001.003.001a.75.75 0 01-.61-1.433zM10 11.25a2.25 2.25 0 100-4.5 2.25 2.25 0 000 4.5z" clip-rule="evenodd" />
                   </svg>
                   <span class="truncate">${props.room}</span>
                </div>
              `
                  : ""
              }

              ${
                props.instructor
                  ? `
                <div class="flex items-center gap-1 text-xs opacity-90">
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3 flex-shrink-0">
                     <path d="M10 8a3 3 0 100-6 3 3 0 000 6zM3.465 14.493a1.23 1.23 0 00.41 1.412A9.957 9.957 0 0010 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 00-13.074.003z" />
                   </svg>
                   <span class="truncate">${props.instructor}</span>
                </div>
              `
                  : ""
              }
            </div>
          `,
        };
      },
    });

    calendar.render();
  });

  onCleanup(() => {
    calendar?.destroy();
  });

  return (
    <>
      <style>
        {`
            .fc .fc-toolbar-title {
              color: var(--fallback-bc, oklch(var(--bc)));
              font-size: 1.5rem;
              font-weight: 700;
            }
            .fc th {
              color: var(--fallback-bc, oklch(var(--bc) / 0.7));
              border-color: var(--fallback-b3, oklch(var(--b3)));
            }
            .fc-timegrid-slot-label-cushion, .fc-col-header-cell-cushion {
              color: var(--fallback-bc, oklch(var(--bc)));
            }
            .fc .fc-button {
              background-color: transparent;
              border: 1px solid var(--fallback-b3, oklch(var(--b3)));
              color: var(--fallback-bc, oklch(var(--bc)));
              text-transform: capitalize;
              font-weight: 600;
              padding: 0.4rem 1rem;
              border-radius: var(--rounded-btn, 0.5rem);
              transition: 0.2s;
            }
            .fc .fc-button-primary:not(:disabled).fc-button-active,
            .fc .fc-button-primary:not(:disabled):active {
              background-color: var(--fallback-p, oklch(var(--p)));
              border-color: var(--fallback-p, oklch(var(--p)));
              color: var(--fallback-pc, oklch(var(--pc)));
            }
            .fc-timegrid-slot-label-frame {
              text-align: center;
            }
            
            .fc-event-main {
              padding: 0 !important;
            }
          `}
      </style>

      <Show
        when={!loading()}
        fallback={
          <div class="absolute inset-0 flex items-center justify-center bg-black/20 z-10">
            <div class="loading loading-spinner loading-lg"></div>
          </div>
        }
      >
        <div ref={calendarEl!} class="h-full w-full" />
      </Show>
    </>
  );
};
