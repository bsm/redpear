class Redpear::Store::Value < Redpear::Store::Base

  # Deletes the value
  # @see Redpear::Store::Base#purge!
  alias_method :delete, :purge!

  # @return [String] the value
  def get
    conn.get(key)
  end

  # @see #get
  def value
    get
  end

  # Sets the value
  # @param [String] the value to set
  def set(value)
    conn.set(key, value)
  end

  # @see #set
  def value=(*a)
    set(*a)
  end

  # @see #set
  def replace(*a)
    set(*a)
  end

  # Appends a `value`
  # @param [Integer] value
  #   The value to append
  def append(value)
    conn.append(key, value)
    self
  end
  alias_method :<<, :append

  # Comparator
  # @param [String] other
  # @return [Boolean] true, if equals `other`
  def ==(other)
    case value = self.value
    when Redis::Future
      value.instance_eval { @transformation = Kernel.lambda {|v| v == other } }
    else      
      value == other
    end
  end

  # @return [Boolean] true, if value is nil
  def nil?
    case value = self.value
    when Redis::Future
      value.instance_eval { @transformation = IS_NIL }
    else      
      value.nil?
    end
  end

  # @return [Boolean] true, if responds to `method`
  def respond_to?(method, *a)
    super || (value || "").respond_to?(method, *a)
  end

  protected

    def method_missing(method, *a, &b)
      base = (value || "")
      base.respond_to?(method) ? base.send(method, *a, &b) : super
    end

end
