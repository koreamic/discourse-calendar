import { withPluginApi } from "discourse/lib/plugin-api";

function initializePostSchedules(api) {

  function decorateSchedules($elements, helper) {
    const $schedules = $(".discourse-calendar-schedule", $elements);
    if (!$schedules.length) return;

    $schedules.each((idx, scheduleElement) => {
      const $schedule = $(scheduleElement);
      const start = $schedule.data("schedule-start");
      const end = $schedule.data("schedule-end");
      const dateFormat = $schedule.data("schedule-all-day") ? "LL" : "LLL";
      //const dateTimeText = moment(start).format(dateFormat).concat(" ~ ").concat(moment(end).format(dateFormat));
      const dateTimeText = moment(start).minute(-moment().utcOffset()).format(dateFormat).concat(" ~ ").concat(moment(end).minute(-moment().utcOffset()).format(dateFormat));

      $(".schedule-date-time", $schedule).text(dateTimeText);
    });
  }

  api.decorateCooked(decorateSchedules, { onlyStream: true });
}

export default {
  name: "post-schedules",

  initialize() {
    withPluginApi("0.5", initializePostSchedules);
  }
};
