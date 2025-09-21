export function setup(helper) {
  if (!helper.markdownIt) {
    return;
  }

  helper.registerPlugin(md => {
    const rule = {
      tag: 'custom-form',
      before(state, tagInfo) {
        const token = state.push('custom_form_open', 'div', 1);
        token.attrSet('class', 'custom-form-container');
        token.attrSet('data-title', tagInfo.attrs['title'] || '');
        token.attrSet('data-date', tagInfo.attrs['date'] || '');
        token.attrSet('data-description', tagInfo.attrs['description'] || '');
        token.attrSet('data-image', tagInfo.attrs['image'] || '');
      },
      after(state) {
        state.push('custom_form_close', 'div', -1);
      }
    };

    md.block.bbcode.ruler.push('custom-form', rule);
  });

  helper.addPreview('custom-form', attrs => {
    const title = attrs['title'] || '';
    const date = attrs['date'] || '';
    const description = attrs['description'] || '';
    
    let preview = `<div class="custom-form-preview">`;
    preview += `<h3>${title}</h3>`;
    if (date) {
      preview += `<p><strong>日期:</strong> ${date}</p>`;
    }
    if (description) {
      preview += `<p><strong>描述:</strong> ${description}</p>`;
    }
    preview += `</div>`;
    
    return preview;
  });
}
