class ActivityObserver
  include DataMapper::Observer

  observe Activity

  after :create do
    user.update(:activities_count => user.activities_count+1)
    notify_project_managers_if_enabled(:created) if date < Date.today - 1
  end

  after :destroy do
    user.update(:activities_count => (new_count = user.activities_count - 1) > 0 ? new_count : 0)
    notify_project_managers_if_enabled(:destroy) if date < Date.today - 1
  end
  
  after :update do
    notify_project_managers_if_enabled(:updated) if date < Date.today - 1
  end
end
