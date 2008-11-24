require 'rubygems'
require 'rubygems/specification'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'merb-core/test/tasks/spectasks'
require 'date'
require 'merb_rake_helper'

PLUGIN = "merb_dm_xss_terminate"
NAME = "merb_dm_xss_terminate"
GEM_VERSION = "0.5.3"
AUTHOR = "Mike Schwab"
EMAIL = "mike.schwab@gmail.com"
HOMEPAGE = "http://github.com/schwabsauce/merb_xss_terminate"
SUMMARY = "Plugin that auto-sanitizes data before it is saved in your DataMapper models"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('merb-core', '>= 0.9.0')
  s.add_dependency('html5', '>= 0.10.0')
  s.require_path = 'lib'
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin locally"
task :install => [:package] do
  sh %{#{sudo} #{gemx} install pkg/#{NAME}-#{GEM_VERSION} --local --no-update-sources}
end

desc "install frozen (source must be located somewhere inside main frozen gems folder)"
task :install_frozen => [:package] do
  if !path = gems_path
    puts "source must be located somewhere inside main frozen gems folder"
  else
    sh %{#{sudo} #{gemx} install pkg/#{NAME}-#{GEM_VERSION} -i #{path} --local --no-update-sources}
  end
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

namespace :jruby do
  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{sudo} jruby -S gem install pkg/#{NAME}-#{GEM_VERSION}.gem --no-rdoc --no-ri}
  end
end