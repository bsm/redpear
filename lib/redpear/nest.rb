# Nested redis key-value store, with master slave support
# Heavily "inspired" by the nest library
# Original copyright: Michel Martens & Damian Janowski
class Redpear::Nest < ::String

  def self.arity_cache
    @arity_cache ||= {}
  end

  attr_reader :connection

  # Constructor
  # @param [String] key
  #   The redis key
  # @param [Redpear::Connection] connection
  #   The connection
  def initialize(key, connection)
    super(key)
    @connection = connection
  end

  # @param [multiple] keys
  #   Nest within these keys
  # @return [Redpear::Nest]
  #   The nested key
  def [](*keys)
    self.class.new [self, *keys].join(':'), connection
  end

  # @overload delegate to connection
  def respond_to?(sym, *a)
    super || connection.respond_to?(sym, *a)
  end

  protected

    # @overload delegate to connection
    def method_missing(sym, *a, &b)
      if connection.respond_to?(sym)
        call(sym, *a, &b)
      else
        super
      end
    end

  private

    def call(method, *a, &b)
      case self.class.arity_cache[method] ||= Redis.instance_method(method).arity
      when 0
        connection.send(method, &b)
      else
        connection.send(method, self, *a, &b)
      end
    end

end
