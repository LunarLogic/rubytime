DataMapper.setup(:default, 'mysql://localhost/merb_xss_terminate_test')
Comment.auto_migrate!
Entry.auto_migrate!
Message.auto_migrate!
Person.auto_migrate!
Review.auto_migrate!
Page.auto_migrate!