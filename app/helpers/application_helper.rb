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
  
    #TODO remove user argument since current_user is available
    def main_menu_items 
      return [] unless current_user
      main_menu = []
      
      selected = ['activities'].include?(controller_name)
      main_menu << { :title => "Activities", :path => resource(:activities), :selected => selected }
      
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
  end
end # Merb