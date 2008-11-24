require File.dirname(__FILE__) + '/html/document'

class RailsSanitize

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  def self.white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def sanitized_uri_attributes=(attributes)
    HTML::WhiteListSanitizer.uri_attributes.merge(attributes)
  end

  def sanitized_bad_tags=(attributes)
    HTML::WhiteListSanitizer.bad_tags.merge(attributes)
  end

  def sanitized_allowed_tags=(attributes)
    HTML::WhiteListSanitizer.allowed_tags.merge(attributes)
  end

  def sanitized_allowed_attributes=(attributes)
    HTML::WhiteListSanitizer.allowed_attributes.merge(attributes)
  end

  def sanitized_allowed_protocols=(attributes)
    HTML::WhiteListSanitizer.allowed_protocols.merge(attributes)
  end
end
