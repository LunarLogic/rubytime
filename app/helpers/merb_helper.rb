# -*- coding: utf-8 -*-
module MerbHelper
  # Methods for view compatibility with merb

  def partial(partial, locals = {})
    if locals[:with] && locals[:as]
      locals[locals.delete(:as)] = locals.delete(:with)
    end
    render :partial => partial.to_s, :locals => locals
  end

  def submit(name, options)
    submit_tag(name, options)
  end

  def throw_content(name, content)
    content_for(name, content)
  end

  def label(name, text)
    if text.is_a?(Hash)
      super(text[:for], name)
    else
      super(name, text)
    end
  end

end
