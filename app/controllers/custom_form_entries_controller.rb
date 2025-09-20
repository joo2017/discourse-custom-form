# frozen_string_literal: true

class CustomFormEntriesController < ApplicationController
  before_action :ensure_logged_in
  before_action :find_entry, only: [:show, :destroy]

  def index
    entries = CustomFormEntry.includes(:user, :post, :image_upload)
                             .by_date
                             .limit(50)
    
    render json: {
      entries: entries.map { |entry| serialize_entry(entry) }
    }
  end

  def create
    # 从参数中提取 post_id
    post_id = params[:post_id]
    post = nil
    
    if post_id.present?
      post = Post.find_by(id: post_id)
    end
    
    entry_params_hash = entry_params
    entry = CustomFormEntry.new(entry_params_hash.merge(user: current_user))
    entry.post = post if post
    
    if entry.save
      render json: serialize_entry(entry)
    else
      render json: { 
        errors: entry.errors.full_messages,
        success: false 
      }, status: 422
    end
  end

  def show
    render json: serialize_entry(@entry)
  end

  def destroy
    raise Discourse::InvalidAccess unless can_delete?
    
    @entry.destroy!
    render json: { success: true }
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
