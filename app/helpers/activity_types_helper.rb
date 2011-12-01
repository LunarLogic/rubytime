module Merb
  module ActivityTypesHelper

    def activity_type_children_summary(activity_type)
      activity_type.children.active.map { |at| at.name }.join(', ').truncate(60)
    end
  end
end # Merb