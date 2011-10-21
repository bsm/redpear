$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'benchmark'
require 'ohm'
require 'redpear'
require 'redis/connection/hiredis'

COUNT     = 2000
Ohm.redis = Redis.current
Redpear::Model.connection = Redis.current

class Apple < Ohm::Model
  attribute :name
  attribute :year
  counter   :votes
  index     :year
end

class Pear < Redpear::Model
  column  :name
  column  :votes, :counter
  index   :year
end

def assert_cycles(num, count)
  raise "Assertion failed #{count} <> #{num}!" unless count == num
end

Redis.current.flushall
Benchmark.bm(20) do |x|

  x.report "Create: Ohm" do
    COUNT.times {|i| Apple.create :name => "Gala", :year => 2011, :id => i }
  end

  x.report "Create: Redpear" do
    COUNT.times {|i| Pear.save :name => "Gala", :year => 2011, :id => i }
  end

  x.report "Find all: Ohm" do
    10.times { Apple.all.to_a.size }
  end

  x.report "Find all: Redpear" do
    10.times { Pear.all.to_a.size }
  end

  x.report "Inspect all: Ohm" do
    5.times { Apple.all.map(&:inspect) }
  end

  x.report "Inspect all: Redpear" do
    5.times { Pear.all.map(&:inspect) }
  end

  x.report "Find one: Ohm" do
    4000.times { Apple[rand(COUNT)].inspect }
  end

  x.report "Find one: Redpear" do
    4000.times { Pear.find(rand(COUNT)).inspect }
  end

  apples = Apple.all
  x.report "Destroy: Ohm" do
    assert_cycles COUNT, apples.each(&:delete).size
  end

  pears  = Pear.all
  x.report "Destroy: Redpear" do
    assert_cycles COUNT, pears.each(&:destroy).size
  end

end
