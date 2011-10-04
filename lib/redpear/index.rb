class Redpear::Index < Redpear::Column

  def namespace
    model.namespace[self]
  end

  def nest(value)
    return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)
    namespace[value]
  end

end
