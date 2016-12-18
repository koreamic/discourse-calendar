import { withPluginApi } from 'discourse/lib/plugin-api';
import showModal from 'discourse/lib/show-modal';
import discoveryRoute from 'discourse/routes/discovery';

function initializeDiscoursePostCalendar(api) {
  const siteSettings = api.container.lookup('site-settings:main');

  if (!siteSettings.calendar_enabled && (api.getCurrentUser() && !api.getCurrentUser().staff)) return;
  const discoveryController = api.container.lookup('controller:discovery');
  //debugger;
  discoveryController.reopen({
    actions: {
      toggleCalendar() {
        console.log("test");
      }
    }
  });
/*
  Ember.ContainerView.reopen({
    didInsertElement : function(){
      this._super();
      Ember.run.scheduleOnce('afterRender', this, this.afterRenderEvent);
    },
    afterRenderEvent : function(){
     debugger;
     console.log ("Container just got rendered");
    }
  });
*/
  api.onPageChange(() => {
    //console.log("stest");
    //console.log($('#calendar').length);
    //debugger;
    const $button = $('.calendar-toggle-button');
    $button.off('click');
    $button.click(function(){
        $(".calendar-container").slideToggle("slow");
    });
    const $div = $('.calendar');
    if($div.length > 0) initializeCalendar($div);
  });
}

function initializeCalendar($div){
  $div.fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,basicWeek,basicDay,listYear'
    },
    navLinks: true, // can click day/week names to navigate views
    editable: false,
    eventLimit: true, // allow "more" link when too many events
    events : function(start, end, timezone, callback){
      $.ajax({
        url: '/calendar/schedules',
        dataType: 'json',
        data: {
          start: start.unix(),
          end: end.unix(),
          catetory: ''
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
