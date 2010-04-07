module Rubytime
  module Test
    module ModelHelper

      def parse_factory_arguments(args)
        factory_name = (args.first.is_a?(Symbol) ? args.shift : self.name.snake_case).to_sym
        properties = args.first || {}
        [factory_name, properties]
      end

      def first_or_generate(attributes = {})
        first(attributes) || generate(attributes)
      end

      def generate(*args)
        Factory.create(*parse_factory_arguments(args))
      end

      def prepare(*args)
        Factory.build(*parse_factory_arguments(args))
      end

      def pick
        records = count
        (records > 0) ? first(:limit => 1, :offset => rand(records)) : nil
      end

      def pick_or_generate
        pick || generate
      end

      def prepare_hash(*args)
        Factory.attributes_for(*parse_factory_arguments(args))
      end

    end
  end
end
