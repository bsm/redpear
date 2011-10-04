class Redpear::Counter < Redpear::Column

  def initialize(model, value)
    super model, value, :counter
  end

end
