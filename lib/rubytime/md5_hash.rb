require 'digest/md5'

module Rubytime
  module DatamapperTypes
    class MD5Hash < DataMapper::Type
      
      class Password
        def self.encrypt(password)
          Digest::MD5::hexdigest password
        end
        
        def initialize(password)
          @hash = Password.encrypt(password)
        end
        
        def ==(password)
          @hash == Password.encrypt(password)
        end
        
        def to_s
          @hash
        end
      end
      
      
      primitive String
      size 60
      
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