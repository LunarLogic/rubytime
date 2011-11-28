desc "configure and install RubyTime"
namespace :rubytime do
  
  task :install => :environment do
    Rake::Task['db:automigrate'].invoke
    puts "---------------- creating database structure \t [ \e[32mDONE\e[0m ]"
    Rake::Task['db:seed'].invoke
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
    puts 'Default password for users is password'
    puts 'Thank you for installing RubyTime'
  end

  task :create_account => :environment do
    print '- login for new account: '
    account_login = STDIN.gets.chomp
    print '- password for new account (6 characters at least): '
    account_passwd = STDIN.gets.chomp
    print '- your name for new account: '
    account_name = STDIN.gets.chomp
    print '- email for new account: '
    account_email = STDIN.gets.chomp
    puts '- available roles:'
    Role.all.map do |role|
      puts "\t #{role.id}. #{role.name}"
    end
    puts "\t #{Role.all.count+1}. < without role >"
    print '- select number of role: '
    account_role_id = STDIN.gets.chomp.to_i
    settings = {}
    if (1..Role.all.count).include?(account_role_id)
      settings = {:role_id => account_role_id}
    else
      puts 'wrong role id !'
      exit
    end
    settings.merge!(:name => account_name, :login => account_login, :password => account_passwd, :password_confirmation => account_passwd, :email => account_email)
    new_user = Employee.new(settings)
    print "creating new account\t"
    puts new_user.save ? "[ \e[32mDONE\e[0m ]" : "[\e[31mFAILED\e[0m]"
  end

  task :create_role => :environment do
    print 'name of new role: '
    role_name = STDIN.gets.chomp
    role = Role.new(:name => role_name)
    print "creating new role\t"
    puts role.save ? "[ \e[32mDONE\e[0m ]" : "[\e[31mFAILED\e[0m]"
  end

end
