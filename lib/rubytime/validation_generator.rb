module Rubytime
  module ValidationGenerator
    def self.included(base)
      base.send :extend, ClassMethods
    end
    
    module ClassMethods
      def validation_info(context = :default)
        info = {}
        info[:messages] = [] 
        info[:rules] = 
          validators.contexts[context].map do |validator|
            rule = {}
            field_name = validator.field_name
            rule[field_name] = {}          
            options = validator.instance_variable_get(:@options)
            
            case validator
            when DataMapper::Validate::RequiredFieldValidator
              rule[field_name] = { :required => true }
            when DataMapper::Validate::LengthValidator
              # LengthValidator has both instance variables and options for :min and :max
              rule[field_name][:required]  = true
              if validator.instance_variable_defined?(:@min)
                rule[field_name][:minlength] = validator.instance_variable_get(:@min)
              end
              if validator.instance_variable_defined?(:@max)
                rule[field_name][:maxlength] = validator.instance_variable_get(:@max)
              end
              #TODO: handle range
            when DataMapper::Validate::FormatValidator
              rule[field_name][:required] = options[:allow_nil] || false
              if (options[:with] || options[:as]) == :email
                rule[field_name] = { :email => true }
              end
              # rule[field_name] 
            end
            rule
          end
        # remove unhandled validators
        info[:rules].reject! { |rule| rule.empty? } 
        info
      end
    end
  end
end