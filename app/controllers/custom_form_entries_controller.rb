# frozen_string_literal: true

class CustomFormController < ApplicationController
  before_action :ensure_logged_in

  def save
    begin
      # 这个控制器主要用于临时保存表单数据
      # 实际的数据保存会在帖子发布时通过 CustomFormProcessor 处理
      
      render json: {
        success: true,
        message: "表单数据已准备就绪",
        form_data: params[:custom_form_data]
      }
      
    rescue => e
      Rails.logger.error "CustomFormController#save error: #{e.message}"
      render json: {
        success: false,
        error: "服务器错误: #{e.message}"
      }, status: 500
    end
  end
end
