import { withPluginApi } from "discourse/lib/plugin-api";
import { default as computed, observes } from 'ember-addons/ember-computed-decorators';
import showModal from "discourse/lib/show-modal";

function initializeScheduleUIBuilder(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  if (!siteSettings.calendar_enabled && (api.getCurrentUser() && !api.getCurrentUser().staff)) return;

  const ComposerController = api.container.lookupFactory("controller:composer");
  ComposerController.reopen({
    actions: {
      showScheduleBuilder() {
        showModal("schedule-ui-builder").set("toolbarEvent", this.get("toolbarEvent"));
      }
    },
    @computed('model.topicFirstPost')
    topicFirstPost(topicFirstPost){
      return topicFirstPost;
    }
  });

  api.addToolbarPopupMenuOptionsCallback(() => {
    return {
      action: "showScheduleBuilder",
      icon: "calendar",
      label: "calendar.schedule.ui_builder.title",
      condition: "topicFirstPost"
    };
  });
}

export default {
  name: "add-schedule-ui-builder",

  initialize() {
    withPluginApi("0.5", initializeScheduleUIBuilder);
  }
};
