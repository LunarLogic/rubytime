module UsersHelper
  def link_to_calendar(user)
    link_to image_tag("icons/calendar.png", :title => "Calendar", :alt => 'C'), user_calendar_path(user) if user.is_employee?
  end

  def recent_days_on_list_desc(v)
    "#{v} days"
  end

  def date_format_desc(v)
    "#{v.capitalize} (#{Rubytime::DATE_FORMATS[v.to_sym][:description]})"
  end

  def radio_options(user, property, symbols)
    symbols.map do |symbol|
      radio_button_tag("user[#{property}]", symbol, user.attribute_get(property) == symbol) +
        label_tag("#{property}_#{symbol}", yield(symbol.to_s))
    end.join.html_safe
  end
end
