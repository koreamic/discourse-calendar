import { registerOption } from 'pretty-text/pretty-text';

const WHITELISTED_ATTRIBUTES = ["title", "all_day", "start_date_time", "end_date_time"];
const ATTRIBUTES_REGEX = new RegExp("(" + WHITELISTED_ATTRIBUTES.join("|") + ")=(['\"][\\S\\s\^\\]]+['\"]|['\"]?[^\\s\\]]+['\"]?)", "g");
const VALUE_REGEX = new RegExp("^['\"]?([\\s\\S]+)['\"]?$", "g");

registerOption((siteSettings, opts) => {
  opts.features.schedule = true;
});

export function setup(helper) {
  helper.whiteList([
    'div.discourse-calendar-schedule discourse-ui-card',
    'div.content',
    'div.extra content',
    'div.header'
  ]);


  helper.replaceBlock({
    //start: /\[schedule((?:\s+\w+=[^\s\]]+)*)\]([\s\S]*)/igm,
    //start: /\[schedule((?:\s+\w+=[\S\s\]]+)*)\]([\s\S]*)/igm,
    //start: /\[schedule((?:\s+\w+=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?))*)\]([\s\S]*)/igm,
    //start: /\[schedule((?:\s+\w+=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?))+)\]([\s\S]*)/igm,
    //start: /\[schedule((?:\s+(?:title|all_day|start_date_time|end_date_time)=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?))+)\]([\s\S]*)/igm,
    start: new RegExp("\\[schedule((?:\\s+(?:" + WHITELISTED_ATTRIBUTES.join("|") + ")=(?:['\"][\\S\\s^\\]]+['\"]|['\"]?[^\\s\\]]+['\"]?))+)\\]([\\s\\S]*)", "igm"),
    stop: /\[\/schedule\]/igm,

    emitter(blockContents, matches) {
      //const schedule = ["div"];
      //const schedule = ["div", {"class": "ui card"}];
      const schedule = ["div", {"class": "discourse-calendar-schedule discourse-ui-card"}];
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
      
      const title = ["div", {"class": "content"}];
      const duration = ["div", {"class": "content"}];
      const extraContents = ["div", {"class": "extra content"}];
      let startDateTime;
      let endDateTime;
      let dateFormat = "LLL";
      let allDay = false;
      let startEndRange = " ~ ";
      (matches[1].match(ATTRIBUTES_REGEX) || []).forEach(function(m) {
        //const [ name, value ] = m.split("=");
        const idx = m.indexOf("=");
        const name = m.substring(0, idx);
        let value = m.substring(idx+1);
        if(value.startsWith("'") && value.endsWith("'") || value.startsWith("\"") && value.endsWith("\"")){
          value = value.substring(1, value.length-1);
        }
               
        const escaped = helper.escape(value);
        //const escaped = helper.escape(value.replace(/["']/g, ""));

        switch (name) {
          case "title":
            title.push(["div", {"class": "header"}, escaped]);
            break;

          case "start_date_time":
            //startDateTime = moment(escaped);
            startDateTime = new Date(escaped);
            break;

          case "end_date_time":
            //endDateTime = moment(escaped);
            endDateTime = new Date(escaped);
            break;

          case "all_day":
            //dateFormat = (escaped === "true") ? "LL" : " LLL";
            allDay = (escaped === "true");
            break;
        }
      });

      if(!startDateTime || isNaN(startDateTime.getDate()) || (endDateTime && isNaN(endDateTime.getDate()))){
        return ["div"].concat(contents);
      }
      
      //startEndRange = startDateTime.format(dateFormat).concat(startEndRange).concat(endDateTime.format(dateFormat));
      if(allDay) {
        startEndRange = startDateTime.toDateString().concat(startEndRange).concat(endDateTime.toDateString());
      }else{
        startEndRange = startDateTime.toDateString().concat(" ".concat(startDateTime.toLocaleTimeString())).concat(startEndRange).concat(endDateTime.toDateString().concat(" ".concat(endDateTime.toLocaleTimeString())));
      }

      duration.push(startEndRange);
      schedule.push(title);
      schedule.push(duration);

      if(contents && contents.length > 0){
        extraContents.push(contents[0]);
        schedule.push(extraContents);
      }

      return schedule;
    }
  });
}
