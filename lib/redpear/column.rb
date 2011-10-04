class Redpear::Column < String
  attr_reader :type, :model

  def initialize(model, value, type = nil)
    super value.to_s
    @model = model
    @type  = type.to_sym if type
  end

  def type_cast(value, type = self.type)
    case type
    when :counter
      value.to_i
    when :integer
      Kernel::Integer(value) rescue nil if value
    when :timestamp
      value = type_cast(value, :integer)
      Time.at(value) if value
    else
      value
    end
  end

  def name
    to_s
  end

  def readable?
    true
  end

  def writable?
    type != :counter
  end

  def index?
    is_a? Redpear::Index
  end

end
