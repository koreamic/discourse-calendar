import { withPluginApi } from 'discourse/lib/plugin-api';
import showModal from 'discourse/lib/show-modal';

function initializeCalendarUIBuilder(api) {
  const siteSettings = api.container.lookup('site-settings:main');

  if (!siteSettings.calendar_enabled && (api.getCurrentUser() && !api.getCurrentUser().staff)) return;

  const ComposerController = api.container.lookupFactory("controller:composer");
  ComposerController.reopen({
    actions: {
      showCalendarBuilder() {
        showModal("calendar-ui-builder").set("toolbarEvent", this.get("toolbarEvent"));
      }
    }
  });

  api.addToolbarPopupMenuOptionsCallback(function() {
    return {
      action: 'showCalendarBuilder',
      icon: 'calendar',
      label: 'calendar.ui_builder.title'
    };
  });
}

export default {
  name: "add-calendar-ui-builder",

  initialize() {
    withPluginApi('0.5', initializeCalendarUIBuilder);
  }
};
