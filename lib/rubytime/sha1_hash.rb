require 'digest/sha1'

module Rubytime
  module DatamapperTypes
    class SHA1Hash < DataMapper::Type
      
      class Password
        attr_accessor :hash
        
        def self.encrypt(password)
          Digest::SHA1::hexdigest(password)
        end
        
        def initialize(password)
          @hash = Password.encrypt(password)
        end
        
        def ==(password)
          case password
          when String
            @hash == Password.encrypt(password)
          when Password
            @hash == password.hash
          else
            raise ArgumentError.new("@password should be either String or Rubytime::DataMapper::SHA1Hash::Password.")
          end
        end
        
        def to_s
          @hash
        end
      end
      
      
      primitive String
      size 40
      
      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          Password.new value
        else
          raise ArgumentError.new("+value+ must be nil or a String")
        end
      end
      
      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end
      
      # def self.typecast(value, property)
      #   value.is_a?(Password) ? value : load(value, property)
      # end
    end
  end
end