class Redpear::Store::Value < Redpear::Store::Base

  # @return [String] the value
  def get
    conn.get(key)
  end
  alias_method :value, :get

  # Sets the value
  # @param [String] the value to set
  def set(value)
    conn.set(key, value)
  end
  alias_method :value=, :set

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

  # Comparator
  # @param [String] other
  # @return [Boolean] true, if equals `other`
  def ==(other)
    value == other
  end

  # @return [Boolean] true, if value is nil
  def nil?
    value.nil?
  end

  # @return [Boolean] true, if responds to `method`
  def respond_to?(method, *a)
    super || value.respond_to?(method, *a)
  end

  protected

    def method_missing(method, *a, &b)
      value.respond_to?(method) ? value.send(method, *a, &b) : super
    end

end