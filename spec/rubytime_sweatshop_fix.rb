module DataMapper
  module Model
    def pick(name = default_fauxture_name)
      offset = (self.count * rand()).to_i
      self.first(:offset => offset, :limit => 1) or raise(NoFixturesExist, "no #{name} context fixtures have been generated for the #{self} class")
    end
  end
end