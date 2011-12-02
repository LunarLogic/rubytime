source 'http://rubygems.org'

gem 'rails', '~> 3.0'
gem 'mysql'

dm_gems_version = '1.1.0'

gem 'dm-aggregates',    dm_gems_version
gem 'dm-core',          dm_gems_version
gem 'dm-is-list',       dm_gems_version
gem 'dm-is-tree',       dm_gems_version
gem 'dm-migrations',    dm_gems_version
gem 'dm-mysql-adapter', dm_gems_version
gem 'dm-observer',      dm_gems_version
gem 'dm-rails',         dm_gems_version
gem 'dm-serializer',    dm_gems_version
gem 'dm-timestamps',    dm_gems_version
gem 'dm-transactions',  dm_gems_version
gem 'dm-types' ,        dm_gems_version
gem 'dm-validations',   dm_gems_version
# gem 'dm-constraints', dm_gems_version  # TODO: this doesn't work, throws some kind of SQL error during migration

gem 'devise'
gem 'dm-devise', '~> 1.5.0'
gem 'i18n' # for whenever
gem 'icalendar', '~>1.1.0'
gem 'net-ldap'
gem 'whenever', :require => false

# gem 'rack_revision_info'
# gem 'nokogiri', '1.4.1'  # for rack_revision_info
# TODO: revision info doesn't work on the production now (which was the whole point) because Vlad deletes .git
# directory from deployed code so there's no way to check current revision... this should be fixed when we switch
# to Capistrano

group :development do
  gem 'vlad', :require => []
  gem 'vlad-git', :require => []
end

group :development, :test do
  gem 'ci_reporter'
  gem 'delorean'
  gem 'factory_girl_rails'
  gem 'jslint_on_rails'
  gem 'rcov'
  gem 'rspec-rails'

  if RUBY_VERSION.include?('1.9')
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
    gem 'linecache', '0.43'
  end
end

group :production do
  gem 'juicer'
end

