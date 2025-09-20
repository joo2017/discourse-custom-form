# frozen_string_literal: true

# name: discourse-custom-form
# about: 添加工具栏按钮并弹出包含标题、图片上传和日期的模态框
# version: 1.0.0
# authors: Your Name
# url: https://github.com/your-username/discourse-custom-form

enabled_site_setting :custom_form_enabled

register_asset "stylesheets/custom-form.scss"

after_initialize do
  # 这里可以添加后端逻辑，比如处理表单提交
end
