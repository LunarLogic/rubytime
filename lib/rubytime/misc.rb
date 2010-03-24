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
  end
  
  decimal_separator_formats = {
    :dot   => { :number => { :delimiter => '', :separator => '.' } },
    :comma => { :number => { :delimiter => '', :separator => ',' } }
  }
  
  Numeric::Transformer.add_format(decimal_separator_formats)

  DATE_FORMAT_NAMES = [:european, :american]
  DATE_FORMATS = { :european => { :format => "%d-%m-%Y", :description => "DD-MM-YYYY" }, :american => { :format => "%m/%d/%Y", :description => "MM/DD/YYYY" } }
  RECENT_DAYS_ON_LIST = [7, 14, 30]
  PASSWORD_RESET_LINK_EXP_TIME = 1.day
  DECIMAL_SEPARATORS = [:dot, :comma]

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