# Nested redis key-value store, with master slave support
# Heavily "inspired" by the nest library
# Original copyright: Michel Martens & Damian Janowski
class Redpear::Nest < ::String
 
  MASTER_METHODS = %w|
    auth bgrewriteaof bgsave blpop brpop
    decr decrby del
    expire expireat
    flushall flushdb getset
    hset hsetnx hincrby hmset hdel
    incr incrby
    lpop lpush lrem lset ltrim
    mapped_hmset move mset msetnx
    psubscribe punsubscribe quit 
    rename renamenx rpop rpoplpush rpush
    sadd save sdiffstore set setex setnx sinterstore
    shutdown smove spop srem subscribe sunionstore
    unsubscribe
    zadd zincrby zrem zremrangebyrank zremrangebyscore
  |.freeze

  SLAVE_METHODS = %w|
    dbsize debug exists get
    hget hmget hexists hlen hkeys hvals hgetall
    info keys lastsave lindex llen lrange
    mapped_mget mget monitor
    publish randomkey
    scard sdiff select sinter sismember slaveof
    smembers sort srandmember sunion
    ttl type
    zcard zcount zrange zrangebyscore zrank
    zrevrange zrevrank zscore
  |.freeze
  
  attr_reader :master, :slave, :current
  
  # Constructor  
  # @param [String] key
  #   The redis key
  # @param [Redis::Client|Redis::Namespace|ConnectionPool] master
  #   The master connection, optional, defaults to the current connection
  # @param [Redis::Client|Redis::Namespace|ConnectionPool] slave
  #   The slave connection, optional, defaults to master
  def initialize(key, master = Redis.current, slave = nil)
    super(key)
    @master = master
    @slave  = slave || master
  end

  # @param [multiple] keys
  #   Nest within these keys
  # @return [Redpear::Nest]
  #   The nested key
  def [](*keys)
    self.class.new [self, *keys].join(':'), master, slave
  end

  # @param [Symbol] name
  #   Either :master or :slave
  # @yield
  #   Perform a block with the given connection
  def with_connection(name)
    @current = send(name)
    yield
  ensure
    @current = nil
  end
  alias_method :with, :with_connection
  
  MASTER_METHODS.each do |meth|
    define_method(meth) do |*args, &block|
      (current || master).send(meth, self, *args, &block)
    end
  end

  SLAVE_METHODS.each do |meth|
    define_method(meth) do |*args, &block|
      (current || slave).send(meth, self, *args, &block)
    end
  end
  
end
