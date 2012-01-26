# == Redpear::Connection
#
# Abstract connection class, with support for master/slave sharding.
# @see Redpear::Connection#initialize for examples
#
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

  # @return [Symbol] ther current connection, either :master or :slave
  attr_reader   :current
  attr_accessor :master, :slave

  # Constructor, accepts a master connection and an optional slave connection.
  # Connections can be instances of Redis::Client, URL strings, or e.g.
  # ConnectionPool objects. Examples:
  #
  #   # Use current redis client as master and slave
  #   Redpear::Connection.new Redis.current
  #
  #   # Use current redis client as slave and a remote URL as master
  #   Redpear::Connection.new "redis://master.host:6379", Redis.current
  #
  #   # Use a connection pool - https://github.com/mperham/connection_pool
  #   slave_pool = ConnectionPool.new(:size => 5, :timeout => 5) { Redis.connect("redis://slave.host:6379") }
  #   Redpear::Connection.new "redis://master.host:6379", slave_pool
  #
  # @param [Redis::Client|String|ConnectionPool] master
  #   The master connection, defaults to `Redis.current`
  # @param [Redis::Client|String|ConnectionPool] slave
  #   The (optional) slave connection, defaults to master
  def initialize(master = Redis.current, slave = nil)
    @master = _connect(master)
    @slave  = _connect(slave || master)
    @transaction = nil
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

  # Run a transaction, prevents accidental transaction nesting
  def transaction(&block)
    if @transaction
      yield
    else
      begin
        @transaction = true
        multi(&block)
      ensure
        @transaction = nil
      end
    end
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

  private

    def _connect(conn)
      case conn
      when String
        Redis.connect(:url => conn)
      else
        conn
      end
    end

end
