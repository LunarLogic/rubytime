module Merb
  module ProjectsHelper

    def activity_type_check_box(activity_type, checked = false)
      attrs = { :type => "checkbox", :name => "project[activity_type_ids][]", :value => activity_type.id }
      attrs[:checked] = 'checked' if checked
      tag(:input, nil, attrs) + activity_type.name
    end

  end
end # Merb