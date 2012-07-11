class Redpear::Store::Lock < Redpear::Store::Base
  class LockTimeout < ::StandardError; end

  class << self

    # Default lock options. Override via e.g.:
    #
    #   Redpear::Store::Lock.default_options[:lock_timeout] = 5
    #
    # @return [Hash] default options
    def default_options
      @default_options ||= { :lock_timeout => 2, :wait_timeout => 2 }
    end

  end

  # @return [Float] the current lock timestamp
  def current
    value.to_f
  end

  # @return [String] the current lock value
  def value
    conn.get key
  end

  # Creates a lock and yields a transaction.
  #
  # @example
  #
  #   sender    = Redpear::Store::Hash.new "accounts:sender", connection
  #   recipient = Redpear::Store::Hash.new "accounts:recipient", connection
  #   lock      = Redpear::Store::Lock.new "locks:transfer", connection
  #
  #   lock.lock do
  #     sender.decrement 'balance', 100
  #     recipient.increment 'balance', 100
  #   end
  #
  # @param [Hash] options
  # @option [Integer] lock_timeout
  #   Hold the lock for a maximum of `lock_timeout` seconds. Defaults to 2.
  # @option [Integer] wait_timeout
  #   Wait for `wait_timeout` seconds to obtain a lock, before timing out. Defaults to 2.
  # @yield [] processes the block within the lock
  # @raise [Redpear::Store::Lock::LockTimeout] timeout error if lock cannot be ontained
  def lock(options = {})
    options   = self.class.default_options.merge(options)
    result    = nil
    timestamp = nil
    timeout   = to_time(options[:wait_timeout])

    while !timestamp && timeout > Time.now
      timestamp = to_time(options[:lock_timeout]).to_f

      if lock_obtained?(timestamp) || expired_lock_obtained?(timestamp)
        result = yield
      else
        timestamp = nil # Unset
        sleep 0.1
      end
    end

    unless timestamp
      raise LockTimeout, "Could not acquire lock on '#{key}'. Timed out."
    end

    result
  ensure
    purge! if timestamp && timestamp > Time.now.to_f
  end

  # Conditional locking. Performs a transaction if lock can be acquired.
  # @param [Hash] options - see #lock
  # @yield [] processes the block within the lock
  # @return [Boolean] true if successful
  def lock?(options = {}, &block)
    lock(options, &block)
    true
  rescue LockTimeout
    false
  end

  protected

    # @param [Float] timestamp
    #   The timestamp to set for the lock
    # @return [Boolean]
    #   True, if timestamp could be set and the lock was obtained
    def lock_obtained?(timestamp)
      conn.setnx key, timestamp
    end

    # @param [Float] timestamp
    #   The timestamp to set for the lock
    # @return [Boolean]
    #   True, if key is set to an expired value and we can replace it
    #   with our `timestamp`
    def expired_lock_obtained?(timestamp)
      exists? && past?(value) && past?(conn.getset(key, timestamp))
    end

    # @return [Boolean] true, if timestamp has expired and is in the past
    def past?(timestamp)
      timestamp = timestamp.to_f if timestamp.is_a?(String)
      timestamp < Time.now.to_f
    end

  private

    def to_time(value)
      case value
      when Time
        value
      when Numeric
        Time.now + value
      else
        Time.now + 5
      end
    end

end