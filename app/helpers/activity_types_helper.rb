module ActivityTypesHelper
  
  def activity_type_children_summary(activity_type)
    activity_type.children.map{|at| at.name}.join(', ').truncate(60)
  end
end
