# frozen_string_literal: true

# name: discourse-custom-form
# about: 添加工具栏按钮并弹出包含标题、图片上传和日期的模态框，支持数据持久化
# version: 1.0.0
# authors: Your Name
# url: https://github.com/your-username/discourse-custom-form

enabled_site_setting :custom_form_enabled

register_asset "stylesheets/custom-form.scss"

after_initialize do
  # 加载模型和控制器
  require_relative "app/models/custom_form_entry"
  require_relative "app/controllers/custom_form_entries_controller"
  require_relative "app/serializers/custom_form_entry_serializer"
  
  # 注册路由
  Discourse::Application.routes.append do
    namespace :custom_form do
      resources :entries, only: [:create, :index, :show, :destroy]
    end
  end
  
  # 添加到序列化器
  add_to_serializer(:post, :custom_form_entries) do
    object.custom_form_entries.map do |entry|
      CustomFormEntrySerializer.new(entry, root: false)
    end
  end
  
  add_to_serializer(:post, :include_custom_form_entries?) do
    object.custom_form_entries.any?
  end
end
