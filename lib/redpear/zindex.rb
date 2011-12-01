class Redpear::ZIndex < Redpear::Index

  # @param [String] value the index value
  # @return [Redpear::SortedMembers] the IDs of all existing records for a given index value
  def members(value)
    Redpear::ZMembers.new nest(value)
  end

end
