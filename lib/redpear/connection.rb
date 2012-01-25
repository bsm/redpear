class Redpear::Connection

  MASTER_METHODS = %w|
    append auth
    bgrewriteaof bgsave blpop brpop brpoplpush
    config
    decr decrby del discard
    exec expire expireat
    flushall flushdb getset
    hset hsetnx hincrby hmset hdel
    incr incrby
    linsert lpop lpush lpushx lrem lset ltrim
    mapped_hmset mapped_mset mapped_msetnx
    move mset msetnx multi
    persist pipelined psubscribe punsubscribe quit
    rename renamenx rpop rpoplpush rpush rpushx
    sadd save sdiffstore set setbit
    setex setnx setrange sinterstore
    shutdown smove spop srem subscribe
    sunionstore sync synchronize
    unsubscribe unwatch watch
    zadd zincrby zinterstore zrem
    zremrangebyrank zremrangebyscore zunionstore
  |.freeze

  SLAVE_METHODS = %w|
    dbsize debug get getbit getrange
    echo exists
    hget hmget hexists hlen hkeys hvals hgetall
    info keys lastsave lindex llen lrange
    mapped_hmget mapped_mget mget monitor
    object ping publish randomkey
    scard sdiff select sinter sismember slaveof
    smembers sort srandmember strlen substr sunion
    ttl type
    zcard zcount zrange zrangebyscore zrank
    zrevrange zrevrangebyscore zrevrank zscore
  |.freeze

  attr_reader   :current
  attr_accessor :master, :slave

  # Constructor
  # @param [Redis::Client|Redis::Namespace|ConnectionPool] master
  #   The master connection, optional, defaults to the current connection
  # @param [Redis::Client|Redis::Namespace|ConnectionPool] slave
  #   The slave connection, optional, defaults to master
  def initialize(master = Redis.current, slave = nil)
    @master = master
    @slave  = slave || master
  end

  # @param [Symbol] name
  #   Either :master or :slave
  # @yield
  #   Perform a block with the given connection
  def on(name)
    @current = send(name)
    yield
  ensure
    @current = nil
  end

  MASTER_METHODS.each do |meth|
    define_method(meth) do |*a, &b|
      (current || master).send(meth, *a, &b)
    end
  end

  SLAVE_METHODS.each do |meth|
    define_method(meth) do |*a, &b|
      (current || slave).send(meth, *a, &b)
    end
  end

end
