// 在 submitForm 方法中更新：
@action
async submitForm() {
  if (!this.validateForm()) {
    return;
  }

  this.isSubmitting = true;

  try {
    const formData = {
      title: this.title,
      date: this.selectedDate,
      image_upload_id: this.uploadedImage?.id
    };

    // 模拟提交成功
    await new Promise(resolve => setTimeout(resolve, 1000));

    // 在编辑器中插入表单内容
    const toolbarEvent = this.args.model.toolbarEvent;
    let content = `## ${this.title}\n\n`;
    content += `**日期:** ${this.selectedDate}\n\n`;
    
    if (this.uploadedImage) {
      content += `![${this.title}](${this.uploadedImage.url})\n\n`;
    }

    toolbarEvent.addText(content);

    this.dialog.alert(I18n.t("custom_form.success_message"));
    this.args.closeModal();

  } catch (error) {
    popupAjaxError(error);
  } finally {
    this.isSubmitting = false;
  }
}
