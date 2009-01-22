# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_dm_xss_terminate}
  s.version = "0.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Schwab"]
  s.date = %q{2009-01-22}
  s.description = %q{Plugin that auto-sanitizes data before it is saved in your DataMapper models}
  s.email = %q{mike.schwab@gmail.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/merb_dm_xss_terminate.rb", "lib/merb_dm_xss_terminate", "lib/merb_dm_xss_terminate/merbtasks.rb", "lib/merb_dm_xss_terminate/rails_sanitize.rb", "lib/merb_dm_xss_terminate/xss_terminate.rb", "lib/merb_dm_xss_terminate/html", "lib/merb_dm_xss_terminate/html/selector.rb", "lib/merb_dm_xss_terminate/html/document.rb", "lib/merb_dm_xss_terminate/html/node.rb", "lib/merb_dm_xss_terminate/html/version.rb", "lib/merb_dm_xss_terminate/html/sanitizer.rb", "lib/merb_dm_xss_terminate/html/tokenizer.rb", "lib/merb_dm_xss_terminate/html5lib_sanitize.rb", "spec/models", "spec/models/review.rb", "spec/models/entry.rb", "spec/models/person.rb", "spec/models/page.rb", "spec/models/message.rb", "spec/models/comment.rb", "spec/merb_dm_xss_terminate_spec.rb", "spec/schema.rb", "spec/spec_helper.rb", "spec/config", "spec/config/database.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/schwabsauce/merb_xss_terminate}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Plugin that auto-sanitizes data before it is saved in your DataMapper models}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb-core>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<html5>, [">= 0.10.0"])
    else
      s.add_dependency(%q<merb-core>, [">= 0.9.0"])
      s.add_dependency(%q<html5>, [">= 0.10.0"])
    end
  else
    s.add_dependency(%q<merb-core>, [">= 0.9.0"])
    s.add_dependency(%q<html5>, [">= 0.10.0"])
  end
end
