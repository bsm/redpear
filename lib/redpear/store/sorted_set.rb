class Redpear::Store::SortedSet < Redpear::Store::Enumerable
  include Enumerable

  # @yield over a field-score pair
  # @yieldparam [String] field
  # @yieldparam [String] score
  def each(&block)
    all.each(&block)
  end

  # @param [Hash] options
  # @option [Boolean] with_scores
  #   Return with scores, defaults to true
  # @return [Array] all elements
  def all(options = {})
    slice(0..-1, options)
  end
  alias_method :to_a, :all

  # @return [Integer] the number of items in the set
  def length
    conn.zcard key
  end
  alias_method :size, :length

  # @param [Range] range
  # @return [Integer] the number of items within given score `range`
  def count(range)
    conn.zcount key, *range_pair(range)
  end

  # Adds a single member.
  # @param [String] member
  #   A member to add
  # @param [Integer] score
  #   The score
  def add(member, score)
    conn.zadd key, score, member
    self
  end
  alias_method :[]=, :add

  # Determines the score of a member
  # @param [String] member
  # @return [Integer] the score for the given `member`
  def score(member)
    number = conn.zscore(key, member)
    number.to_i if number
  end
  alias_method :[], :score

  # Determines the index of a member (based on ascending scores)
  # @param [String] member
  # @return [Integer] the index for the given `member`
  def index(member)
    number = conn.zrank(key, member)
    number.to_i if number
  end
  alias_method :rank, :index

  # Determines the reverse index of a member (based on descending scores)
  # @param [String] member
  # @return [Integer] the index for the given `member`
  def rindex(member)
    number = conn.zrevrank(key, member)
    number.to_i if number
  end
  alias_method :rrank, :rindex

  # @param [String] member
  #   The `member` to delete
  def delete(member)
    conn.zrem key, member
  end

  # @return [Array] empty array
  def clear
    conn.zremrangebyrank key, 0, -1
    []
  end

  # @return [Boolean] true, if member is included
  def include?(member)
    !!conn.zscore(key, member)
  end
  alias_method :member?, :include?

  # @return [Boolean] true, if empty
  def empty?
    length.zero?
  end

  # Returns a slice of members between index +range+, with the lower index returned first
  # @param [Range] range
  #   The index range of the elements
  # @param [Hash] options
  # @option [Boolean] with_scores
  #   Return with scores, defaults to true
  # @return [Array] the members
  def slice(range, options = {})
    start, finish = range_pair(range)
    fetch_range :zrange, start, finish, options
  end
  alias_method :top, :slice

  # Returns a slice of members between rindex +range+, with the higher index returned first
  # @param [Range] range
  #   The rindex range of the elements
  # @param [Hash] options
  # @option [Boolean] with_scores
  #   Return with scores, defaults to true
  # @return [Array] the members
  def rslice(range, options = {})
    start, finish = range_pair(range)
    fetch_range :zrevrange, start, finish, options
  end
  alias_method :bottom, :rslice

  # Selects members between a score +range+. Lower scores returned first
  # @param [Range] range
  #   The score range of the elements
  # @param [Hash] options
  # @option [Boolean] with_scores
  #   Return with scores, defaults to true
  # @option [Integer] limit
  #   Limit the results
  # @return [Array] the members
  def select(range, options = {})
    start, finish = range_pair(range)
    fetch_range :zrangebyscore, start, finish, options
  end

  # Selects members between a score +range+. Higher scores returned first
  # @param [Range] range
  #   The score range of the elements
  # @param [Hash] options
  # @option [Boolean] with_scores
  #   Return with scores, defaults to true
  # @option [Integer] limit
  #   Limit the results
  # @return [Array] the members
  def rselect(range, options = {})
    start, finish = range_pair(range)
    fetch_range :zrevrangebyscore, finish, start, options
  end

  # Comparator
  # @return [Boolean] true if contains same members as other
  def ==(other)
    other.respond_to?(:to_a) && other.to_a == to_a
  end

  # @param [Integer] index
  # @return [String] member for given `index`.
  def at(index)
    slice(index..index, :with_scores => false).first
  end

  # @return [String] member with the lowest index
  def first(count = 0)
    count > 0 ? slice(0..(count-1), :with_scores => false).to_a : at(0)
  end

  # @return [String] member with the highest index
  def last(count = 0)
    count > 0 ? slice(-count..-1, :with_scores => false).to_a : at(-1)
  end

  # Store the result of a union in a new +target+ key
  # @param [Redpear::Store::Set] other
  #   The other set
  # @param [multiple] others
  #   The other sets
  # @param [Hash] options
  # @option [Array] weights
  # @option [Symbol] aggregate
  # @return [Redpear::Store::Set] the result set
  def unionstore(target, *others)
    opts = others.last.is_a?(Hash) ? others.pop : {}
    conn.zunionstore target.to_s, [key] + others.map(&:to_s), opts
    self.class.new target.to_s, conn
  end

  # Store the result of an intersection in a new +target+ key
  # @param [String] target
  #   The target key
  # @param [multiple] others
  #   The other sets
  # @param [Hash] options
  # @option [Array] weights
  # @option [Symbol] aggregate
  # @return [Redpear::Store::SortedSet] the result set
  def interstore(target, *others)
    opts = others.last.is_a?(Hash) ? others.pop : {}
    conn.zinterstore target.to_s, [key] + others.map(&:to_s), opts
    self.class.new target.to_s, conn
  end

  # @param [String] member
  #   The member to increment
  # @param [Integer] by
  #   The increment, defaults to 1
  def increment(member, by = 1)
    conn.zincrby(key, by, member).to_i
  end

  # @param [String] member
  #   The member to decrement
  # @param [Integer] by
  #   The decrement, defaults to 1
  def decrement(member, by = 1)
    increment member, -by
  end

  private

    def fetch_range(method, start, finish, options = {})
      options[:limit]       = [options[:offset] || 0, options[:limit]] if options[:offset] || options[:limit]
      options[:with_scores] = true unless options.key?(:with_scores)
      result = conn.send method, key, start, finish, options
      options[:with_scores] ? result.each_slice(2).map {|m,s| [m, s.to_i] } : result
    end

end