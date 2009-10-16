merb_gems_version = "~>1.0.11"
dm_gems_version   = "~>0.9.11"

dependency "merb_datamapper", merb_gems_version
dependency "merb-assets", merb_gems_version        # Provides link_to, asset_path, auto_link, image_tag methods (and lots more)
dependency "merb-helpers", merb_gems_version       # Provides the form, date/time, and other helpers
dependency "merb-mailer", merb_gems_version        # Integrates mail support via Merb Mailer
dependency "merb-slices", merb_gems_version        # Provides a mechanism for letting plugins provide controllers, views, etc. to your app
dependency "merb-auth-core", merb_gems_version          # An authentication slice (Merb's equivalent to Rails' restful authentication)
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version

dependency "dm-core", dm_gems_version         # The datamapper ORM
dependency "dm-aggregates", dm_gems_version   # Provides your DM models with count, sum, avg, min, max, etc.
dependency "dm-timestamps", dm_gems_version   # Automatically populate created_at, created_on, etc. when those properties are present.
dependency "dm-types" , dm_gems_version       # Provides additional types, including csv, json, yaml.
dependency "dm-validations", dm_gems_version  # Validation framework
dependency "dm-migrations", dm_gems_version   # Migrations support
dependency "dm-observer", dm_gems_version
dependency "dm-sweatshop", dm_gems_version    # Data generator
dependency "dm-serializer", dm_gems_version   # Serialization
dependency "dm-constraints", '0.9.9'          # Validation framework

dependency "do_mysql", dm_gems_version
dependency "addressable", "~> 2.0.2", :require_as => 'addressable/uri'

# dependency "merb-action-args", "0.9.10"   # Provides support for querystring arguments to be passed in to controller actions
# dependency "merb-cache", "0.9.10"         # Provides your application with caching functions 

dependency "randexp", ">=0.1.3"
dependency "chronic", ">=0.2.3"
dependency "html5", ">=0.10.0"
dependency "merb_dm_xss_terminate", "0.5.3"

require 'digest/sha1'
require "csv" # dependency raises error
