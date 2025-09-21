# frozen_string_literal: true

class CustomFormEntriesController < ApplicationController
  before_action :ensure_logged_in
  before_action :find_entry, only: [:show, :destroy]

  def index
    begin
      entries = CustomFormEntry.includes(:user, :image_upload)
                               .order(:event_date)
                               .limit(50)
      
      render json: {
        success: true,
        entries: entries.map { |entry| serialize_entry(entry) }
      }
    rescue => e
      Rails.logger.error "CustomFormEntriesController#index error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { 
        success: false, 
        error: e.message 
      }, status: 500
    end
  end

  def create
    begin
      Rails.logger.info "CustomFormEntriesController#create called"
      Rails.logger.info "Params: #{params.inspect}"
      Rails.logger.info "Current user: #{current_user.id}"
      
      entry_params_hash = entry_params
      Rails.logger.info "Entry params: #{entry_params_hash.inspect}"
      
      entry = CustomFormEntry.new(entry_params_hash.merge(user: current_user))
      
      if params[:post_id].present?
        post = Post.find_by(id: params[:post_id])
        entry.post = post if post
      end
      
      if entry.save
        Rails.logger.info "Entry saved successfully: #{entry.id}"
        render json: {
          success: true,
          message: "表单提交成功",
          entry: serialize_entry(entry)
        }
      else
        Rails.logger.error "Entry validation failed: #{entry.errors.full_messages}"
        render json: { 
          success: false,
          errors: entry.errors.full_messages 
        }, status: 422
      end
      
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Record not found: #{e.message}"
      render json: { 
        success: false, 
        error: "记录未找到: #{e.message}" 
      }, status: 404
      
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "Database error: #{e.message}"
      render json: { 
        success: false, 
        error: "数据库错误，请检查表结构是否正确" 
      }, status: 500
      
    rescue => e
      Rails.logger.error "CustomFormEntriesController#create error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { 
        success: false, 
        error: "服务器错误: #{e.message}" 
      }, status: 500
    end
  end

  def show
    begin
      render json: {
        success: true,
        entry: serialize_entry(@entry)
      }
    rescue => e
      Rails.logger.error "CustomFormEntriesController#show error: #{e.message}"
      render json: { 
        success: false, 
        error: e.message 
      }, status: 500
    end
  end

  def destroy
    begin
      unless can_delete?
        render json: { 
          success: false, 
          error: "权限不足" 
        }, status: 403
        return
      end
      
      @entry.destroy!
      render json: { 
        success: true, 
        message: "删除成功" 
      }
    rescue => e
      Rails.logger.error "CustomFormEntriesController#destroy error: #{e.message}"
      render json: { 
        success: false, 
        error: e.message 
      }, status: 500
    end
  end

  private

  def find_entry
    @entry = CustomFormEntry.find(params[:id])
  end

  def entry_params
    params.require(:custom_form_entry).permit(:title, :event_date, :image_upload_id, :description)
  end

  def can_delete?
    return true if current_user.staff?
    return true if @entry.user_id == current_user.id
    false
  end

  def serialize_entry(entry)
    {
      id: entry.id,
      title: entry.title,
      event_date: entry.event_date,
      description: entry.description,
      image_url: entry.image_upload&.url,
      created_at: entry.created_at,
      user: {
        id: entry.user.id,
        username: entry.user.username,
        avatar_template: entry.user.avatar_template
      }
    }
  end
end
