class Redpear::Index < Redpear::Column

  # @return [Redpear::Nest] the namespace of the index. Example:
  #
  #   index = Comment.columns.lookup["post_id"]
  #   index.namespace # => "comments:[post_id]"
  #
  def namespace
    model.namespace["[#{to_s}]"]
  end

  # @param [String] value the index value
  # @return [Redpear::Nest] the nest for a specific value. Example:
  #
  #   index = Comment.columns.lookup["post_id"]
  #   index.nest(123) # => "comments:[post_id]:123"
  #   index.nest(nil) # => nil
  #   index.nest("")  # => nil
  #
  def nest(value)
    return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)
    namespace[value]
  end

  # @param [String] value the index value
  # @return [Array] the IDs of all existing records for a given index value
  def members(value)
    Redpear::Set.new nest(value)
  end

end
