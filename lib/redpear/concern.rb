module Redpear::Concern

  # Partially borrowed from ActiveSupport
  def append_features(base)
    return false if base < self
    super
    base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
  end

end