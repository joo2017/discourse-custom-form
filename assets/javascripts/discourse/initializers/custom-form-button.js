import { withPluginApi } from "discourse/lib/plugin-api";
import CustomFormModal from "../components/custom-form-modal";

function initializeCustomFormButton(api) {
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "custom_form",
      group: "extras",
      icon: "plus",
      title: "custom_form.button_title",
      perform: (editor) => {
        const modal = api.container.lookup("service:modal");
        modal.show(CustomFormModal, {
          model: {
            editor: editor
          }
        });
      }
    });
  });
}

export default {
  name: "custom-form-button",
  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");
    
    if (siteSettings.custom_form_enabled) {
      withPluginApi("0.12.0", initializeCustomFormButton);
    }
  }
};
