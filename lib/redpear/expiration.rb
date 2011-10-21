module Redpear::Expiration

  # Expires the record.
  # @param [Time, Integer] either a Time or an Integer period (in seconds)
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

  # @return [Integer] the period this record has to live.
  # May return -1 for non-expiring records and nil for non-persisted records.
  def ttl
    nest.ttl if persisted?
  end

end