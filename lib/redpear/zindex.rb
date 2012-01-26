class Redpear::ZIndex < Redpear::Index

  attr_reader :callback

  # Creates a new ZIndex.
  # @param [Redpear::Model] model
  #   the model the column is associated with
  # @param [String] name
  #   the column name
  # @param [Symbol] callback
  #   method to be call on the object, to determine the score
  # @param [Symbol] type
  #   the column type (:string (default), :counter, :integer, :float, :timestamp)
  def initialize(model, name, callback, type = nil)
    super(model, name, type)
    @callback = callback
  end

  # @param [String] value
  #   the index value
  # @return [Redpear::SortedMembers] the IDs of all existing records for a given index value
  def members(value)
    Redpear::Store::SortedSet.new [model.scope, "[#{to_s}]", value].join(':'), model.connection
  end

end
