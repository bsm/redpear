require 'securerandom'

class Redpear::Store::Base

  # Transforamtions
  IS_NIL     = ->v { v.nil? }.freeze
  IS_ZERO    = ->v { v.zero? }.freeze
  IS_ONE     = ->v { v == 1 }.freeze
  IS_TRUE    = ->v { !!v }.freeze
  TO_INT     = ->v { v.to_i }.freeze
  TO_SET     = ->v { v.to_set }.freeze
  PICK_FIRST = ->v { v.first }.freeze

  attr_reader :key, :conn

  # Creates and yields over a temporary key.
  # Useful in combination with e.g. `interstore`, `unionstore`, etc.
  #
  # @param [Redis] conn
  #   The connection
  # @param [Hash] options
  #   The options hash
  # @option [String] prefix
  #   Specify a key prefix. Example:
  #      Base.temporary conn, :prefix => "temp:" do |c|
  #        store.key # => temp:55ee0c1ec9530cf545bc25040beb4f292fd448af
  #      end
  # @yield [Redpear::Store::Base]
  #   The temporary key
  def self.temporary(conn, options = {})
    store = nil
    while !store || store.exists?
      key   = "#{options[:prefix]}#{SecureRandom.hex(20)}"
      store = new(key, conn)
    end
    yield store
  ensure
    store.purge! if store
  end

  # Constructor
  # @param [String] key
  #   The storage key
  # @param [Redis] conn
  #   The connection
  def initialize(key, conn)
    @key, @conn = key, conn
  end
  alias_method :to_s, :key

  # @return [String] custom inspect
  def inspect
    "#<#{self.class.name} #{key}: #{value.inspect}>"
  end

  # @return [Boolean] true if the record exists
  def exists?
    conn.exists(key)
  end

  # Watch this key
  # @return [Boolean] true if successful
  def watch(&block)
    conn.watch(key, &block)
    true
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
    case value = conn.del(key)
    when Redis::Future
      value.instance_eval { @transformation = IS_ONE }
    else
      value == 1
    end
  end

  # Deletes the record and returns the value
  def clear
    purge!
    value
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

    def range_pair(value, reversed = false)
      case value
      when Range
        first, last = value.first.to_i, value.last.to_i
        last -= 1 if value.exclude_end?
        reversed ? [last, first] : [first, last]
      when Array
        [value.first, value.last]
      end
    end

end
