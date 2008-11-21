module Merb
  module ActivitiesHelper
    # TODO: use css instead of &nbsp; in activities_calendar, edit_activity and delete_activity
    
    def activities_calendar(options = {})
      # no need to check for :year and :month - calendar_table does it
      activities = options[:activities] or raise ArgumentError.new("options[:activities] is a mandatory argument")
      user = options[:user]             or raise ArgumentError.new("options[:user] is a mandatory argument")
      year = options[:year]
      month = options[:month]
      
      calendar_table(:year => year, :month => month, :first_day_of_week => 1) do |date|
        activities_for_today =  !activities[date].nil?
        html =  %(<div class="day_of_the_month clearfix">)
        criteria =  { :date_from => date, :date_to => date, :user_id => [user.id]}
        html << link_to("Show activity for the day", CGI.escapeHTML(url(:activities_for_day, :search_criteria => criteria) + "#activities_for_day"), 
          :class => "show_day", :style => activities_for_today ? "" : "display: none")
        html << %(#{date.mday}</div><ul class="activities">)
        html << partial(:activity, :with => activities[date]) if activities_for_today
        html << %(<li class="add_activity"><a href="#"class="add_activity" id="#{format_date date}">Add activity</a></li>)
        html << "</ul>"
      end 
    end
    
    def delete_activity(activity)
      if activity.deletable_by?(current_user) && !activity.locked?
        link_to "<img src=\"/images/icons/cross_small.png\" alt=\"Delete activity\" />", resource(activity), :class => "delete_activity" 
      end
    end
      
    def edit_activity(activity)
      if activity.deletable_by?(current_user) && !activity.locked?
        link_to "<img src=\"/images/icons/pencil_small.png\" alt=\"Edit activity\" />", resource(activity, :edit)+"?height=350&width=500", :class => "edit_activity_link"
      end
    end
      
    def format_hours(activity)
      "#{activity.minutes / 60}:#{activity.minutes % 60}"
    end
    
    private
      
    # based on rails calendar_helper plugin by topfunky
    # homepage: http://nubyonrails.com
    # plugin: http://topfunky.net/svn/plugins/calendar_helper  
    def calendar_table(options = {}, &block)
      raise(ArgumentError, "No year given")  unless options.has_key?(:year)
      raise(ArgumentError, "No month given") unless options.has_key?(:month)
    
      block ||= Proc.new { |d| nil }
    
      defaults = {
        :table_id => "calendar", 
        :table_class => 'calendar',
        :month_name_class => 'month_name',
        :other_month_class => 'other_month',
        :day_name_class => 'day_name',
        :day_class => 'day',
        :abbrev => (0..2),
        :first_day_of_week => 0
      }
      options = defaults.merge options
    
      first = Date.civil(options[:year], options[:month], 1)
      last = Date.civil(options[:year], options[:month], -1)
    
      first_weekday = first_day_of_week(options[:first_day_of_week])
      last_weekday = last_day_of_week(options[:first_day_of_week])
    
      day_names = Date::DAYNAMES.dup
      first_weekday.times do
        day_names.push(day_names.shift)
      end
    
      cal = %(<table id="#{options[:table_id]}" class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">) 
      cal << %(<thead><tr class="#{options[:month_name_class]}"><th colspan="7">)
      cal << link_to("&laquo; Previous", url(:user_calendar, @user.id, :month => @previous_month, :year => @previous_year), :id => "previous_month")
      cal << %(<span class="date">#{Date::MONTHNAMES[options[:month]]} #{options[:year]}</span>)
      unless @next_month.nil? && @next_year.nil?
        cal << link_to("Next &raquo;", url(:user_calendar, @user.id, :month => @next_month, :year => @next_year), :id => "next_month")
      end
      cal << %(</th></tr><tr class="#{options[:day_name_class]}">)
      day_names.each {|d| cal << "<th>#{d[options[:abbrev]]}</th>"}
      cal << "</tr></thead><tbody><tr>"
      beginning_of_week(first, first_weekday).upto(first - 1) do |d|
        cal << %(<td class="#{options[:other_month_class]})
        cal << " weekendDay" if weekend?(d)
        cal << %(">#{d.day}</td>)
      end unless first.wday == first_weekday
      first.upto(last) do |cur|
        cell_text, cell_attrs = block.call(cur)
        cell_text  ||= cur.mday
        cell_attrs ||= {:class => options[:day_class]}
        cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday) 
        cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
        cal << "<td #{cell_attrs}>#{cell_text}</td>"
        cal << "</tr><tr>" if cur.wday == last_weekday
      end
      (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
        cal << %(<td class="#{options[:other_month_class]})
        cal << " weekendDay" if weekend?(d)
        cal << %(">#{d.day}</td>)
      end unless last.wday == last_weekday
      cal << "</tr></tbody></table>"
    end
      
    def first_day_of_week(day)
      day
    end
      
    def last_day_of_week(day)
      if day > 0
        day - 1
      else
        6
      end
    end
      
    def days_between(first, second)
      if first > second
        second + (7 - first)
      else
        second - first
      end
    end
      
    def beginning_of_week(date, start = 1)
      days_to_beg = days_between(start, date.wday)
      date - days_to_beg
    end
      
    def weekend?(date)
      [0, 6].include?(date.wday)
    end    
  end # ActivitiesHelper
end # Merb