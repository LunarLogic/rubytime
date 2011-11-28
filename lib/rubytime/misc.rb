module Rubytime
  module Misc
    def self.generate_password(size = 3)
      c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr lt)
      v = %w(a e i o u y)
      f, r = true, ''
      (size * 2).times do
        r << (f ? c[rand * c.size] : v[rand * v.size])
        f = !f
      end
      r
    end

    def self.check_activity_roles
      return if ARGV.include?("db:autoupgrade")

      begin
        return unless Activity.first(:role_id => -1)
      rescue Exception => e
        p e
        raise "*** Please run db:autoupgrade"
      end

      puts "*** Updating activity role_id fields - please wait..."
      activities = Activity.all(:role_id => -1)
      count = activities.count
      activities.each_with_index do |a, i|
        puts "#{i} / #{count}"
        a.role = a.role_for_date
        a.save! # saving without validations on purpose, because some activities may be invalid
                # e.g. because types or properties were defined after they were created
      end
    end
  end

   decimal_separator_formats = {
     :dot   => { :number => { :delimiter => '', :separator => '.' } },
     :comma => { :number => { :delimiter => '', :separator => ',' } }
   }
  
  DATE_FORMAT_NAMES = [:european, :american]
  DATE_FORMATS = { :european => { :format => "%d-%m-%Y", :description => "DD-MM-YYYY" }, :american => { :format => "%m/%d/%Y", :description => "MM/DD/YYYY" } }
  RECENT_DAYS_ON_LIST = [7, 14, 30]
  PASSWORD_RESET_LINK_EXP_TIME = 86400 # One day
  DECIMAL_SEPARATORS = [:dot, :comma]
  DECIMAL_FORMATS = {
    :dot => {:delimiter => "", :separator => "."},
    :comma => {:delimiter => "", :separator => ","}
   }

  CONFIG = {}
end

class DataMapper::Validate::ValidationErrors
  def to_json
    @errors.to_json
  end
end

if RUBY_VERSION < "1.8.7"
  class Fixnum
    def pred
      self - 1
    end
  end

  class Array
    def group_by
      inject({}) do |groups, element|
        (groups[yield(element)] ||= []) << element
        groups
      end
    end
  end
end
