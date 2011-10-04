module Redpear::Expiration

  # Expire this record. Expects either a Time or an Integer period.
  def expire(value)
    return false unless persisted?

    case value
    when Time
      nest.expireat(value.to_i)
    when Integer
      nest.expire(value)
    when String
      value = Kernel::Integer(value) rescue nil
      expire(value)
    else
      false
    end
  end

  # How long does this record have to live?
  def ttl
    nest.ttl if persisted?
  end

end