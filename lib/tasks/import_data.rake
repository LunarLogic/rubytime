desc "import data from rubytime 2 db"
namespace :rubytime do
  task :import_data => :merb_env do
    require Merb.root / "lib" / "rubytime" / "legacy"
    Rubytime::Legacy::import_data
  end
end
