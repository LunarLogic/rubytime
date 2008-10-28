module Rubytime
  module Test
    module SpecsHelper
      private 
  
      class BlockMatcher
        def initialize()
          @matchers = []
        end
  
        def and(matcher, &blk)
          @matchers << [:should, matcher]
          run(&blk) if block_given?
          self
        end
  
        def and_not(matcher, &blk)
          @matchers << [:should_not, matcher]
          run(&blk) if block_given?      
          self
        end
  
        private
  
        def run(&blk)
          @matchers.inject(blk) do |memo, matcher|
            proc { memo.send matcher[0], matcher[1] }
          end.call
        end
      end

      def block_should(matcher, &blk)
        BlockMatcher.new.and(matcher, &blk)
      end

      def block_should_not(matcher, &blk)
        BlockMatcher.new.and_not(matcher, &blk)
      end

      def raise_argument_error
        raise_error ArgumentError
      end
    end
  end
end
