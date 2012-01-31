class Redpear::Schema::Score < Redpear::Schema::Index

  # @return [Redpear::Store::Set] the set holding the IDs for `record's` index
  def for(*)
    members
  end

  # @return [Redpear::Store::SortedSet] the sorted set holding the pairs
  def members(*)
    @members ||= Redpear::Store::SortedSet.new nested_key(name), model.connection
  end

end
