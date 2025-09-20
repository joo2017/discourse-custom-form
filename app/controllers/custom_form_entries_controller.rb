# frozen_string_literal: true

class CustomFormEntriesController < ApplicationController
  before_action :ensure_logged_in
  before_action :find_post, except: [:index]
  before_action :find_entry, only: [:show, :destroy]

  def index
    entries = CustomFormEntry.includes(:user, :post, :image_upload)
                             .by_date
                             .limit(50)
    
    render json: {
      entries: entries.map { |entry| CustomFormEntrySerializer.new(entry, root: false) }
    }
  end

  def create
    entry = @post.custom_form_entries.build(entry_params.merge(user: current_user))
    
    if entry.save
      # 在帖子中插入表单内容
      update_post_content(entry)
      
      render json: CustomFormEntrySerializer.new(entry, root: false)
    else
      render json: { errors: entry.errors.full_messages }, status: 422
    end
  end

  def show
    render json: CustomFormEntrySerializer.new(@entry, root: false)
  end

  def destroy
    raise Discourse::InvalidAccess unless can_delete?
    
    @entry.destroy!
    render json: { success: true }
  end

  private

  def find_post
    @post = Post.find(params[:post_id]) if params[:post_id]
  end

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

  def update_post_content(entry)
    content = "\n\n---\n**#{entry.title}**\n"
    content += "**日期:** #{entry.event_date.strftime('%Y-%m-%d')}\n"
    
    if entry.image_upload
      content += "![#{entry.title}](#{entry.image_upload.url})\n"
    end
    
    if entry.description.present?
      content += "\n#{entry.description}\n"
    end
    
    content += "---\n"
    
    revisor = PostRevisor.new(@post)
    revisor.revise!(
      current_user,
      raw: @post.raw + content,
      edit_reason: I18n.t('custom_form.edit_reason')
    )
  end
end
