class Redpear::Store::Enumerable < Redpear::Store::Base
  include ::Enumerable
  alias_method :value, :to_a
end