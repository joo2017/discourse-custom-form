# frozen_string_literal: true

class CustomFormEntrySerializer < ApplicationSerializer
  attributes :id, :title, :event_date, :description, :created_at, :updated_at
  
  has_one :user, serializer: BasicUserSerializer
  has_one :post, serializer: BasicPostSerializer
  
  def include_image_url?
    object.image_upload_id.present?
  end
  
  def image_url
    object.image_upload&.url
  end
  
  def include_image_upload_id?
    object.image_upload_id.present?
  end
end
