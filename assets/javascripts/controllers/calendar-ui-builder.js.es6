import { default as computed, observes } from 'ember-addons/ember-computed-decorators';
import InputValidation from 'discourse/models/input-validation';

export default Ember.Controller.extend({
  needs: ['modal'],

  init() {
    this._super();
    this._setupSchedule();
  },

  _setupSchedule() {
    this.setProperties({
      title: '',
      startDate: '',
      startTime: '',
      endDate: '',
      endTime: ''
    });
  },

  @computed("title", "startDate", "startTime", "endDate", "endTime")
  scheduleOutput(title, startDate, startTime, endDate, endTime) {
    let scheduleHeader = '[schedule';
    let output = '';

    const match = this.get("toolbarEvent").getText().match(/\[schedule(\s+name=[^\s\]]+)*.*\]/igm);
    if (match) {
      scheduleHeader += ` schedule_number=${match.length + 1}`;
    }else{
      scheduleHeader += ` schedule_number=1`;
    };
    
    output += `${scheduleHeader}`;
    output += " start_date_time="+startDate + (startTime ? "T"+startTime : ""); 
    output += " end_date_time="+endDate + (endTime ? "T"+endTime : ""); 
    output += "]";
    output += title;
    output += "[/schedule]";
    
    return output;
  },

  actions: {
    insertSchedule() {
      this.get("toolbarEvent").addText(this.get("scheduleOutput"));
      this.send("closeModal");
      this._setupSchedule();
    }
  }
});
