module Merb
  module Session
    def abandon!
      self.user.forget_me! unless self.user.nil?
      authentication.abandon!
    end
  end
end