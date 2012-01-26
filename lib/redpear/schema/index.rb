class Redpear::Schema::Index < Redpear::Schema::Column

  # @param [Redpear::Model] record the owner record
  # @return [Redpear::Store::Set] the set holding the IDs for `record's` index
  def for(record)
    members record.send(name)
  end

  # @param [String] foreign_key the foreign key
  # @return [Redpear::Store::Set] the set holding the IDs for the given `foreign_key`
  def members(foreign_key)
    Redpear::Store::Set.new model.scoped("+", name, foreign_key), model.connection
  end

end
