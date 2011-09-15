# -*- coding: utf-8 -*-
class Currency
  include DataMapper::Resource
  
  PREFIX_REGEX = SUFFIX_REGEX = /^[^0-9]*$/
  
  property :id, Serial
  property :singular_name, String, :required => true
  property :plural_name,   String, :required => true
  property :prefix,        String
  property :suffix,        String
  
  validates_uniqueness_of :singular_name, :plural_name
  validates_format_of :prefix, :with => PREFIX_REGEX, :if => proc { |c| not c.prefix.nil? }
  validates_format_of :suffix, :with => SUFFIX_REGEX, :if => proc { |c| not c.suffix.nil? }
  validates_with_method :singular_name, :method => :validates_singular_name_format
  validates_with_method :plural_name, :method => :validates_plural_name_format
  
  default_scope(:default).update(:order => [:singular_name])
  
  def render(value)
    "#{prefix}#{format('%.2f',value)}#{suffix}"
  end
  
  [:singular_name, :plural_name].each do |attr|
    define_method "validates_#{attr}_format" do
      if self.send(attr) =~ /^[\p{Word} ]*$/u && self.send(attr) !~ /[\d_]/
        true
      else
        [false, "#{attr.to_s.humanize} has an invalid format."]
      end 
    end
  end
  
end
