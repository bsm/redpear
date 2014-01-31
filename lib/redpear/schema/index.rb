class Redpear::Schema::Index < Redpear::Schema::Column

  # @param [Redpear::Model] record the owner record
  # @return [Redpear::Store::Set] the set holding the IDs for `record's` index
  def for(record)
    members record.send(name)
  end

  # @param [String] value index value
  # @return [Redpear::Store::Set] the set holding the IDs for the given `foreign_key`
  def members(value)
    value = '_' if value.nil?
    Redpear::Store::Set.new nested_key(name, value), model.connection
  end

  private

    def nested_key(*tokens)
      model.nested_key(:~, *tokens)
    end

end
