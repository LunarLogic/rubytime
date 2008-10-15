class UserObserver
  include DataMapper::Observer

  observe User

  after :create do
    #m = UserMailer.new(:to => self.email, :from => Rubytime::CONFIG[:mail_from], :subject => "Welcome to Rubytime!")
    #m.dispatch_and_deliver(:welcome, :user => self)
  end
end
