# frozen_string_literal: true

# name: discourse-custom-form
# about: 添加工具栏按钮并弹出包含标题、图片上传和日期的模态框，使用自定义字段保存
# version: 2.0.0
# authors: Your Name
# url: https://github.com/your-username/discourse-custom-form

enabled_site_setting :custom_form_enabled

register_asset "stylesheets/custom-form.scss"

PLUGIN_NAME = "discourse-custom-form"

after_initialize do
  # 注册自定义字段类型
  register_post_custom_field_type("custom_form_title", :string)
  register_post_custom_field_type("custom_form_date", :string)
  register_post_custom_field_type("custom_form_description", :text)
  register_post_custom_field_type("custom_form_image_upload_id", :integer)
  
  # 确保自定义字段包含在序列化中
  TopicView.default_post_custom_fields << "custom_form_title"
  TopicView.default_post_custom_fields << "custom_form_date"
  TopicView.default_post_custom_fields << "custom_form_description"
  TopicView.default_post_custom_fields << "custom_form_image_upload_id"

  # 加载处理类
  load File.expand_path('../lib/custom_form_processor.rb', __FILE__)
  load File.expand_path('../app/controllers/custom_form_controller.rb', __FILE__)

  # 注册路由
  Discourse::Application.routes.append do
    post '/custom_form/save' => 'custom_form#save'
  end

  # 添加到序列化器
  add_to_serializer(:post, :custom_form_data, include_condition: -> { object.has_custom_form? }) do
    {
      title: object.custom_fields["custom_form_title"],
      date: object.custom_fields["custom_form_date"],
      description: object.custom_fields["custom_form_description"],
      image_upload_id: object.custom_fields["custom_form_image_upload_id"]
    }
  end

  # 扩展 Post 模型
  Post.class_eval do
    def has_custom_form?
      custom_fields["custom_form_title"].present?
    end

    def custom_form_image_upload
      return nil unless custom_fields["custom_form_image_upload_id"].present?
      Upload.find_by(id: custom_fields["custom_form_image_upload_id"])
    end
  end

  # 在帖子处理时解析和保存自定义字段
  on(:post_process_cooked) do |doc, post|
    CustomFormProcessor.update(post)
  end

  # 在帖子恢复时也处理
  on(:post_recovered) do |post, _, _|
    CustomFormProcessor.update(post)
  end

  # 在帖子更新时也处理
  on(:post_edited) do |post, topic_changed, _|
    CustomFormProcessor.update(post)
  end
end
