class ActivityObserver
  include DataMapper::Observer

  observe Activity

  after :create do
    notify_project_managers_about_saving__if_enabled('created') if date < Date.today - 1
  end
  
  after :update do
    notify_project_managers_about_saving__if_enabled('updated') if date < Date.today - 1
  end
  
end
