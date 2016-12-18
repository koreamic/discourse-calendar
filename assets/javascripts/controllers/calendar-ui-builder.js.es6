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
      fromDate: '',
      fromTime: '',
      toDate: '',
      toTime: ''
    });
  },

  @computed("title", "fromDate", "fromTime", "toDate", "toTime")
  scheduleOutput(title, fromDate, fromTime, toDate, toTime) {
    let scheduleHeader = '[schedule';
    let output = '';

    const match = this.get("toolbarEvent").getText().match(/\[schedule(\s+name=[^\s\]]+)*.*\]/igm);
    if (match) {
      scheduleHeader += ` name=schedule${match.length + 1}`;
    };
    
    output += `${scheduleHeader}`;
    output += " from="+fromDate + (fromTime ? "T"+fromDate : ""); 
    output += " to="+toDate + (toTime ? "T"+toDate : ""); 
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
