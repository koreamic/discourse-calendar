import ModalBodyView from "discourse/views/modal-body";

export default ModalBodyView.extend({
  needs: ['modal'],

  templateName: 'modals/calendar-ui-builder',
  title: I18n.t('calendar.ui_builder.title')
});
