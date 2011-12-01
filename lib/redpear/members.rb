class Redpear::Members
  include Enumerable

  attr_reader :nest

  # Constructor
  # @param [Redpear::Nest] the nest object
  def initialize(nest)
    @nest = nest
  end

  # @return [Boolean] true if member have been loaded
  def loaded?
    !@members.nil?
  end

  # @yield [String] do something with each member
  def each(&block)
    members.each(&block)
  end

  # @param [String] value check if this value is a member
  # @return [Boolean] true if members contain the value
  def include?(value)
    loaded? ? @members.include?(value.to_s) : is_member?(value)
  end

  # @return [Set] the actual members
  def members
    @members ||= nest.smembers.to_set
  end

  # @return [Integer] then count of members
  def count
    @count ||= loaded? ? @members.size : cardinality
  end
  alias_method :size, :count

  # Compares members
  # @param [Object] other the object to compare with
  # @return [Boolean] true if same as other
  def ==(other)
    case other
    when Redpear::Members
      other.members == members
    when Set
      other == members
    when Array
      other.to_set == members
    else
      super
    end
  end

  # Is the value a member? This method is not cached, try using #include? instead.
  # @param [String] value
  def is_member?(value)
    nest.sismember(value)
  end

  # @return [Integer] the cardinaliry of this set.
  # This method is not cached, try using #count instead.
  def cardinality
    nest.scard
  end

  # Add a member to this set
  # @param [String] member
  def add(member)
    @members << member.to_s if loaded?
    nest.sadd(member)
  end

  # Remove a member from this set
  # @param [String] member
  def remove(member)
    @members.delete(member.to_s) if loaded?
    nest.srem(member)
  end

end
