require 'benchmark'
require 'rubygems'
require 'redis'

redis  = Redis.new
CYCLES = 1_000
ENTRY  = "redpear:benchmark:hash"
KEYS   = ('a'..'z').to_a

redis.del ENTRY
KEYS.each_with_index do |letter, index|
  redis.hset ENTRY, letter, index
end

read_all  = lambda {|*| redis.mapped_hmget(ENTRY, *KEYS).values }
read_each = lambda {|*| KEYS.map {|k| redis.hget ENTRY, k } }

Benchmark.bmbm(40) do |x|

  x.report "Read all" do
    CYCLES.times &read_all
  end

  x.report "Read individually" do
    CYCLES.times &read_each
  end

end
