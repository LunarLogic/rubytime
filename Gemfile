disable_system_gems
clear_sources
source "http://gemcutter.org"
source "http://gems.github.com"
bundle_path 'gems'

gem "do_mysql"

dm_gems_version = "0.10.1"

gem "dm-core", dm_gems_version
gem "dm-aggregates", dm_gems_version
gem "dm-timestamps", dm_gems_version
gem "dm-types" , dm_gems_version
gem "dm-validations", dm_gems_version
gem "dm-migrations", dm_gems_version
gem "dm-observer", dm_gems_version
gem "dm-sweatshop", dm_gems_version
gem "dm-serializer", dm_gems_version
gem "dm-constraints", dm_gems_version

merb_gems_version = "1.0.12"

gem "merb_datamapper", merb_gems_version
gem "merb-assets", merb_gems_version
gem "merb-helpers", merb_gems_version
gem "merb-mailer", merb_gems_version
gem "merb-slices", merb_gems_version
gem "merb-auth-core", merb_gems_version
gem "merb-auth-more", merb_gems_version
gem "merb-auth-slice-password", merb_gems_version

git "git://github.com/schwabsauce/merb_dm_xss_terminate.git" do
  gem "merb_dm_xss_terminate"
end

gem "randexp", ">=0.1.3"
gem "chronic", ">=0.2.3"
gem "html5", ">=0.10.0"
gem "icalendar", "~>1.1.0"

only :test do
  gem 'webrat'
  gem "bartes-rcov_stats" , :require_as => 'rcov_stats'
end
