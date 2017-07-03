import { withPluginApi } from "discourse/lib/plugin-api";

function initializePostSchedules(api) {

  function decorateSchedules($elements, helper) {
    const $schedules = $(".discourse-calendar-schedule", $elements);
    if (!$schedules.length) return;

    $schedules.each((idx, scheduleElement) => {
      const $schedule = $(scheduleElement);
      const allDay = $schedule.data("schedule-all-day");
      const start = allDay ? moment.utc($schedule.data("schedule-start")) : moment($schedule.data("schedule-start"));
      const end = allDay ? moment.utc($schedule.data("schedule-end")) : moment($schedule.data("schedule-end"));
      const dateFormat = allDay ? "LL" : "LLL";
      const dateTimeText = start.format(dateFormat).concat(" ~ ").concat(end.format(dateFormat));

      $(".schedule-date-time", $schedule).text(dateTimeText);
    });
  }

  api.decorateCooked(decorateSchedules, { onlyStream: true });
}

export default {
  name: "post-schedules",

  initialize() {
    withPluginApi("0.8.7", initializePostSchedules);
  }
};
