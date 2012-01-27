class Redpear::Store::Lock < Redpear::Store::Base
  class LockTimeout < ::StandardError; end
  class UnlockError < ::StandardError; end

  # Creates a lock and yields a transaction. Example:
  #
  #   sender    = Redpear::Store::Hash.new "accounts:sender", connection
  #   recipient = Redpear::Store::Hash.new "accounts:recipient", connection
  #   lock      = Redpear::Store::Lock.new "locks:transfer", connection
  #
  #   lock.lock :timeout => 5, :wait => 5 do
  #     sender.decrement 'balance', 100
  #     recipient.increment 'balance', 100
  #   end
  #
  # @param [Hash] options
  # @option [Integer] timeout
  #   Lock for `timeout` seconds. Defaults to 5.
  # @option [Integer] wait
  #   Wait for up to `wait` seconds to acquire a lock. Defaults to 1.
  # @yield [] processes the block within the lock
  def lock(options = {})
    options = { :timeout => 5, :wait => 1 }.merge(options)
    locked  = false
    result  = nil
    value   = SecureRandom.hex(16)
    expire  = options[:wait].is_a?(Time) ? options[:wait] : Time.now + options[:wait]

    while !locked && expire > Time.now
      if conn.setnx(key, value)
        expire(options[:timeout])
        locked = true
        result = yield
      elsif ttl.nil?
        purge!
      else
        sleep 0.1
      end
    end

    unless locked
      raise LockTimeout, "Could not acquire lock on '#{key}' with '#{value}'. Timed out."
    end

    result
  ensure
    remove(value) if locked && value
  end

  def locked?
    exists? && !!ttl
  end

  private

    def remove(value)
      current = conn.get(key)
      if current == value
        purge!
      else
        raise UnlockError, "Lost lock on '#{key}'. Expected '#{value}' but was '#{current}'"
      end
    end

end