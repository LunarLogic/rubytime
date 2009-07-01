require 'randexp'

# This adds the ability of reading word lists from a local file
# instead of reading them from the system dependent location
module Randexp::DictionaryFix
  def self.included(base)
    base.class_eval do
      class << self
        attr_reader :dict_path
        alias original_load_dictionary load_dictionary

        def dict_path=(path)
          @@words = nil
          @dict_path = path
        end

        def load_dictionary
          if dict_path && File.exists?(dict_path)
            return File.read(dict_path).split
          else
            return original_load_dictionary
          end
        end
      end
    end
  end
end

Randexp::Dictionary.send :include, Randexp::DictionaryFix unless Randexp::Dictionary.included_modules.include? Randexp::DictionaryFix