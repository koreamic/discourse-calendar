import { registerOption } from "pretty-text/pretty-text";

const DATA_PREFIX = "data-schedule-";
const WHITELISTED_ATTRIBUTES = ["title", "all_day", "start_date_time", "end_date_time"];
const ATTRIBUTES_REGEX = new RegExp("(" + WHITELISTED_ATTRIBUTES.join("|") + ")=(['\"][\\S\\s\^\\]]+['\"]|['\"]?[^\\s\\]]+['\"]?)", "g");
const VALUE_REGEX = new RegExp("^['\"]?([\\s\\S]+)['\"]?$", "g");

registerOption((siteSettings, opts) => {
  opts.features.schedule = true;
});

export function setup(helper) {
  helper.whiteList([
    "div.discourse-calendar-schedule discourse-ui-card",
    "div[data-*]",
    "div.content",
    "div.schedule-date-time content",
    "div.extra content",
    "div.header"
  ]);


  helper.replaceBlock({
    start: new RegExp("\\[schedule((?:\\s+(?:" + WHITELISTED_ATTRIBUTES.join("|") + ")=(?:['\"][^\\n]+['\"]|[^\\s\\]]+))+)\\]([\\s\\S]*)", "igm"),
    stop: /\[\/schedule\]/igm,

    emitter(blockContents, matches) {
      const attributes = { "class": "discourse-calendar-schedule discourse-ui-card" };
      const contents = [];

      if (blockContents.length){
        const postProcess = bc => {
          if (typeof bc === "string" || bc instanceof String) {
            const processed = this.processInline(String(bc));
            if (processed.length) {
              contents.push(["p"].concat(processed));
            }
          } else {
            contents.push(bc);
          }
        };

        let b;
        while ((b = blockContents.shift()) !== undefined) {
          this.processBlock(b, blockContents).forEach(postProcess);
        }
      }
      

      const title = [];
      const duration = ["div", {"class": "schedule-date-time content"}];
      const extraContents = ["div", {"class": "extra content"}];
      let startDateTime;
      let endDateTime;
      let dateFormat = "LLL";
      let allDay = false;
      let startEndRange = " ~ ";
      (matches[1].match(ATTRIBUTES_REGEX) || []).forEach(function(m) {
        const idx = m.indexOf("=");
        const name = m.substring(0, idx);
        let value = m.substring(idx+1);
        if(value.startsWith("'") && value.endsWith("'") || value.startsWith("\"") && value.endsWith("\"")){
          value = value.substring(1, value.length-1);
        }
               
        const escaped = helper.escape(value);
        switch (name) {
          case "title":
            if(escaped) title.push("div", {"class": "content"}, ["div", {"class": "header"}, escaped]);
            break;

          case "start_date_time":
            startDateTime = new Date(escaped);
            break;

          case "end_date_time":
            endDateTime = new Date(escaped);
            break;

          case "all_day":
            allDay = (escaped === "true");
            break;
        }
      });

      if(!startDateTime || isNaN(startDateTime.getDate()) || (endDateTime && isNaN(endDateTime.getDate()))){
        return ["div"].concat(contents);
      }

      if(!endDateTime){
        if(allDay){
         endDateTime = new Date(startDateTime);
        }else{
         endDateTime = new Date(startDateTime);
         endDateTime = endDateTime.setHours(endDateTime.getHours() + 1);
        }
      }
      
      attributes[DATA_PREFIX + "start"] = startDateTime.getTime().toString();
      attributes[DATA_PREFIX + "end"] = endDateTime.getTime().toString();
      attributes[DATA_PREFIX + "all-day"] = allDay.toString();

      if(allDay) {
        startEndRange = startDateTime.toDateString().concat(startEndRange).concat(endDateTime.toDateString());
      }else{
        startEndRange = startDateTime.toDateString().concat(" ".concat(startDateTime.toLocaleTimeString())).concat(startEndRange).concat(endDateTime.toDateString().concat(" ".concat(endDateTime.toLocaleTimeString())));
      }

      const schedule = ["div", attributes];

      if(title.length > 0) schedule.push(title);
      duration.push(startEndRange);
      schedule.push(duration);

      if(contents && contents.length > 0){
        extraContents.push(contents[0]);
        schedule.push(extraContents);
      }

      return schedule;
    }
  });
}
