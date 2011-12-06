# -*- coding: utf-8 -*-
class Currency
  include DataMapper::Resource
  
  property :id, Serial
  property :singular_name, String, :required => true
  property :plural_name,   String, :required => true
  property :prefix,        String
  property :suffix,        String
  
  validates_uniqueness_of :singular_name, :plural_name
  
  default_scope(:default).update(:order => [:singular_name])
  
  def render(value)
    "#{prefix}#{format('%.2f',value)}#{suffix}"
  end
end
