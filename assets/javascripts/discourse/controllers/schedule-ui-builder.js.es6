import { default as computed, observes } from 'ember-addons/ember-computed-decorators';
import InputValidation from 'discourse/models/input-validation';

export default Ember.Controller.extend({
  needs: ['modal'],

  dateRegEx: /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/,
  timeRegEx: /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/,

  init() {
    this._super();
    this._setupSchedule();
  },

  @computed("hasValidStartDateTime", "hasValidEndDateTime", "hasValidDateTime")
  disableInsert(hasValidStartDateTime, hasValidEndDateTime, hasValidDateTime) {
    return !(hasValidStartDateTime && hasValidEndDateTime && hasValidDateTime);
  },
 
  @computed("hasValidStartDate", "hasValidStartTime")
  startDateTimeValidation(hasValidStartDate, hasValidStartTime) {
    let options = { ok: true };
    
    if(!hasValidStartDate || !hasValidStartTime) {
      options = { failed: true, reason: I18n.t("calendar.schedule.ui_builder.help_valid_start_date_time") };
    }

    return InputValidation.create(options);
  },

  @computed("hasValidEndDate", "hasValidEndTime", "hasValidDateTime")
  scheduleDateTimeValidation(hasValidEndDate, hasValidEndTime, hasValidDateTime) {
    let options = { ok: true };
    
    if (!hasValidEndDate || !hasValidEndTime) {
      options = { failed: true, reason: I18n.t("calendar.schedule.ui_builder.help_valid_end_date_time") };
      return InputValidation.create(options);
    }

    if(!hasValidDateTime) {
      options = { failed: true, reason: I18n.t("calendar.schedule.ui_builder.help_valid_date_time") };
      return InputValidation.create(options);
    }

    return InputValidation.create(options);
  },

  @computed("startDate")
  hasValidStartDate(startDate) {
    return this.dateRegEx.test(startDate);
  },

  @computed("startTime", "allDay")
  hasValidStartTime(startTime, allDay) {
    if (allDay) return true;
    return this.timeRegEx.test(startTime);
  },

  @computed("hasValidStartDate", "hasValidStartTime")
  hasValidStartDateTime(hasValidStartDate, hasValidStartTime) {
    return hasValidStartDate && hasValidStartTime;
  },

  @computed("endDate")
  hasValidEndDate(endDate) {
    return this.dateRegEx.test(endDate);
  },

  @computed("endTime", "allDay")
  hasValidEndTime(endTime, allDay) {
    if (allDay) return true;
    return this.timeRegEx.test(endTime);
  },

  @computed("hasValidEndDate", "hasValidEndTime")
  hasValidEndDateTime(hasValidEndDate, hasValidEndTime) {
    return hasValidEndDate && hasValidEndTime;
  },

  @computed("startDate", "startTime", "endDate", "endTime")
  hasValidDateTime(startDate, startTime, endDate, endTime) {
    return new Date(startDate + " " + startTime) <= new Date(endDate + " " + endTime);
  },

  @computed("allDay")
  isAllDaySchedule(allDay) {
    if(allDay){
      this.set("startTime", "");
      this.set("endTime", "");
    }

    return allDay;
  },

  @computed("title", "startDate", "startTime", "endDate", "endTime", "allDay", "timezoneOffset")
  scheduleOutput(title, startDate, startTime, endDate, endTime, allDay, timezoneOffset) {
    let output = "";

    output += "[schedule";
    output += " title='" + title + "'"; 
    output += " start_date_time=" + startDate + (allDay ? "" : "T" + startTime); 
    output += " end_date_time=" + endDate + (allDay ? "" : "T" + endTime); 
    output += " all_day=" + allDay; 
    output += " timezone_offset=" + timezoneOffset; 
    output += "]\n";
    output += "[/schedule]";
    
    return output;
  },

  _setupSchedule() {
    this.setProperties({
      title: "",
      startDate: "",
      startTime: "",
      endDate: "",
      endTime: "",
      timezoneOffset: new Date().getTimezoneOffset(),
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
