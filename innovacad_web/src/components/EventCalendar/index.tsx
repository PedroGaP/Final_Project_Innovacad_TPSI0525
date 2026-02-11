import { onMount, onCleanup, createEffect, Show } from "solid-js";
import {
  Calendar,
  type EventInput,
  type DateSelectArg,
  type EventClickArg,
  type EventDropArg,
} from "@fullcalendar/core";
import { type EventResizeDoneArg } from "@fullcalendar/interaction";
import timeGridPlugin from "@fullcalendar/timegrid";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import type { Class } from "@/types/class";
import toast from "solid-toast";

type Props = {
  selectedClass: Class | null;
  isEditable: boolean;
  events: EventInput[];
  loading?: boolean;
  onCreateRequest: (start: string, end: string) => void;
  onEditRequest: (event: any) => void;
  onMoveRequest?: (id: string, start: Date, end: Date) => Promise<void>;
};

export const EventCalendar = (props: Props) => {
  let calendarEl: HTMLDivElement | undefined;
  let calendar: Calendar | undefined;

  createEffect(() => {
    const rawEvents = props.events;

    if (calendar) {
      const cleanEvents = JSON.parse(JSON.stringify(rawEvents));
      calendar.removeAllEvents();
      calendar.addEventSource(cleanEvents);

      if (cleanEvents.length > 0) {
        const firstEventDate = new Date(cleanEvents[0].start);
        if (
          !isNaN(firstEventDate.getTime()) &&
          firstEventDate.getFullYear() > 2000
        ) {
          calendar.gotoDate(firstEventDate);
        }
      } else {
        calendar.today();
      }
    }
  });

  createEffect(() => {
    const editable = props.isEditable;
    if (calendar) {
      calendar.setOption("editable", editable);
      calendar.setOption("selectable", editable);
      calendar.setOption("eventStartEditable", editable);
      calendar.setOption("eventDurationEditable", editable);
    }
  });

  const handleDateSelect = (selectInfo: DateSelectArg) => {
    if (!props.isEditable) return;
    props.onCreateRequest(selectInfo.startStr, selectInfo.endStr);
    calendar?.unselect();
  };

  const handleEventClick = (clickInfo: EventClickArg) => {
    const eventProps = clickInfo.event.extendedProps;

    if (!props.isEditable) {
      toast.custom((_) => (
        <div class="bg-base-100 border border-base-300 p-4 rounded-lg shadow-xl text-sm pointer-events-auto z-50">
          <h4 class="font-bold text-lg mb-1">{clickInfo.event.title}</h4>
          <p>👤 {eventProps.instructor || "N/A"}</p>
          <p>🏠 {eventProps.roomName || eventProps.room || "N/A"}</p>
          <p>
            🕒{" "}
            {clickInfo.event.start?.toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            })}{" "}
            -{" "}
            {clickInfo.event.end?.toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </p>
          {eventProps.regime && (
            <span class="badge badge-sm badge-ghost mt-2">
              {eventProps.regime === "post-work" ? "Pós-Laboral" : "Diurno"}
            </span>
          )}
        </div>
      ));
      return;
    }

    props.onEditRequest({
      id: clickInfo.event.id,
      title: clickInfo.event.title,
      start: clickInfo.event.start,
      end: clickInfo.event.end,
      extendedProps: eventProps,
    });
  };

  const handleEventDrop = async (info: EventDropArg | EventResizeDoneArg) => {
    if (!props.onMoveRequest) return;

    const revert = info.revert;

    const start = info.event.start!;
    let end = info.event.end;

    if (!end) {
      end = new Date(start.getTime() + 60 * 60 * 1000);
    }

    try {
      await props.onMoveRequest(info.event.id, start, end);
      toast.success("Schedule moved!");
    } catch (e) {
      console.error(e);
      revert();
      toast.error("Could not move session.");
    }
  };

  onMount(() => {
    if (!calendarEl) return;

    const initialEvents = JSON.parse(JSON.stringify(props.events || []));

    calendar = new Calendar(calendarEl, {
      plugins: [timeGridPlugin, dayGridPlugin, interactionPlugin],
      editable: props.isEditable,
      selectable: props.isEditable,
      timeZone: "local",
      locale: "pt",
      firstDay: 1,
      selectMirror: true,

      eventOverlap: false,
      slotEventOverlap: false,

      select: handleDateSelect,
      eventClick: handleEventClick,

      eventDrop: handleEventDrop,
      eventResize: handleEventDrop,

      slotLabelFormat: {
        hour: "2-digit",
        minute: "2-digit",
        omitZeroMinute: false,
        meridiem: false,
        hour12: false,
      },
      slotMinTime: "08:00:00",
      slotMaxTime: "23:00:00",
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
      events: initialEvents,

      eventContent: function (arg) {
        const p = arg.event.extendedProps;
        return {
          html: `
            <div class="fc-event-main-frame h-full flex flex-col justify-start p-1 gap-0.5 overflow-hidden text-xs">
              <div class="font-bold opacity-80">${arg.timeText}</div>
              <div class="font-bold text-sm leading-tight truncate">${arg.event.title}</div>
              ${p.roomName ? `<div class="flex items-center gap-1 mt-1 opacity-90 truncate">🏠 ${p.roomName}</div>` : ""}
              ${p.instructor ? `<div class="flex items-center gap-1 opacity-90 truncate">👤 ${p.instructor}</div>` : ""}
              ${p.isOnline ? `<div class="absolute top-1 right-1 text-[10px]">🌐</div>` : ""}
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
            .fc .fc-toolbar-title { font-size: 1.25rem; font-weight: 700; color: var(--color-base-content); }
            .fc-event { border: none; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
            .fc th { border-color: var(--color-base-300); }
            .fc-timegrid-slot { border-color: var(--color-base-300); }
            
            .fc .fc-button {
                border-radius: var(--rounded-btn, 0.5rem);
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                font-size: 0.75rem;
                padding: 0 0.75rem;
                height: 2.25rem;
                min-height: 2.25rem;
                transition: 0.2s;
                border: none;
                opacity: 1;
                box-shadow: none;
            }
            .fc .fc-button:focus { box-shadow: none !important; }
            .fc .fc-button-primary { 
                background-color: var(--color-primary); 
                color: var(--color-primary-content); 
            }
            .fc .fc-button-primary:hover { 
                background-color: var(--color-primary); 
                opacity: 0.8; 
            }
            .fc .fc-button-primary:not(:disabled).fc-button-active,
            .fc .fc-button-primary:not(:disabled):active {
                background-color: var(--color-primary-focus, var(--color-primary));
                opacity: 1;
            }
            .fc .fc-button:disabled {
                background-color: var(--color-neutral);
                color: var(--color-neutral-content);
                opacity: 0.5;
            }
        `}
      </style>

      <div class="relative h-full w-full">
        <Show when={props.loading}>
          <div class="absolute inset-0 z-50 flex items-center justify-center bg-base-100/50 backdrop-blur-[1px]">
            <span class="loading loading-dots loading-lg text-primary"></span>
          </div>
        </Show>

        <div ref={calendarEl!} class="h-full w-full" />
      </div>
    </>
  );
};
