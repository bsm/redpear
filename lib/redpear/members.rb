class Redpear::Members
  include Enumerable

  def initialize(nest)
    @nest    = nest
    @members = Set.new unless @nest
  end

  def loaded?
    !@members.nil?
  end

  def each(&block)
    members.each(&block)
  end

  def exists?(value)
    loaded? ? @members.include?(value.to_s) : @nest.sismember(value)
  end

  def members
    @members ||= @nest.smembers.to_set
  end

  def count
    members.count
  end

  def size
    members.size
  end

  def ==(other)
    other.is_a?(Array) ? to_a == other : super
  end

end
