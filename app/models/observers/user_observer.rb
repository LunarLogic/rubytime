class UserObserver
  include DataMapper::Observer

  observe User

  after :create do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:welcome, :to => self.email, :from => Rubytime::CONFIG[:mail_from], :subject => "Welcome to Rubytime!")
  end
  
  after :reset_password! do
    m = UserMailer.new(:user => self)
    m.dispatch_and_deliver(:new_password, :to => self.email, :from => Rubytime::CONFIG[:mail_from], :subject => "Your new password for Rubytime")
  end
end
