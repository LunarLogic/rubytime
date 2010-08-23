source "http://rubygems.org"

gem "do_mysql"

dm_gems_version = "0.10.2"

gem "dm-core", dm_gems_version
gem "dm-aggregates", dm_gems_version
gem "dm-timestamps", dm_gems_version
gem "dm-types" , dm_gems_version
gem "dm-validations", dm_gems_version
gem "dm-migrations", dm_gems_version
gem "dm-observer", dm_gems_version
gem "dm-serializer", dm_gems_version
# gem "dm-constraints", dm_gems_version  # TODO: this doesn't work, throws some kind of SQL error during migration
gem "dm-is-tree", dm_gems_version
gem "dm-is-list", dm_gems_version

merb_gems_version = "1.1.0.pre" # TODO: update to 1.1.1 when available; 1.1.0 final breaks mongrel with rack middlewares

gem "merb-core", merb_gems_version
gem "merb_datamapper", merb_gems_version
gem "merb-assets", merb_gems_version
gem "merb-helpers", merb_gems_version
gem "merb-mailer", merb_gems_version
gem "merb-slices", merb_gems_version
gem "merb-auth-core", merb_gems_version
gem "merb-auth-more", merb_gems_version
gem "merb-auth-slice-password", merb_gems_version
gem "merb-param-protection", merb_gems_version
gem "merb-exceptions", merb_gems_version

git "git://github.com/schwabsauce/merb_dm_xss_terminate.git" do
  gem "merb_dm_xss_terminate"
end

gem "mongrel", "1.1.5"
gem "icalendar", "~>1.1.0"
gem "fastercsv", '1.5.3'
gem 'rack_revision_info'
gem 'nokogiri', '1.4.1'  # for rack_revision_info
# TODO: revision info doesn't work on the production now (which was the whole point) because Vlad deletes .git
# directory from deployed code so there's no way to check current revision... this should be fixed when we switch
# to Capistrano

group :development do
  gem 'vlad', '2.0.0', :require => []
  gem 'vlad-git', '2.0.0', :require => []
end

group :development, :test do
  gem "dm-factory_girl", "1.2.3", :require => "factory_girl", :git => "git://github.com/psionides/factory_girl_dm.git"
  gem "rspec", '1.3.0', :require => "spec"
  gem "rcov"
  gem "rcov_stats"
  gem "ci_reporter"
  gem "jslint_on_rails"
  gem 'ruby-debug'
  gem 'delorean'
end
