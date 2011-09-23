# -*- coding: utf-8 -*-
module ProjectsHelper

  def activity_type_check_box(activity_type, checked = false, disabled = false)
    attrs = { :type => "checkbox", :name => "project[activity_type_ids][]", :value => activity_type.id }
    attrs[:checked] = 'checked' if checked
    attrs[:disabled] = 'disabled' if disabled
    tag(:input, attrs) + activity_type.name
  end
  
  def activity_type_select(project)
    list = project.available_activity_types.map do |main_type|
      data = [[main_type[:id], main_type[:name]]]
      data += main_type[:available_subactivity_types].map { |st| [st[:id], "– " + st[:name]] }
      data
    end
    
    select_tag 'activity_type_id', select_options(list.inject(&:+), :first, :last)
  end

end
