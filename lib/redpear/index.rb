class Redpear::Index < Redpear::Column

  # @param [String] value the index value
  # @return [Array] the IDs of all existing records for a given index value
  def members(value)
    Redpear::Store::Set.new [model.scope, "[#{to_s}]", value].join(':'), model.connection
  end

end
