class Redpear::Store::Base

  attr_reader :key, :conn

  # Constructor
  # @param [String] key
  #   The storage key
  # @param [Redpear::Connection] conn
  #   The connection
  def initialize(key, conn)
    @key, @conn = key, conn
  end

  alias to_s key

end