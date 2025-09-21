# frozen_string_literal: true

class CustomFormProcessor
  # 修正后的正则表达式
  CUSTOM_FORM_REGEX = /\[wrap=custom-form(?:\s+title="([^"]*)")?(?:\s+date="([^"]*)")?(?:\s+description="([^"]*)")?(?:\s+image="([^"]*)")?\]\[\/wrap\]/

  def self.update(post)
    Rails.logger.info "CustomFormProcessor.update called for post #{post.id}"
    Rails.logger.info "Post raw content: #{post.raw}"
    
    return unless post.raw.include?('[wrap=custom-form')

    # 解析帖子内容中的自定义表单标记
    matches = post.raw.scan(CUSTOM_FORM_REGEX)
    Rails.logger.info "Found matches: #{matches.inspect}"
    
    if matches.any?
      # 取第一个匹配的表单数据
      title, date, description, image_id = matches.first
      Rails.logger.info "Parsed data - title: #{title}, date: #{date}, description: #{description}, image_id: #{image_id}"
      
      # 保存到自定义字段
      post.custom_fields["custom_form_title"] = title if title.present?
      post.custom_fields["custom_form_date"] = date if date.present?
      post.custom_fields["custom_form_description"] = description if description.present?
      post.custom_fields["custom_form_image_upload_id"] = image_id.to_i if image_id.present?
      
      result = post.save_custom_fields
      Rails.logger.info "CustomFormProcessor: Save result: #{result}, Custom fields: #{post.custom_fields.inspect}"
    else
      Rails.logger.info "No matches found in post content"
    end
  end
end
