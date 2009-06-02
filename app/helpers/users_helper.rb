module Merb
  module UsersHelper
    def link_to_calendar(user)
      link_to image_tag("icons/calendar.png", :title => "Calendar", :alt => 'C'), url(:user_calendar, user) if user.is_employee?
    end

    def recent_days_on_list_desc(v)
      "#{v} days"
  end

    def date_format_desc(v)
      "#{v.capitalize} (#{Rubytime::DATE_FORMATS[v.to_sym][:description]})"
    end

    def radio_options(user, property, symbols)
      radio_group(property, symbols.map { |s|
        { :value => s.to_s, :label => yield(s.to_s), :checked => user.attribute_get(property) == s }})
    end
  end
end # Merb