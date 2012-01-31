module Redpear::Model::Expiration

  # Expires the record.
  # @overload expire(time)
  #   @param [Time] time The time to expire the record at
  # @overload expire(number)
  #   @param [Integer] number Expire in `number` of seconds from now
  def expire(value)
    attributes.expire(value)
  end

  # @return [Integer] the period this record has to live.
  # May return nil for non-expiring records and non-existing records.
  def ttl
    attributes.ttl
  end

end