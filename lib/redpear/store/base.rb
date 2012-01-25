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

  private

    def range_pair(range)
      first = range.first.to_i
      last  = range.last.to_i
      last -= 1 if range.exclude_end?
      [first, last]
    end

end