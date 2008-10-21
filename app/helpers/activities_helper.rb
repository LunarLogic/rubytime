module Merb
  module ActivitiesHelper

    def criteria_icons(i, size)
      tags = ""
      tags << link_to(image_tag("icons/minus.png"), "#", :class => "remove_criterium", 
                                                     :style => "display: #{ i > 0 ? 'inline' : '' }")
      tags << link_to(image_tag("icons/plus.png"), "#", :class => "add_criterium", 
                                                    :style => "display: #{ i == size-1 ? 'inline' : '' }")
      tags
    end
  end
end # Merb