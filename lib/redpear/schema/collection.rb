# Stores the column information
class Redpear::Schema::Collection < Array

  # @param [multiple] the column definition. Please see Redpear::Column#initialize
  def store(klass, *args)
    reset!
    klass.new(*args).tap do |col|
      self << col
    end
  end

  # @return [Array] the names of the columns
  def names
    @names ||= lookup.keys
  end

  # @return [Array] the names of the indices only
  def indices
    @indices ||= select(&:index?)
  end

  # @return [Hash] the column lookup, indexed by name
  def lookup
    @lookup ||= inject({}) {|r, c| r.update c.to_s => c }
  end

  # @param [String] the column name
  # @return [Boolean] if name is part of the collection
  def include?(name)
    lookup.key?(name.to_s)
  end

  # @param [String] the column name
  # @return [Redpear::Column] the column for the given name
  def [](name)
    lookup[name.to_s]
  end

  # Resets indexes and lookups
  def reset!
    instance_variables.each do |name|
      instance_variable_set name, nil
    end
  end

end
