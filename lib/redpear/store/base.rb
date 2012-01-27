class Redpear::Store::Base

  attr_reader :key, :conn

  # Constructor
  # @param [String] key
  #   The storage key
  # @param [Redpear::Connection] conn
  #   The connection
  def initialize(key, conn)
    @key, @conn = key, conn
  end

  alias to_s key

  # @return [String] custom inspect
  def inspect
    "#<#{self.class.name} #{key}: #{value.inspect}>"
  end

  # @return [Boolean] true if the record exists
  def exists?
    !!conn.exists(key)
  end

  # @return [Integer] remaining time-to-live in seconds (if set)
  def ttl
    value = conn.ttl(key).to_i
    value if value > -1
  end

  # @return [String] type information for this record
  def type
    conn.type(key).to_sym
  end

  # Expires the record
  # @overload expire(time)
  #   @param [Time] time The time to expire the record at
  # @overload expire(seconds)
  #   @param [Integer] seconds Expire in `seconds` from now
  def expire(expiration)
    case expiration
    when Time
      expire_at(expiration)
    when Integer
      expire_in(expiration)
    when String
      expiration = Kernel::Integer(expiration) rescue nil
      expire(expiration)
    else
      false
    end
  end

  # Deletes the whole record
  def purge!
    conn.del key
  end

  # Expires the record
  # @param [Time] time The time to expire the record at
  def expire_at(time)
    conn.expireat key, time.to_i
  end

  # Expires the record
  # @param [Integer] seconds Expire in `seconds` from now
  def expire_in(seconds)
    conn.expire key, seconds.to_i
  end

  # @abstract, override in subclasses
  def value
    nil
  end

  private

    def range_pair(range)
      first = range.first.to_i
      last  = range.last.to_i
      last -= 1 if range.exclude_end?
      [first, last]
    end

end