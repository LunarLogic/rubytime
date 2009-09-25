class String
  def generate_random(length)
    Array.new(length) { self[rand(size),1] }.join
  end
end