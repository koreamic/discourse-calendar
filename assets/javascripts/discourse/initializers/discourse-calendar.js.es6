import { withPluginApi } from 'discourse/lib/plugin-api';

function initializeDiscourseCalendar(api) {
  const siteSettings = api.container.lookup('site-settings:main');

  if (!siteSettings.calendar_enabled && (api.getCurrentUser() && !api.getCurrentUser().staff)) return;

  api.onPageChange((url, title) => {
    // toggle hide
    // calendar destroy
    // check calendar initialized????
    // click
    // -> show -> hide
    // -> hide -> show -> check reder ? not render, reder calendar
    const $button = $('.calendar-toggle-button');

    if($button.length < 1) return;

    $button.off('click');

    $(function() {
      const $calendarContainer = $('.calendar-container');
      $button.click(function(){
        if($calendarContainer.is(':visible')){
          $calendarContainer.slideUp('slow');
          $(this).find('span').text(I18n.t('calendar.ui.show_label'));
        }else{
          $calendarContainer.slideDown('slow');
          $(this).find('span').text(I18n.t('calendar.ui.hide_label'));
          $('.calendar').fullCalendar('render');
        }
      });
    });

    const $div = $('.calendar');
    if($div.length > 0) initializeCalendar(url, $div);
  });
}

function initializeCalendar(url, $div){
  $div.fullCalendar('destroy');
  $div.fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay,listMonth'
    },
    locale: moment.locale(),
    navLinks: true,   // can click day/week names to navigate views
    editable: false,
    eventLimit: true, // allow "more" link when too many events
    timeFormat:'H:m',
    height: 600,
    contentHeidht: 500,
    events : function(start, end, timezone, callback){
      $.ajax({
        url: '/calendar/schedules'.concat(url),
        dataType: 'json',
        data: {
          start: start.unix(),
          end: end.unix()
        },
        method: 'GET',
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
    withPluginApi('0.5', initializeDiscourseCalendar);
  }
};
