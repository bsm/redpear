# Stores the column information
class Redpear::Schema::Collection < Array

  # @param [Class] klass
  # @param [multiple] args the column definition.
  # @see Redpear::Schema::Column#initialize
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

  # @return [Hash] the column lookup, indexed by name
  def lookup
    @lookup ||= inject({}) {|r, c| r.update c.to_s => c }
  end

  # @return [Array] only the index columns
  def indicies
    @indicies ||= to_a.select {|i| i.is_a?(Redpear::Schema::Index) }
  end

  # @param [String] name the column name
  # @return [Boolean] if name is part of the collection
  def include?(name)
    lookup.key?(name.to_s)
  end

  # @param [String] name the column name
  # @return [Redpear::Schema::Column] the column for the given name
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
