module Redpear::Connection
  extend Redpear::Concern

  module ClassMethods

    # @return [Redis] the current master connection
    def master_connection
      @master_connection ||= (superclass.respond_to?(:master_connection) ? superclass.master_connection : Redis.current)
    end
    alias_method :connection, :master_connection

    # @param [Redis] the master connection to assign
    def master_connection=(value)
      @master_connection = value
    end

    # @return [Redis] the current slave connection
    def slave_connection
      @slave_connection
    end

    # @param [Redis] the slave connection to assign
    def slave_connection=(value)
      @slave_connection = value
    end

  end
end
