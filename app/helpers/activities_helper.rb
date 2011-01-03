module Merb
  module ActivitiesHelper
    # TODO: use css instead of &nbsp; in activities_calendar, edit_activity and delete_activity
    
    def activities_calendar(options = {})
      # no need to check for :year and :month - calendar_table does it
      activities = options[:activities] or raise ArgumentError.new("options[:activities] is a mandatory argument")
      year = options[:year]
      month = options[:month]
      owner = options[:owner] or raise ArgumentError.new("options[:owner] is a mandatory argument")
      owner_type = owner.is_a?(Project) ? "project" : "user"
      owner_id_name = :"#{owner_type}_id"

      calendar_table(:year => year, :month => month, :first_day_of_week => 1, :owner_type => owner_type) do |date|
        vacation_for_today = owner.respond_to?(:has_free_day_on) ? owner.has_free_day_on(date) : false
        activities_for_today =  !activities[date].nil?
        html =  %(<div class="day_wrapper"><div class="day_of_the_month clearfix">)
        criteria =  { :date_from => date, :date_to => date, owner_id_name => [owner.id]}
        html << %(#{date.mday}</div>)

        if activities_for_today
          shown_activities = activities[date][0..2]
          rest_of_activities = activities[date] - shown_activities
          html << '<ul class="activities">'
          html << partial(:activity, :with => shown_activities)
            if rest_of_activities.size > 0
              html << %(<li class="more">#{link_to("#{rest_of_activities.size} more ...", day_url(criteria))}</li>)
            end
          html << '</ul>'
        elsif vacation_for_today
          html << %(<p class="vacation">VACATION</p>)
        end

        html << %(<span class="total_hours">Total: <strong>#{total_from(activities[date])}</strong></span>) if activities_for_today
        html << %(<span class="activity_icons">)
        if activities_for_today
          html << link_to(image_tag("/images/icons/magnifier.png", :title => "Show details", :alt => "Details"), day_url(criteria),
            :class => "show_day")
        elsif !vacation_for_today
          html << link_to(image_tag("/images/icons/working_day.png", :title => "Mark as day off", :alt => "Mark as day off"), '#',
            :class => "day_off", :id => "vacation-#{date}")
        elsif vacation_for_today
          html << link_to(image_tag("/images/icons/calendar-day-off.png", :title => "Mark as working day", :alt => 'Mark as working day'), '#',
            :class => "working_day", :id => "vacation-#{date}")
        end
        if owner_type == "user" && current_user.can_add_activity? && owner.active?
          html << link_to(image_tag("/images/icons/plus.png", :title => "Add activity for this day", :alt => 'Add activity for this day'), '#',
            :class => "add_activity", :id => "add-#{date}")
        end
        html << %(</span></div>)
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
            
      prev_url = CGI.escapeHTML(url(:"#{options[:owner_type]}_calendar", @owner.id, :month => @previous_month, :year => @previous_year))
      next_url = CGI.escapeHTML(url(:"#{options[:owner_type]}_calendar", @owner.id, :month => @next_month, :year => @next_year))
      
      cal = %(<table id="#{options[:table_id]}" class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">) 
      cal << %(<thead><tr class="#{options[:month_name_class]}"><th colspan="7">)
      cal << link_to("&laquo; Previous", prev_url, :id => "previous_month")
      cal << %(<span class="date" data-current-year="#{options[:year]}" data-current-month="#{options[:month]}">#{Date::MONTHNAMES[options[:month]]} #{options[:year]}</span>)
      unless @next_month.nil? && @next_year.nil?
        cal << link_to("Next &raquo;", next_url, :id => "next_month")
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

    def day_url(criteria)
      CGI.escapeHTML(resource(:activities, :day, :search_criteria => criteria)+"&width=600&height=500")
    end

    def prev_day_url
      criteria = Mash.new(params[:search_criteria])
      criteria[:date_from] = criteria[:date_to] = (Date.parse(criteria[:date_from]) - 1).to_s
      day_url(criteria)
    end

    def next_day_url
      criteria = Mash.new(params[:search_criteria])
      criteria[:date_from] = criteria[:date_to] = (Date.parse(criteria[:date_from]) + 1).to_s
      day_url(criteria)
    end

  end # ActivitiesHelper
end # Merb