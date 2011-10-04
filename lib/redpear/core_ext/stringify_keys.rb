# Hash stringify_keys extension. "Borrowed" from ActiveSupport.
class Hash

  # Return a new hash with all keys converted to strings.
  def stringify_keys
    dup.stringify_keys!
  end

  # Destructively convert all keys to strings.
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key) unless key.is_a?(String)
    end
    self
  end

end unless Hash.new.respond_to?(:symbolize_keys)