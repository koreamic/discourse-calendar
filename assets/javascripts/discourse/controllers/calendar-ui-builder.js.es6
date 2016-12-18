import { default as computed, observes } from 'ember-addons/ember-computed-decorators';
import InputValidation from 'discourse/models/input-validation';

export default Ember.Controller.extend({
  needs: ['modal'],

  init() {
    this._super();
    this._setupSchedule();
  },

  @computed("startDate")
  disableInsert(startDate) {
    //debugger;
    //return /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/.test(startDate);
    const test = (/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/.test(startDate));
    console.log("Test="+test);
    return  !(/^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/.test(startDate));
  },
 
  @computed("disableInsert")
  startDateFormatValidation(disableInsert) {
    console.log("startDateFormatValidation");
    let options = { ok: true };
    
    if(disableInsert) {
      options = { failed: true, reason: I18n.t("poll.ui_builder.help.options_count") };
    }

    return InputValidation.create(options);
  },

  @computed("title", "startDate", "startTime", "endDate", "endTime", "allDay")
  scheduleOutput(title, startDate, startTime, endDate, endTime, allDay) {
    let output = "";

    /*
    const match = this.get("toolbarEvent").getText().match(/\[schedule(\s+name=[^\s\]]+)*.*\]/igm);
    if (match) {
      scheduleHeader += ` schedule_number=${match.length + 1}`;
    }else{
      scheduleHeader += ` schedule_number=1`;
    };
    */
    
    output += "[schedule";
    output += " title="+title; 
    output += " start_date_time="+startDate + (startTime ? "T"+startTime : ""); 
    output += " end_date_time="+endDate + (endTime ? "T"+endTime : ""); 
    output += " all_day="+allDay; 
    output += "]\n";
    output += "[/schedule]";
    
    return output;
  },

  _setupSchedule() {
    this.setProperties({
      title: '',
      startDate: '',
      startTime: '',
      endDate: '',
      endTime: '',
      allDay: true
    });
  },

  actions: {
    insertSchedule() {
      this.get("toolbarEvent").addText(this.get("scheduleOutput"));
      this.send("closeModal");
      this._setupSchedule();
    }
  }
});
