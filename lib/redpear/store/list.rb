class Redpear::Store::List < Redpear::Store::Enumerable

  # @yield over each item in the list
  # @yieldparam [String] item
  def each(&block)
    all.each(&block)
  end

  # @return [Array] all items
  def all
    slice(0..-1)
  end
  alias_method :to_a, :all

  # Returns a slice of the list
  # @overload slice(index)
  #   Returns the item at `index`
  #   @param [Integer] index
  #   @return [String] item
  # @overload slice(start, length)
  #   Returns from `length` items from `start`
  #   @param [Integer] start
  #   @param [Integer] length
  #   @return [Array] items
  # @overload slice(range)
  #   Returns items from range
  #   @param [Range] range
  #   @return [Array] items
  def slice(start, length = nil)
    case start
    when Integer
      if length
        range(start, start + length - 1)
      else
        conn.lindex(key, start) rescue nil
      end
    when Range
      range *range_pair(start)
    else
      []
    end
  end
  alias_method :[], :slice

  # Destructive slice. Returns specified range and removes other items.
  # @overload slice(start, length)
  def slice!(start, length = nil)
    case start
    when Range
      trim *range_pair(start)
    else
      trim(start, start + length - 1)
    end
    to_a
  end

  # @param [Integer] start
  # @param [Integer] finish
  # @return [Array] items
  def range(start, finish)
    conn.lrange(key, start, finish) || []
  end

  # @param [Integer] start
  # @param [Integer] finish
  def trim(start, finish)
    conn.ltrim(key, start, finish)
  end

  # @return [Integer] the number of items in the set
  def length
    conn.llen key
  end
  alias_method :size, :length

  # Appends a single item. Chainable example:
  #   list << 'a' << 'b'
  # @param [String] item
  #   A item to add
  def push(item)
    conn.rpush key, item
    self
  end
  alias_method :<<, :push

  # Removes the last item
  # @return [String] the removed item
  def pop
    conn.rpop key
  end

  # Prepends a single item.
  # @param [String] item
  #   A item to add
  def unshift(item)
    conn.lpush key, item
    self
  end

  # Removes the first item
  # @return [String] the removed item
  def shift
    conn.lpop key
  end

  # Removes the last item and prepends it to `target`
  # @param [Redpear::Store::List] target
  def pop_unshift(target)
    conn.rpoplpush key, target.to_s
  end

  # Comparator
  # @param [#to_a] other
  # @return [Boolean] true if items match
  def ==(other)
    other.respond_to?(:to_a) && other.to_a == to_a
  end

  # Remove `item` from list
  # @param [String] item
  # @param [Integer] count
  #   The number of items to remove.
  #   When =0 - remove all occurences
  #   When >0 - remove the first `count` items
  #   When <0 - remove the last `count` items
  def delete(item, count = 0)
    conn.lrem key, count, item
  end

  # Insert `item` before `pivot`
  # @param [String] pivot
  # @param [String] item
  def insert_before(pivot, item)
    conn.linsert key, :before, pivot, item
  end

  # Insert `item` after `pivot`
  # @param [String] pivot
  # @param [String] item
  def insert_after(pivot, item)
    conn.linsert key, :after, pivot, item
  end

end