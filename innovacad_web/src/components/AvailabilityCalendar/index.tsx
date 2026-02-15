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
import toast from "solid-toast";
import useI18n from "@/hooks/useL18N";

type Props = {
  isEditable: boolean;
  events: EventInput[];
  loading?: boolean;
  onCreateRequest: (start: string, end: string) => void;
  onEditRequest: (event: any) => void;
  onMoveRequest?: (event: any, start: string, end: string) => Promise<void>;
  validateDrop?: (start: string, end: string) => boolean;
};

export const AvailabilityCalendar = (props: Props) => {
  const { t, currentLang } = useI18n();
  let calendarEl: HTMLDivElement | undefined;
  let calendar: Calendar | undefined;

  const mapLocale = (lng: string) => {
    if (lng.startsWith("pt")) return "pt";
    return "en";
  };

  createEffect(() => {
    const rawEvents = props.events;
    if (calendar) {
      const cleanEvents = JSON.parse(JSON.stringify(rawEvents));
      calendar.removeAllEvents();
      calendar.addEventSource(cleanEvents);
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
          <p>👤 {eventProps.trainerName || t("common.unknown_trainer")}</p>
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
          <span
            class={`badge badge-sm mt-2 ${eventProps.is_booked ? "badge-error text-white" : "badge-success text-white"}`}
          >
            {eventProps.is_booked
              ? t("dashboard.availabilities.fields.status.booked")
              : t("dashboard.availabilities.fields.status.free")}
          </span>
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
    const startStr = info.event.startStr;
    let endStr = info.event.endStr;

    if (!endStr) {
      const s = info.event.start!;
      const e = new Date(s.getTime() + 60 * 60 * 1000);
      endStr = e.toISOString();
    }

    try {
      await props.onMoveRequest(info.event, startStr, endStr);
      toast.success(t("dashboard.availabilities.alerts.moved_success"));
    } catch (e) {
      console.error(e);
      revert();
      toast.error(t("dashboard.availabilities.alerts.moved_fail"));
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
      locale: mapLocale(currentLang()),
      firstDay: 1,
      selectMirror: true,

      eventOverlap: false,
      slotEventOverlap: false,

      snapDuration: "01:00:00",
      dragScroll: true,
      eventAllow: (dropInfo, _draggedEvent) => {
        if (!props.validateDrop) return true;
        const startStr = dropInfo.startStr;
        let endStr = dropInfo.endStr;

        if (!endStr) {
          const s = dropInfo.start!;
          const e = new Date(s.getTime() + 60 * 60 * 1000);
          endStr = e.toISOString();
        }

        return props.validateDrop(startStr, endStr);
      },

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
      buttonText: {
        today: t("dashboard.availabilities.btn.today"),
        month: t("dashboard.availabilities.btn.month"),
        week: t("dashboard.availabilities.btn.week"),
        day: t("dashboard.availabilities.btn.day"),
      },

      eventContent: function (arg) {
        const p = arg.event.extendedProps;
        return {
          html: `
            <div class="fc-event-main-frame h-full flex flex-col justify-start p-1 gap-0.5 overflow-hidden text-xs">
              <div class="font-bold opacity-80">${arg.timeText}</div>
              <div class="font-bold text-sm leading-tight truncate">${arg.event.title}</div>
               ${p.trainerName ? `<div class="flex items-center gap-1 opacity-90 truncate">👤 ${p.trainerName}</div>` : ""}
            </div>
          `,
        };
      },
    });
    calendar.render();

    createEffect(() => {
      if (!calendar) return;
      calendar.setOption("locale", mapLocale(currentLang()));
      calendar.setOption("buttonText", {
        today: t("dashboard.availabilities.btn.today"),
        month: t("dashboard.availabilities.btn.month"),
        week: t("dashboard.availabilities.btn.week"),
        day: t("dashboard.availabilities.btn.day"),
      });
    });
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
