class Employee < User
  property :role, Enum[:developer, :tester, :project_manager], :default => :developer
end
