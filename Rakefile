require 'rubygems'
require 'rake/rdoctask'

require 'merb-core'
require 'merb-core/tasks/merb'

include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)
     
# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each{|rake_file| load rake_file }

desc "Start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end

require 'spec/rake/spectask'
require 'merb-core/test/tasks/spectasks'

desc 'Default: run spec examples'
task :default => 'spec'

# Hack for top-level name clash between vlad and datamapper.
if Rake.application.top_level_tasks.any? {|t| t == 'deploy' or t =~ /^vlad:/}
  begin
    $TESTING = true # Required to bypass check for reserved_name? in vlad. DataMapper 0.9.x defines Kernel#repository...
    require 'vlad'
    Vlad.load :scm => "git", :app => nil, :web => nil
  rescue LoadError
    # do nothing
  end
end

##############################################################################
# ADD YOUR CUSTOM TASKS IN /lib/tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################
