module Redpear::Connection
  extend Redpear::Concern

  module ClassMethods

    # @return [Redis] the current connection
    def connection
      @connection ||= (superclass.respond_to?(:connection) ? superclass.connection : Redis.current)
    end

    # @param [Redis] the connection to assign
    def connection=(value)
      @connection = value
    end

  end
end