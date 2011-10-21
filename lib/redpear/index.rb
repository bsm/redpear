class Redpear::Index < Redpear::Column

  # @return [Redpear::Nest] the namespace of the index. Example:
  #
  #   index = Comment.columns.lookup["post_id"]
  #   index.namespace # => "comments:post_id"
  #
  def namespace
    model.namespace[self]
  end

  # @return [Redpear::Nest] the nest for a specific value. Example:
  #
  #   index = Comment.columns.lookup["post_id"]
  #   index.nest(123) # => "comments:post_id:123"
  #   index.nest(nil) # => nil
  #   index.nest("")  # => nil
  #
  def nest(value)
    return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)
    namespace[value]
  end

end
