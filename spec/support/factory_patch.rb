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
