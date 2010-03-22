begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'merb-core'

Merb::Config.setup(
  :merb_root   => ::File.expand_path(::File.dirname(__FILE__)),
  :environment => ENV['RACK_ENV'] || 'production'
)
Merb.environment = Merb::Config[:environment]
Merb.root = Merb::Config[:merb_root]
Merb::BootLoader.run

run Merb::Rack::Application.new
