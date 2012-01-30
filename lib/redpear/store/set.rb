class Redpear::Store::Set < Redpear::Store::Enumerable
  include Enumerable

  # @yield over a field-value pair
  # @yieldparam [String] field
  # @yieldparam [String] value
  def each(&block)
    members.each(&block)
  end

  # @return [Set] all members
  def all
    members.to_set
  end
  alias_method :to_set, :all
  alias_method :value, :all

  # @return [Array] the array of members
  def members
    conn.smembers(key) || []
  end
  alias_method :to_a, :members

  # @return [Integer] the number of items in the set
  def length
    conn.scard key
  end
  alias_method :size, :length

  # Adds a single value. Chainable example:
  #   set << 'a' << 'b'
  # @param [String] value
  #   A value to add
  def add(value)
    conn.sadd key, value
    self
  end
  alias_method :<<, :add

  # @param [String] value
  #   A value to delete
  def delete(value)
    conn.srem key, value
  end
  alias_method :remove, :delete

  # @return [Boolean] true, if value is included
  def include?(value)
    !!conn.sismember(key, value)
  end
  alias_method :member?, :include?

  # @return [Boolean] true, if empty
  def empty?
    length.zero?
  end

  # Removes a random value
  # @return [String] the removed value
  def pop
    conn.spop key
  end

  # Subtracts values using other sets
  # @param [multiple] others
  #   The other sets
  # @return [Array] remaining values
  def diff(*others)
    conn.sdiff key, *others.map(&:to_s)
  end
  alias_method :-, :diff

  # Store the result of a diff in a new +target+ key
  # @param [String] target
  #   The target key
  # @param [multiple] others
  #   The other sets
  # @return [Redpear::Store::Set] the result set
  def diffstore(target, *others)
    conn.sdiffstore target.to_s, key, *others.map(&:to_s)
    self.class.new target.to_s, conn
  end

  # Merges values of two sets
  # @param [multiple] others
  #   The other sets
  # @return [Array] union
  def union(*others)
    conn.sunion key, *others.map(&:to_s)
  end
  alias_method :+, :union
  alias_method :|, :union
  alias_method :merge, :union

  # Store the result of a union in a new +target+ key
  # @param [Redpear::Store::Set] other
  #   The other set
  # @param [multiple] others
  #   The other sets
  # @return [Redpear::Store::Set] the result set
  def unionstore(target, *others)
    conn.sunionstore target.to_s, key, *others.map(&:to_s)
    self.class.new target.to_s, conn
  end

  # @param [multiple] other
  #   The other sets
  # @return [Array] the intersection +other+ set
  def inter(*others)
    conn.sinter key, *others.map(&:to_s)
  end
  alias_method :intersect, :inter
  alias_method :inter, :inter
  alias_method :&, :inter

  # Store the result of an intersection in a new +target+ key
  # @param [String] target
  #   The target key
  # @param [multiple] others
  #   The other sets
  # @return [Redpear::Store::Set] the result set
  def interstore(target, *others)
    conn.sinterstore target.to_s, key, *others.map(&:to_s)
    self.class.new target.to_s, conn
  end

  # @return [String] a random member
  def random
    conn.srandmember key
  end

  # Comparator
  # @return [Boolean] true if contains same members as other
  def ==(other)
    other.respond_to?(:to_set) && other.to_set == to_set
  end

  # Move a value to +target+ set
  # @param [String] target
  #   The key of the target set
  # @param [String] value
  #   The value to move
  def move(target, value)
    conn.smove key, target.to_s, value
  end

end