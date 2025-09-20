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

    // 如果有 post，添加 post_id
    if (this.args.model.post?.id) {
      formData.post_id = this.args.model.post.id;
    }

    const response = await ajax("/custom_form/entries", {
      type: "POST",
      data: formData
    });

    this.dialog.alert(I18n.t("custom_form.success_message"));
    this.args.closeModal();

    // 触发事件通知其他组件更新
    this.args.model.onEntryCreated?.(response);

  } catch (error) {
    if (error.jqXHR?.responseJSON?.errors) {
      this.errors = { general: error.jqXHR.responseJSON.errors.join(", ") };
    } else {
      popupAjaxError(error);
    }
  } finally {
    this.isSubmitting = false;
  }
}
