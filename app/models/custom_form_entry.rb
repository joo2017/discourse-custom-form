# frozen_string_literal: true

class CustomFormEntry < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :image_upload, class_name: 'Upload', foreign_key: 'image_upload_id', optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :event_date, presence: true
  validates :user_id, presence: true
  validates :post_id, presence: true

  scope :by_date, -> { order(:event_date) }
  scope :upcoming, -> { where('event_date >= ?', Date.current) }
  scope :past, -> { where('event_date < ?', Date.current) }
  
  def past?
    event_date < Date.current
  end
  
  def upcoming?
    event_date >= Date.current
  end
end

# 扩展 Post 模型
Post.class_eval do
  has_many :custom_form_entries, dependent: :destroy
end
