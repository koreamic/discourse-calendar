import { registerOption } from 'pretty-text/pretty-text';

const WHITELISTED_ATTRIBUTES = ["from", "to"];
const ATTRIBUTES_REGEX = new RegExp("(" + WHITELISTED_ATTRIBUTES.join("|") + ")=['\"]?[^\\s\\]]+['\"]?", "g");

registerOption((siteSettings, opts) => {
  opts.features.schedule = true;
});

export function setup(helper) {
  helper.whiteList([
    'table',
    'tbody',
    'thead',
    'tr',
    'td',
    'td[colspan]',
    'th',
    'th[colspan]'
  ]);


  helper.replaceBlock({
    start: /\[schedule((?:\s+\w+=[^\s\]]+)*)\]([\s\S]*)/igm,
    stop: /\[\/schedule\]/igm,

    emitter(blockContents, matches) {
      const result = ["table"];
      if(blockContents.length){
        const titleHead = ["tr"];
        //TODO TITLE locale config set
        titleHead.push(["th", {"colspan":"4"}, "TITLE"]);
        result.push(titleHead);
        const titleBody = ["tr"];
        titleBody.push(["td", {"colspan":"4"}, String(blockContents[0])]);
        result.push(titleBody);
      }
      

      const durations = ["tr"];
      (matches[1].match(ATTRIBUTES_REGEX) || []).forEach(function(m) {
        const [ name, value ] = m.split("=");
        const escaped = helper.escape(value.replace(/["']/g, ""));
        durations.push(["th", name]);
        durations.push(["td", escaped]);
      });
      
      result.push(durations);

      return result;
    }
  });
}
