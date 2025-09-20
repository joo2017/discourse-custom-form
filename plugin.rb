# frozen_string_literal: true

# name: discourse-custom-form
# about: 添加工具栏按钮并弹出包含标题、图片上传和日期的模态框，支持数据持久化
# version: 1.0.0
# authors: Your Name
# url: https://github.com/your-username/discourse-custom-form

enabled_site_setting :custom_form_enabled

register_asset "stylesheets/custom-form.scss"

after_initialize do
  # 加载控制器文件
  load File.expand_path('../app/controllers/custom_form_entries_controller.rb', __FILE__)
  
  # 注册路由 - 注意：不要使用 namespace，直接使用 resources
  Discourse::Application.routes.append do
    get '/custom_form/entries' => 'custom_form_entries#index'
    post '/custom_form/entries' => 'custom_form_entries#create'
    get '/custom_form/entries/:id' => 'custom_form_entries#show'
    delete '/custom_form/entries/:id' => 'custom_form_entries#destroy'
  end
  
  # 扩展 Post 模型
  Post.class_eval do
    has_many :custom_form_entries, dependent: :destroy
  end
end
