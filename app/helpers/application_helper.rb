module Merb
  module ApplicationHelper
    def format_time(time)
      time.strftime Rubytime::CONFIG[:time_format]
    end
    
    def main_menu_items_for(user, controller_name)
      return [] unless user
      main_menu = []
      
      selected = ['activities'].include?(controller_name)
      main_menu << { :title => "Activities", :path => resource(:activities), :selected => selected }
      
      if user.is_admin? || user.instance_of?(ClientUser)
        selected = ['invoices'].include?(controller_name)
        main_menu << { :title => "Invoices", :path => resource(:invoices), :selected => selected }
      end
      
      if user.is_admin?
        selected = ['users', 'roles', 'projects', 'clients'].include?(controller_name)
        main_menu << { :title => "Manage", :path => resource(:users), :selected => selected }
      end
      
      main_menu
    end
    
    def sub_menu_items_for(controller_name)
      sub_menu = []
      case controller_name
      when 'users', 'roles', 'projects', 'clients'
        sub_menu << { :title => "Users", :path => resource(:users), :selected => controller_name == 'users' }
        sub_menu << { :title => "Clients", :path => resource(:clients), :selected => controller_name == 'clients' }
        sub_menu << { :title => "Projects", :path => resource(:projects), :selected => controller_name == 'projects' }
        sub_menu << { :title => "Roles", :path => resource(:roles), :selected => controller_name == 'roles' }
      when 'invoices'
        sub_menu << { :title => "Issued", :path => resource(:invoices), :selected => true }
        sub_menu << { :title => "Not issued", :path => resource(:invoices) }
      end
      sub_menu
    end
  end
end # Merb