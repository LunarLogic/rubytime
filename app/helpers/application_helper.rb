module Merb
  module ApplicationHelper
    def format_minutes(minutes)
      return "0" unless minutes
      format("%d:%.2d", minutes / 60, minutes % 60)
    end
  
    def main_menu_items 
      return [] unless current_user
      main_menu = []
      
      selected = controller_name == 'activities'
      main_menu << { :title => "Activities", :path => resource(:activities), :selected => selected }
      
      if current_user.is_client_user?
        selected = (controller_name == 'projects' && action_name == 'index' )
        main_menu << { :title => "Projects", :path => resource(:projects), :selected => selected }
      end

      if current_user.is_admin? || current_user.is_client_user?
        selected = controller_name == 'invoices'
        main_menu << { :title => "Invoices", :path => resource(:invoices), :selected => selected }
      end
      
      if current_user.is_admin?
        selected = ['users', 'roles', 'projects', 'clients', 'activity_types', 'activity_custom_properties'].include?(controller_name)
        main_menu << { :title => "Manage", :path => resource(:users), :selected => selected }
      end
      
      main_menu
    end
    
    def sub_menu_items
      sub_menu = []
      case controller_name
      when 'users', 'roles', 'projects', 'clients', 'activity_types', 'activity_custom_properties'
        if current_user.is_admin?
          sub_menu << { :title => "Users", :path => url(:users), :selected => controller_name == 'users' }
          sub_menu << { :title => "Clients", :path => url(:clients), :selected => controller_name == 'clients' }
          sub_menu << { :title => "Projects", :path => url(:projects), :selected => controller_name == 'projects' }
          sub_menu << { :title => "Roles", :path => url(:roles), :selected => controller_name == 'roles' }
          sub_menu << { :title => "Activity types", :path => url(:activity_types), :selected => controller_name == 'activity_types' }
          sub_menu << { :title => "Custom activity properties", :path => url(:activity_custom_properties), :selected => controller_name == 'activity_custom_properties' }
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
      format_minutes(activities.inject(0) { |a,act| a + act.minutes })
    end
    
    def total_custom_properties(activities, client, project=nil, role=nil)
      html = ""
      ActivityCustomProperty.all.each do |activity_custom_property|
        html << %(<p>)
        html << %(Total #{activity_custom_property.name}: )
        html << %(#{Activity.custom_property_values_sum(activities_from(@activities, client), activity_custom_property)})
        html << %( #{activity_custom_property.unit})
        html << %(</p>)
      end
      html
    end
    
    def activities_table(activities, options={})
      default_options = { :show_checkboxes => false, :show_users => true,
                          :show_details_link => true, :show_edit_link => true,
                          :show_delete_link => true, :show_exclude_from_invoice_link => false,
                          :expanded => false, :show_date => true,
                          :custom_properties_to_show_in_columns => ActivityCustomProperty.all(:show_as_column_in_tables => true),
                          :custom_properties_to_show_in_expanded_view => ActivityCustomProperty.all(:show_as_column_in_tables => false) }

      options = default_options.merge(options)

      table_opts = { :class => 'activities list wide', :id => "#{options[:table_id]}"}
      table_opts.reject!{|k,v| v.blank?}

      tag(:table, table_opts) do
        html =  %(<tr>)
        html << %(<th class="checkbox">#{check_box :class => "activity_select_all"}</th>) if options[:show_checkboxes]
        html << %(<th>#{image_tag("icons/project.png", :alt => 'project') if options[:show_header_icons]} Project</th>) if options[:show_project]
        html << %(<th>#{image_tag("icons/role.png", :alt => 'role') if options[:show_header_icons]} User</th>) if options[:show_users]
        html << %(<th>Date</th>) if options[:show_date]
        html << %(<th class="right">#{image_tag("icons/clock.png", :alt => 'clock') if options[:show_header_icons]} Hours</th>)
        
        options[:custom_properties_to_show_in_columns].each do |custom_property|
          html << %(<th class="right">#{custom_property.name}#{' (' + custom_property.unit + ')' if custom_property.unit}</th>)
        end
        
        html << %(<th class="icons">)
        html << link_to(image_tag("icons/magnifier.png", :title => "Toggle all details", :alt => 'I'), "#", :class => "toggle_all_comments_link") if options[:show_details_link]
        html << %(</th>)
        html << %(</tr>)
        activities.each do |activity|
          html << activities_table_row(activity, options)
        end
        html << %(<tr class="no_zebra">)
        html << %(<td></td>) if options[:show_checkboxes]
        html << %(<td></td>) if options[:show_project]
        html << %(<td></td>) if options[:show_users]
        html << %(<td class="right"><strong>Total:</strong></td>)
        html << %(<td class="right"><strong>#{total_from(activities)}</strong></td>)
        options[:custom_properties_to_show_in_columns].each do |custom_property|
          html << %(<td class="right"><strong>#{Activity.custom_property_values_sum(activities, custom_property)}</strong></td>)
        end
        html << %(<td></td>)
        html << %(</tr>)
      end
    end

    def activities_table_row(activity, options)
      row = %(<tr>)
      if options[:show_checkboxes]
        row << %(<td class="checkbox">#{check_box(:name => "activity_id[]", :value => activity.id, :id => "activity_id_#{activity.id}") unless activity.invoiced?}</td>)
      end
      row << %(<td>#{h(activity.project.name)}</td>) if options[:show_project]
      row << %(<td>#{h(activity.user.name)}</td>) if options[:show_users]
      row << %(<td>#{activity.date.formatted(current_user.date_format)}</td>) if options[:show_date]
      row << %(<td class="right">#{activity.hours}</td>)
      
      options[:custom_properties_to_show_in_columns].each do |custom_property|
        row << %(<td class="right">#{activity.custom_properties[custom_property.id]}</td>)
      end

      # icons
      row << %(<td class="icons">)
      row << link_to(image_tag("icons/magnifier.png", :alt => "I", :title => "Toggle details"), "#", :class => "toggle_comments_link") if options[:show_details_link]
      row << link_to(image_tag("icons/pencil.png", :alt => "E", :title => "Edit"), resource(activity, :edit)+"?height=350&amp;width=500", :class => "edit_activity_link", :title => "Editing activity") if options[:show_edit_link] && activity.deletable_by?(current_user) && !activity.locked?
      row << link_to(image_tag("icons/cross.png", :alt => "R", :title => "Remove"), resource(activity), :class => "remove_activity_link") if options[:show_delete_link] && activity.deletable_by?(current_user) && !activity.locked?
      row << link_to(image_tag("icons/notebook_minus.png", :alt => "-", :title => "Remove activity from this invoice"), resource(activity), :class => "remove_from_invoice_link") if options[:show_exclude_from_invoice_link] && !activity.locked?
      row << %(</td>)

      klass, visibility = (options[:expanded] ? ["", ""] : ["no_zebra", "display: none"])
      row << %(</tr><tr class="comments #{klass}" style="#{visibility}"><td colspan="#{options[:custom_properties_to_show_in_columns].size + 5}">)
      row << %(<p><strong>#{h(activity.breadcrumb_name)}</strong></p>) if activity.breadcrumb_name
      options[:custom_properties_to_show_in_expanded_view].each do |custom_property|
        if activity.custom_properties[custom_property.id]
          row << %(<p><strong>#{custom_property.name}</strong>: #{activity.custom_properties[custom_property.id]} #{custom_property.unit}</p>)
        end
      end
      row << %(<p>#{h(activity.comments).gsub(/\n/, "<br/>")}</p></td></tr>)
      row
    end

    def full_activities_table(activities)
      activities_table(activities, :show_checkboxes => current_user.is_admin?,
                                         :show_users => current_user.is_admin? || !current_user.is_employee?,
                                         :show_details_link => true, :show_edit_link => true,
                                         :show_delete_link => true, :show_exclude_from_invoice_link => false)
    end

    def invoice_activities_table(activities, options={})
      activities_table(activities, { :show_checkboxes => false, :show_users => true, :show_details_link => true,
                                     :show_edit_link => false, :show_delete_link => false,
                                     :show_exclude_from_invoice_link => current_user.is_admin? }.merge!(options))
    end

    def calendar_activities_table(activities, options={})
      activities_table(activities, { :show_checkboxes => false, :show_users => current_user.is_admin? || !current_user.is_employee?,
                                     :show_details_link => false, :show_edit_link => true, :show_delete_link => false,
                                     :show_project => true, :expanded => true, :show_date => false }.merge!(options))
    end
  end
end # Merb