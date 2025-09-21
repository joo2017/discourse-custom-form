export function setup(helper) {
  if (!helper.markdownIt) {
    return;
  }

  helper.registerPlugin(md => {
    const rule = {
      tag: 'custom-form',
      
      replace: function(state, tagInfo, content) {
        const title = tagInfo.attrs.title || '';
        const date = tagInfo.attrs.date || '';
        const description = tagInfo.attrs.description || '';
        const imageId = tagInfo.attrs.image || '';
        
        let htmlContent = '<div class="custom-form-container">';
        
        if (title) {
          htmlContent += `<div class="custom-form-title">${title}</div>`;
        }
        
        if (date) {
          htmlContent += `<div class="custom-form-date"><span class="custom-form-label">日期:</span> ${date}</div>`;
        }
        
        if (description) {
          htmlContent += `<div class="custom-form-description"><span class="custom-form-label">描述:</span> ${description}</div>`;
        }
        
        if (imageId) {
          htmlContent += `<div class="custom-form-image"><span class="custom-form-label">图片 ID:</span> ${imageId}</div>`;
        }
        
        htmlContent += '</div>';
        
        const token = state.push('html_block', '', 0);
        token.content = htmlContent;
        token.map = tagInfo.map;
        
        return true;
      }
    };

    md.block.bbcode.ruler.push('custom-form', rule);
  });
}
