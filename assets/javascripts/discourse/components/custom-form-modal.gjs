import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import DModalCancel from "discourse/components/d-modal-cancel";
import UppyImageUploader from "discourse/components/uppy-image-uploader";
import { Input } from "@ember/component";
import { on } from "@ember/modifier";
import { i18n } from "discourse-i18n";
import icon from "discourse-common/helpers/d-icon";

export default class CustomFormModal extends Component {
  @service dialog;
  @service siteSettings;
  @tracked title = "";
  @tracked selectedDate = "";
  @tracked description = "";
  @tracked uploadedImage = null;
  @tracked isSubmitting = false;
  @tracked errors = {};

  @action
  updateTitle(event) {
    this.title = event.target.value;
    if (this.errors.title && this.title.trim()) {
      delete this.errors.title;
    }
  }

  @action
  updateDate(event) {
    this.selectedDate = event.target.value;
    if (this.errors.event_date && this.selectedDate) {
      delete this.errors.event_date;
    }
  }

  @action
  updateDescription(event) {
    this.description = event.target.value;
  }

  @action
  onImageUploaded(upload) {
    this.uploadedImage = upload;
  }

  @action
  validateForm() {
    this.errors = {};
    let isValid = true;

    if (!this.title.trim()) {
      this.errors.title = I18n.t("custom_form.form.title_required");
      isValid = false;
    }

    if (!this.selectedDate) {
      this.errors.event_date = I18n.t("custom_form.form.date_required");
      isValid = false;
    }

    return isValid;
  }

  @action
  async submitForm() {
    if (!this.validateForm()) {
      return;
    }

    this.isSubmitting = true;

    try {
      const formData = {
        custom_form_entry: {
          title: this.title,
          event_date: this.selectedDate,
          description: this.description,
          image_upload_id: this.uploadedImage?.id
        }
      };

      if (this.args.model.post?.id) {
        formData.post_id = this.args.model.post.id;
      }

      console.log("发送请求数据:", formData);

      const response = await ajax("/custom_form/entries", {
        type: "POST",
        data: formData
      });

      console.log("收到响应:", response);

      if (response.success) {
        // 在编辑器中插入内容（恢复之前的功能）
        const toolbarEvent = this.args.model.toolbarEvent;
        if (toolbarEvent) {
          let content = `## ${this.title}\n\n`;
          content += `**日期:** ${this.selectedDate}\n\n`;
          
          if (this.description) {
            content += `**描述:** ${this.description}\n\n`;
          }
          
          if (this.uploadedImage) {
            content += `![${this.title}](${this.uploadedImage.url})\n\n`;
          }
          
          toolbarEvent.addText(content);
        }
        
        this.dialog.alert(response.message || "表单提交成功！");
        this.args.closeModal();
        this.args.model.onEntryCreated?.(response.entry);
      } else {
        this.errors = { general: response.error || "提交失败" };
      }

    } catch (error) {
      console.error("AJAX 错误:", error);
      console.error("响应文本:", error.jqXHR?.responseText);
      
      let errorMessage = "提交失败";
      
      if (error.jqXHR?.responseJSON) {
        const jsonError = error.jqXHR.responseJSON;
        if (jsonError.error) {
          errorMessage = jsonError.error;
        } else if (jsonError.errors) {
          errorMessage = Array.isArray(jsonError.errors) ? 
            jsonError.errors.join(", ") : 
            jsonError.errors;
        }
      } else if (error.jqXHR?.responseText) {
        errorMessage = `服务器错误 (${error.jqXHR.status}): 请查看服务器日志`;
      }
      
      this.errors = { general: errorMessage };
    } finally {
      this.isSubmitting = false;
    }
  }

  @action
  cancel() {
    this.args.closeModal();
  }

  <template>
    <DModal
      @title={{i18n "custom_form.modal_title"}}
      @closeModal={{@closeModal}}
      class="custom-form-modal"
    >
      <:body>
        <form class="custom-form">
          {{#if this.errors.general}}
            <div class="alert alert-error">{{this.errors.general}}</div>
          {{/if}}

          <div class="form-group">
            <label for="custom-form-title" class="form-label">
              {{i18n "custom_form.form.title_label"}}
              <span class="required">*</span>
            </label>
            <Input
              @type="text"
              @value={{this.title}}
              {{on "input" this.updateTitle}}
              placeholder={{i18n "custom_form.form.title_placeholder"}}
              id="custom-form-title"
              class="form-control {{if this.errors.title 'error'}}"
            />
            {{#if this.errors.title}}
              <div class="error-message">{{this.errors.title}}</div>
            {{/if}}
          </div>

          <div class="form-group">
            <label for="custom-form-date" class="form-label">
              {{i18n "custom_form.form.date_label"}}
              <span class="required">*</span>
            </label>
            <Input
              @type="date"
              @value={{this.selectedDate}}
              {{on "input" this.updateDate}}
              id="custom-form-date"
              class="form-control {{if this.errors.event_date 'error'}}"
            />
            {{#if this.errors.event_date}}
              <div class="error-message">{{this.errors.event_date}}</div>
            {{/if}}
          </div>

          <div class="form-group">
            <label for="custom-form-description" class="form-label">
              {{i18n "custom_form.form.description_label"}}
            </label>
            <textarea
              {{on "input" this.updateDescription}}
              id="custom-form-description"
              class="form-control"
              rows="3"
              placeholder={{i18n "custom_form.form.description_placeholder"}}
            >{{this.description}}</textarea>
          </div>

          {{#if this.siteSettings.custom_form_allow_image_upload}}
            <div class="form-group">
              <label class="form-label">
                {{i18n "custom_form.form.image_label"}}
              </label>
              <UppyImageUploader
                @id="custom-form-image"
                @type="composer"
                @uploadUrl="/uploads.json"
                @done={{this.onImageUploaded}}
                class="image-uploader"
              />
              {{#if this.uploadedImage}}
                <div class="uploaded-image-preview">
                  <img src={{this.uploadedImage.url}} alt="预览" class="preview-image" />
                </div>
              {{/if}}
            </div>
          {{/if}}
        </form>
      </:body>

      <:footer>
        <DButton
          @action={{this.submitForm}}
          @disabled={{this.isSubmitting}}
          class="btn-primary custom-form-submit"
        >
          {{#if this.isSubmitting}}
            {{icon "spinner" class="loading-icon"}}
          {{/if}}
          {{i18n "custom_form.form.submit"}}
        </DButton>
        
        <DModalCancel @close={{this.cancel}} />
      </:footer>
    </DModal>
  </template>
}
