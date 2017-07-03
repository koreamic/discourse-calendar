import { withPluginApi } from "discourse/lib/plugin-api";

function initializeDiscourseCalendar(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  if (!siteSettings.calendar_enabled) return;

  api.onPageChange((url, title) => {
    const $button = $(".calendar-toggle-button");
    const postfixUrl = url.replace(Discourse.BaseUri, "");
    const locale = siteSettings.calendar_locale;

    if($button.length < 1) return;

    $button.off("click");

    $(function() {
      const $calendarContainer = $(".calendar-container");
      $button.click(function(){
        if($calendarContainer.is(":visible")){
          $calendarContainer.slideUp("slow");
          $(this).find("span").text(I18n.t("calendar.ui.show_label"));
        }else{
          $calendarContainer.slideDown("slow");
          $(this).find("span").text(I18n.t("calendar.ui.hide_label"));
          $(".calendar").fullCalendar("render");
        }
      });
    });

    const $div = $(".calendar");

    if($div.length > 0) initializeCalendar(postfixUrl, $div, locale);
  });
}

function initializeCalendar(postfixUrl, $div, locale){
  $div.fullCalendar("destroy");
  $div.fullCalendar({
    header: {
      left: "prev,next today",
      center: "title",
      right: "month,agendaWeek,agendaDay,listMonth"
    },
    locale: moment.locale(locale),
    navLinks: true,
    editable: false,
    eventLimit: true,
    timeFormat:"H:m",
    height: 600,
    contentHeidht: 500,
    timezone: "local",
    events : function(start, end, timezone, callback){
      $.ajax({
        url: Discourse.getURL("/calendar/schedules".concat(postfixUrl)),
        dataType: "json",
        data: {
          start: start.unix(),
          end: end.unix(),
          timezone: timezone,
        },
        method: "GET",
        success: function(data){
          var events = data.schedules;
          callback(events);
        }
      });
    }
  });
}

export default {
  name: "discourse-calendar",

  initialize() {
    withPluginApi("0.8.7", initializeDiscourseCalendar);
  }
};
