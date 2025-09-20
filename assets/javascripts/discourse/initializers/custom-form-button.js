import { withPluginApi } from "discourse/lib/plugin-api";
import CustomFormModal from "../components/custom-form-modal";

export default {
  name: "custom-form-button",
  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");
    
    if (siteSettings.custom_form_enabled) {
      withPluginApi("0.12.0", (api) => {
        const modal = container.lookup("service:modal");
        
        api.onToolbarCreate((toolbar) => {
          toolbar.addButton({
            id: "custom_form",
            group: "extras",
            icon: "plus",
            title: "custom_form.button_title",
            perform: (toolbarEvent) => {
              // 获取当前 post 对象
              const composerModel = toolbarEvent.composer?.model;
              const currentPost = composerModel?.post;
              
              modal.show(CustomFormModal, {
                model: {
                  toolbarEvent: toolbarEvent,
                  post: currentPost,
                  onEntryCreated: (entry) => {
                    // 可以在这里处理条目创建后的逻辑
                    console.log("Entry created:", entry);
                  }
                }
              });
            }
          });
        });
      });
    }
  }
};
