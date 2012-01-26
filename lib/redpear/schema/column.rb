class Redpear::Schema::Column < String
  attr_reader :type, :model

  # Creates a new column.
  # @param [Redpear::Model] model
  #   the model the column is associated with
  # @param [String] name
  #   the column name
  # @param [Symbol] type
  #   the column type (:string (default), :counter, :integer, :float, :timestamp)
  def initialize(model, name, type = nil)
    super name.to_s
    @model = model
    @type  = type.to_sym if type
  end

  # Casts a value to a type
  #
  # @param value the value to cast
  # @param [Symbol, #optional] type the type to cast to, defaults to the column type
  # @return the casted value
  def type_cast(value, type = self.type)
    case type
    when :counter
      type_cast(value, :integer).to_i
    when :integer
      Kernel::Integer(value) rescue nil if value
    when :float
      Kernel::Float(value) rescue nil if value
    when :timestamp
      value = type_cast(value, :integer)
      Time.at(value) if value
    else
      value
    end
  end

  # Encodes a value, for storage
  # @return [Object] the encoded value
  def encode_value(value)
    case value
    when Time
      value.to_i
    else
      value
    end
  end

  # @return [String] the column name
  def name
    to_s
  end

  # @return [Boolean] true if the column is readable
  def readable?
    true
  end

  # @return [Boolean] true if the column is writable
  def writable?
    true
  end

end
