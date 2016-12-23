import ModalBodyView from "discourse/views/modal-body";

export default ModalBodyView.extend({
  needs: ['modal'],

  templateName: 'modals/schedule-ui-builder',
  title: I18n.t('calendar.schedule.ui_builder.title')
  
});
