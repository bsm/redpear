class Redpear::Store::Hash < Redpear::Store::Enumerable

  # @yield over a field-value pair
  # @yieldparam [String] field
  # @yieldparam [String] value
  def each(&block)
    all.each(&block)
  end

  # @return [Hash] all pairs
  def all
    conn.hgetall(key) || {}
  end
  alias_method :to_hash, :all
  alias_method :value, :all

  # @param [String] field
  #   The field to delete
  def delete(field)
    conn.hdel key, field
  end

  # @return [Boolean] true, if field exists
  def key?(field)
    !!conn.hexists(key, field)
  end
  alias_method :has_key?, :key?
  alias_method :member?, :key?
  alias_method :include?, :key?

  # @return [Boolean] true, if empty
  def empty?
    length.zero?
  end

  # @param [String] field
  #   The field to fetch
  # @return [String] value stored in +field+
  def fetch(field)
    conn.hget key, field
  end
  alias_method :[], :fetch

  # @param [String] field
  #   The field to store at
  # @param [String] value
  #   The value to store
  # @param [Hash] options
  #   The value to store
  def store(field, value, options = {})
    conn.hset key, field, value
  end
  alias_method :[]=, :store

  # @return [Array] all keys
  def keys
    conn.hkeys key
  end

  # @return [Array] all values
  def values
    conn.hvals key
  end

  # @return [Intege] the number of pairs in the hash
  def length
    conn.hlen key
  end
  alias_method :size, :length

  # @param [String] field
  #   The field to increment
  # @param [Integer] value
  #   The increment value, defaults to 1
  def increment(field, value = 1)
    conn.hincrby key, field, value
  end

  # @param [String] field
  #   The field to decrement
  # @param [Integer] value
  #   The decrement value, defaults to 1
  def decrement(field, value = 1)
    increment(field, -value)
  end

  # @param [multiple] fields
  #   The field to return
  # @return [Array] values
  def values_at(*fields)
    conn.hmget key, *fields
  end

  # @param [Hash] hash
  #   The pairs to update
  def update(hash)
    merge!(hash)
    to_hash
  end

  # @param [Hash] hash
  #   The pairs to merge
  def merge!(hash)
    conn.hmset key, *hash.flatten
  end

  # Comparator
  # @return [Boolean] true if same as `other`
  def ==(other)
    other.respond_to?(:to_hash) && other.to_hash == to_hash
  end

end