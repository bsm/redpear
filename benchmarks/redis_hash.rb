require 'tach'
require 'redis'

redis  = Redis.current
ENTRY  = "redpear:benchmark:hash"
KEYS   = ('a'..'z').to_a

redis.del ENTRY
KEYS.each_with_index do |letter, index|
  redis.hset ENTRY, letter, index
end

Tach.meter(5_000) do |x|

  x.tach "Read all" do
    redis.hgetall(ENTRY)
  end

  x.tach "Read keys" do
    redis.hkeys(ENTRY)
  end

  x.tach "Read values" do
    redis.hvals(ENTRY)
  end

  x.tach "Read mapped" do
    redis.mapped_hmget(ENTRY, *KEYS)
  end

  one = KEYS.first
  x.tach "Read one" do
    redis.hget(ENTRY, one)
  end

  few = KEYS.first(5)
  x.tach "Read few" do
    redis.hmget(ENTRY, *few)
  end

  some = KEYS.first(10)
  x.tach "Read some" do
    redis.hmget(ENTRY, *some)
  end

  many = KEYS.first(20)
  x.tach "Read many" do
    redis.hmget(ENTRY, *many)
  end

end
