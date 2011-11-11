module Redpear::Counters

  # Increments the value of a counter attribute
  # @param [String|Symbol] column
  #   The column name to increment
  # @param [Integer] by
  #   Increment by this value
  def increment!(column, by = 1)
    return false unless persisted?

    col = self.class.columns[column]
    return false unless col && col.type == :counter

    self[col.name] = nest.hincrby(col.name, by).to_i
  end

  # Decrements the value of a counter attribute
  # @param [String|Symbol] column
  #   The column name to decrement
  # @param [Integer] by
  #   Decrement by this value
  def decrement!(column, by = 1)
    increment!(column, -by)
  end

end