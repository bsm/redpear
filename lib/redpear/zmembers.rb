class Redpear::ZMembers < Redpear::Members

  # @return [Hash] the actual members
  def members
    @members ||= range.to_set
  end

  # @param [Hash] options
  # @option [Integer] start, start index, defaults to 0
  # @option [Integer] stop, stop index, defaults to -1
  # @returns [Hash] range of members, lowest rank first
  def range(options = {})
    options = options.merge(:start => 0, :stop => -1)
    nest.zrange options.delete(:start), options.delete(:stop), options
  end

  # @param [Hash] options
  # @option [Integer] start, start index, defaults to 0
  # @option [Integer] stop, stop index, defaults to -1
  # @returns [Hash] range or members, highest rank first
  def reverse_range(options = {})
    options = options.merge(:start => 0, :stop => -1)
    nest.zrevrange options.delete(:start), options.delete(:stop), options
  end

  # Is the value a member? This method is not cached, try using #include? instead.
  # @param [String] value
  def is_member?(value)
    !!nest.zscore(value)
  end

  # @return [Integer] the cardinality of this set.
  # This method is not cached, try using #count instead.
  def cardinality
    nest.zcard
  end

  # @return [Integer] the score for a member
  # This method is not cached.
  def score(value)
    nest.zscore(value)
  end

  # Add a member to this set
  # @param [String] member
  def add(member, score = 0)
    @members << member if loaded?
    nest.zadd(score, member)
  end

  # Remove a member from this set
  # @param [String] member
  def remove(member, score = 0)
    @members.delete(member.to_s) if loaded?
    nest.zrem(member)
  end

end
