# -*- coding: utf-8 -*-
module MerbHelper
  # Methods for view compatibility with merb

  def partial(partial, locals = {})
    if locals[:with] && locals[:as]
      locals[locals.delete(:as)] = locals.delete(:with)
    elsif locals[:with]
      locals[partial.to_sym] = locals.delete(:with)
    end
    render :partial => partial.to_s, :locals => locals
  end

end
