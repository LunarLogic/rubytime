# Monkey patch for factory_girl to have a more generic sequence
# http://devblog.timmedina.com

class FactoryGirl::DefinitionProxy

  def custom_sequence(name, initial_value = 1, &block)
    s = Sequence.new(initial_value, &block)
    add_attribute(name) { s.next }
  end

  class Sequence

    def initialize(initial_value = 1, &proc)
      @proc = proc
      @value = initial_value
    end

    def next
      prev, @value = @value, @value.next
      @proc.call(prev)
    end

  end

end

# Monkey patch to make factory_girl work with Datamapper as expected
# Without this the factory happily returns invalid objects by calling
# save! which just skips validations and hooks in DM

class FactoryGirl::Proxy::Create < FactoryGirl::Proxy::Build
  def result(to_create)
    run_callbacks(:after_build)
    if to_create
      to_create.call(@instance)
    else
      raise "Validation failed in #{@instance.class} factory" unless @instance.save
    end
    run_callbacks(:after_create)
    @instance
  end
end
