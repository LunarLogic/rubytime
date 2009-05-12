desc "configure and install RubyTime"
namespace :rubytime do
  
  task :install => :merb_env do
    Rake::Task['db:automigrate'].invoke
    puts "---------------- creating database structure \t [ \e[32mDONE\e[0m ]"
    Rake::Task['rubytime:kickstart'].invoke
    puts "---------------- populate database tables with initial data \t [ \e[32mDONE\e[0m ]"
    puts 'Roles automatically created:'
    Role.all.each { |role| puts " - #{role.name}"}
    puts 'Users automatically created:'
    User.all.each do |user|
      print " - #{user.name}"
      puts " (#{user.role.name})" rescue puts ' <without role>'
    end
    print 'Woud you like to create another role? [y/N] '
    Rake::Task['rubytime:create_role'].invoke if STDIN.gets.chomp =~ /[Yy]/
    print 'Woud you like to create new account? [y/N] '
    Rake::Task['rubytime:create_account'].invoke if STDIN.gets.chomp =~ /[Yy]/
    puts 'Thank you for installing RubyTime'
  end

  task :create_account do
    print '- login for new account: '
    account_login = STDIN.gets.chomp
    print '- password for new account: '
    account_passwd = STDIN.gets.chomp
    print '- confirm password for new account: '
    account_passwd_conf = STDIN.gets.chomp
    print '- your name for new account: '
    account_name = STDIN.gets.chomp
    print '- email for new account: '
    account_email = STDIN.gets.chomp
    puts '- select number of role:'
    Role.all.each do |role|
      puts "\t #{role.id}. #{role.name}"
    end
    puts "\t #{Role.all.count+1}. < without role >"
    role = {}
    account_role_id = STDIN.gets.chomp.to_i
    if (1..Role.all.count).include?(account_role_id)
      role = {:role_id => account_role_id}
    end
    new_user = User.new(role.merge!(:name => account_name, :login => account_login, :password => account_passwd, :password_confirmation => account_passwd_conf, :email => account_email))
    print "creating new account\t"
    puts new_user.save ? "[ \e[32mDONE\e[0m ]" : "[\e[31mFAILED\e[0m]"
  end

  task :create_role do
    print 'name of new role: '
    role_name = STDIN.gets.chomp
    role = Role.new(:name => role_name)
    print "creating new role\t"
    puts role.save ? "[ \e[32mDONE\e[0m ]" : "[\e[31mFAILED\e[0m]"
  end

end
