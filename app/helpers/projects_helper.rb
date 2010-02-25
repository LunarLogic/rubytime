module Merb
  module ProjectsHelper

    def activity_type_check_box(activity_type, checked = false, disabled = false)
      attrs = { :type => "checkbox", :name => "project[activity_type_ids][]", :value => activity_type.id }
      attrs[:checked] = 'checked' if checked
      attrs[:disabled] = 'disabled' if disabled
      tag(:input, nil, attrs) + activity_type.name
    end

  end
end # Merb