module Merb
  module ApplicationHelper
    def format_time(time)
      time.strftime Rubytime::CONFIG[:time_format]
    end
    
    def format_date(date)
      date.strftime Rubytime::CONFIG[:date_format]
    end

    def format_minutes(minutes)
      return "0" unless minutes
      format("%d:%.2d", minutes / 60, minutes % 60)
    end
  
    def main_menu_items 
      return [] unless current_user
      main_menu = []
      
      selected = ['activities'].include?(controller_name)
      main_menu << { :title => "Activities", :path => resource(:activities), :selected => selected }
      
      if current_user.is_client_user?
        selected = (controller_name == 'projects' && action_name == 'index' )
        main_menu << { :title => "Projects", :path => resource(:projects), :selected => selected }
      end

      if current_user.is_admin? || current_user.is_client_user?
        selected = ['invoices'].include?(controller_name)
        main_menu << { :title => "Invoices", :path => resource(:invoices), :selected => selected }
      end
      
      if current_user.is_admin?
        selected = ['users', 'roles', 'projects', 'clients'].include?(controller_name)
        main_menu << { :title => "Manage", :path => resource(:users), :selected => selected }
      end
      
      main_menu
    end
    
    def sub_menu_items
      sub_menu = []
      case controller_name
      when 'users', 'roles', 'projects', 'clients'
        if current_user.is_admin?
          sub_menu << { :title => "Users", :path => url(:users), :selected => controller_name == 'users' }
          sub_menu << { :title => "Clients", :path => url(:clients), :selected => controller_name == 'clients' }
          sub_menu << { :title => "Projects", :path => url(:projects), :selected => controller_name == 'projects' }
          sub_menu << { :title => "Roles", :path => url(:roles), :selected => controller_name == 'roles' }
        end
      when 'invoices'
        sub_menu << { :title => "All", :path => url(:invoices), :selected => params[:filter].nil? }
        sub_menu << { :title => "Issued", :path => url(:issued_invoices), :selected => params[:filter] == 'issued' }
        sub_menu << { :title => "Pending", :path => url(:pending_invoices), :selected => params[:filter] == 'pending' }
      when 'activities'
        if current_user.is_employee?
          sub_menu << { :title => "List", :path => resource(:activities), 
                        :selected => action_name == 'index' }
          sub_menu << { :title => "Calendar", :path => url(:user_calendar, current_user.id), 
                        :selected => action_name == 'calendar' }
        end
      end
      sub_menu
    end
    
    def unique_clients_from(activities)
      activities.map { |a| a.project.client }.uniq.sort_by { |c| c.name }
    end
    
    def unique_projects_from(activities, client)
      activities.select { |a| a.project.client == client }.map { |a| a.project }.uniq.sort_by { |p| p.name }
    end
    
    def unique_roles_from(activities, client, project)
      activities.select { |a| a.project.client == client && a.project == project }.map { |a| a.user.role }.uniq.sort_by { |r| r.name }
    end
    
    def activities_from(activities, client, project=nil, role=nil)
      activities = activities.select { |a| a.project.client == client }
      if project
        activities = activities.select { |a| a.project == project }
        activities = activities.select { |a| a.user.role == role  } if role
      end
      activities.sort_by { |a| a.date }
    end
    
    def total_from(activities)
      activities.inject(0) { |a,act| a + act.minutes }
    end
    
    def activities_table(activities, options={})
      default_options = { :show_checkboxes => false, :show_users => true, :show_details_link => true, :show_edit_link => true,
                          :show_delete_link => true, :show_exclude_from_invoice_link => false, :expanded => false }
      options = default_options.merge(options)

      html = %(<table class="activities list wide" cellspacing="0" cellpadding="0">)
      html << %(<tr>)
      html << %(<th class="checkbox">#{check_box :class => "activity_select_all"}</th>) if options[:show_checkboxes]
      html << %(<th>User</th>) if options[:show_users]
      html << %(<th>Date</th>)
      html << %(<th class="right">Hours</th>)
      html << %(<th class="icons">)
      html << link_to(image_tag("icons/magnifier.png", :title => "Toggle all details"), "#", :class => "toggle_all_comments_link") if options[:show_details_link]
      html << %(</th>)
      html << %(</tr>)
      activities.each do |activity|
        html << activities_table_row(activity, options)
      end
      html << %(</table>)
      html
    end

    def activities_table_row(activity, options)
      row = %(<tr>)
      if options[:show_checkboxes]
        row << %(<td class="checkbox">#{check_box(:name => "activity_id[]", :value => activity.id) unless activity.invoiced?}</td>)
      end
      row << %(<td>#{h(activity.user.name)}</td>) if options[:show_users]
      row << %(<td>#{activity.date}</td>)
      row << %(<td class="right">#{activity.hours}</td><td>)
      row << link_to(image_tag("icons/magnifier.png", :title => "Toggle details"), "#", :class => "toggle_comments_link") if options[:show_details_link]
      row << link_to(image_tag("icons/pencil.png", :title => "Edit"), resource(activity, :edit)+"?height=350&width=500", :class => "edit_activity_link", :title => "Editing activity") if options[:show_edit_link] && activity.deletable_by?(current_user) && !activity.locked?
      row << link_to(image_tag("icons/cross.png", :title => "Remove"), resource(activity), :class => "remove_activity_link") if options[:show_delete_link] && activity.deletable_by?(current_user) && !activity.locked?
      row << link_to(image_tag("icons/notebook_minus.png", :title => "Remove activity from this invoice"), resource(activity), :class => "remove_from_invoice_link") if options[:show_exclude_from_invoice_link] && !activity.locked?
      visibility = options[:expanded] ? "" : "display: none"
      row << %(</td></tr><tr class="comments" style="#{visibility}"><td colspan="5">#{h(activity.comments.gsub(/\n/, "<br/>"))}</td></tr>)
      row
    end

    def full_activities_table(activities)
      activities_table(activities, :show_checkboxes => current_user.is_admin?,
                                         :show_users => current_user.is_admin? || !current_user.is_employee?,
                                         :show_details_link => true, :show_edit_link => true,
                                         :show_delete_link => true, :show_exclude_from_invoice_link => false)
    end

    def invoice_activities_table(activities)
      activities_table(activities, :show_checkboxes => false, :show_users => true, :show_details_link => true,
                                   :show_edit_link => false, :show_delete_link => false, 
                                   :show_exclude_from_invoice_link => current_user.is_admin?)
    end

    def calendar_activities_table(activities)
      activities_table(activities, :show_checkboxes => false, :show_users => current_user.is_admin? || !current_user.is_employee?,
                                   :show_details_link => false, :show_edit_link => false, :show_delete_link => false,
                                   :expanded => true)
    end
  end
end # Merb