require "set"
require "redpear/core_ext/stringify_keys"

class Redpear::Model < Hash
  include Redpear::Connection
  include Redpear::Namespace
  include Redpear::Persistence
  include Redpear::Expiration
  include Redpear::Schema
  include Redpear::Finders

  # Ensure we can read raw level values
  alias_method :_fetch, :[]

  def initialize(attrs = {})
    super()
    @_casted = Set.new
    update(attrs)
  end

  # Every record needs an ID
  def id
    value = _fetch("id")
    value.to_s if value
  end

  # Bulk-update attributes
  def update(attrs)
    super attrs.stringify_keys
  end
  alias_method :load, :update

  # Attribute reader with type-casting
  def [](name)
    name = name.to_s
    return super if @_casted.include?(name)

    @_casted << name
    column = self.class.columns.lookup[name]
    value  = super(name)
    store name, column ? column.type_cast(value) : value
  end

  # Attribute writer
  def []=(name, value)
    name = name.to_s
    @_casted.delete(name)
    super
  end

  # Returns a Hash with attributes
  def to_hash
    {}.update(self)
  end

  # Show information about this record
  def inspect
    "#<#{self.class.name} #{super}>"
  end

end
