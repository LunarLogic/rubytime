namespace :merb_dm_xss_terminate do
  namespace :db do

    desc "Given MODELS=Foo,Bar,Baz find all instances in the DB and save to sanitize existing records"
    task :sanitize => :environment do
      models = Dir.open(Merb.root + '/app/models').reject { |file_name| ['.', '..'].include? file_name }.map { |file_name| file_name.gsub(/\.rb/, '').gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase } }
      models.each do |model|
        Module.const_get(model).send(:all).map { |record| record.save }
      end
    end
  end
end
