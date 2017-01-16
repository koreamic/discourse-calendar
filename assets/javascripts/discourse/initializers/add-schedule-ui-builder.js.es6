import { withPluginApi } from "discourse/lib/plugin-api";
import showModal from "discourse/lib/show-modal";

function initializeScheduleUIBuilder(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  if (!siteSettings.calendar_enabled) return;

  const ComposerController = api.container.lookupFactory("controller:composer");
  ComposerController.reopen({
    actions: {
      showScheduleBuilder() {
        showModal("schedule-ui-builder").set("toolbarEvent", this.get("toolbarEvent"));
      }
    }
  });

  api.addToolbarPopupMenuOptionsCallback(function() {
    return {
      action: "showScheduleBuilder",
      icon: "calendar",
      label: "calendar.schedule.ui_builder.title"
    };
  });
}

export default {
  name: "add-schedule-ui-builder",

  initialize() {
    withPluginApi("0.5", initializeScheduleUIBuilder);
  }
};
