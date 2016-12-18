import { withPluginApi } from 'discourse/lib/plugin-api';
import showModal from 'discourse/lib/show-modal';
import DiscoveryRoute from 'discourse/routes/discovery';
import DiscoveryController from 'discourse/controllers/discovery';
import Category from 'discourse/models/category';

function initializeDiscoursePostCalendar(api) {
  const siteSettings = api.container.lookup('site-settings:main');

  if (!siteSettings.calendar_enabled && (api.getCurrentUser() && !api.getCurrentUser().staff)) return;
 // const discoveryController = api.container.lookup('controller:discovery');

  Ember.ContainerView.reopen({
    didInsertElement : function(){
      this._super();
      Ember.run.scheduleOnce('afterRender', this, this.afterRenderEvent);
    },
    afterRenderEvent : function(){
      /*
      toggle hide
      calendar destroy
      check calendar initialized????
      click
      -> show -> hide
      -> hide -> show -> check reder ? not render, reder calendar
      */
      const $button = $('.calendar-toggle-button');
      const $div = $('.calendar');
      $button.off('click');

      $button.click(function(){
        debugger;
        const $calendarContainer = $('.calendar-container');
        if($calendarContainer.is(':visible')){
          $calendarContainer.slideUp('slow');
        }else{
          $calendarContainer.slideDown('slow');
        }
      });

      if($div.length > 0) initializeCalendar($div);
      console.log ("Container just got rendered");
    }
  });

  /*
  api.onPageChange(() => {
    //debugger;
    const $button = $('.calendar-toggle-button');
    $button.off('click');
    $button.click(function(){
        $(".calendar-container").slideToggle("slow");
    });

    const $div = $('.calendar');
    if($div.length > 0) initializeCalendar($div);
  });
  */
}

function initializeCalendar($div){
  $div.fullCalendar('destroy');
  $div.fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,basicWeek,basicDay,listYear'
    },
    navLinks: true, // can click day/week names to navigate views
    editable: false,
    eventLimit: true, // allow "more" link when too many events
    timeFormat:'H:m',
    events : function(start, end, timezone, callback){
      debugger;
      $.ajax({
        url: '/calendar/schedules',
        dataType: 'json',
        data: {
          start: start.unix(),
          end: end.unix(),
          catetory: Category.id
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
  name: "discourse-post-calendar",

  initialize() {
    withPluginApi('0.5', initializeDiscoursePostCalendar);
  }
};