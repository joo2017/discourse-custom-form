# frozen_string_literal: true

class CustomFormProcessor
  CUSTOM_FORM_REGEX = /\[custom-form\s+title="([^"]*)"(?:\s+date="([^"]*)")?(?:\s+description="([^"]*)")?(?:\s+image="([^"]*)")?\]\[\/custom-form\]/

  def self.update(post)
    return unless post.raw.include?('[custom-form')

    # 解析帖子内容中的自定义表单标记
    matches = post.raw.scan(CUSTOM_FORM_REGEX)
    
    if matches.any?
      # 取第一个匹配的表单数据
      title, date, description, image_id = matches.first
      
      # 保存到自定义字段
      post.custom_fields["custom_form_title"] = title if title.present?
      post.custom_fields["custom_form_date"] = date if date.present?
      post.custom_fields["custom_form_description"] = description if description.present?
      post.custom_fields["custom_form_image_upload_id"] = image_id.to_i if image_id.present?
      
      post.save_custom_fields
      
      Rails.logger.info "CustomFormProcessor: Saved custom form data for post #{post.id}"
    end
  end
end
