class UserObserver
  include DataMapper::Observer

  observe User

  after :create do
#    Merb::Mailer.new(:to => self.email, :from => "rubytime", :subject => ..., :text => "Users with no HTML rendering mail clients will see this").deliver! 
#puts "-------------- jolaaaaaaaaa ------------------"
    puts self
    # log message
  end
end
