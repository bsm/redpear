class Redpear::Store::Counter < Redpear::Store::Value

  # @return [Integer] the value
  def get
    super.to_i
  end

  # Sets the value
  # @param [Integer] the value to set
  def set(value)
    super Kernel::Integer(value)
  end

  undef_method :append
  undef_method :<<

  # Increments the value
  # @param [Integer] by
  #   The increment, defaults to 1
  def increment(by = 1)
    case by
    when 1
      conn.incr(key)
    else
      conn.incrby(key, by)
    end
  end
  alias_method :next, :increment

  # Decrements the value
  # @param [Integer] by
  #   The decrement, defaults to 1
  def decrement(by = 1)
    case by
    when 1
      conn.decr(key)
    else
      conn.decrby(key, by)
    end
  end
  alias_method :previous, :decrement
  alias_method :prev, :decrement

end