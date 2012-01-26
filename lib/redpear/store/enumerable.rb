class Redpear::Store::Enumerable < Redpear::Store::Base
  include ::Enumerable

  # Returns the array as the record's value
  # @see Redpear::Store::Base#value
  alias_method :value, :to_a

  # Deletes the whole records
  # @see Redpear::Store::Base#purge!
  alias_method :delete_all, :purge!

end