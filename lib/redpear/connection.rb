module Redpear::Connection
  extend Redpear::Concern

  module ClassMethods

    def connection
      @connection ||= (superclass.respond_to?(:connection) ? superclass.connection : Redis.new)
    end

    def connection=(value)
      @connection = value
    end

  end
end