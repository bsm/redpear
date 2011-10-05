$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'benchmark'
require 'ohm'
require 'redpear'

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
    1000.times { Apple.create :name => "Gala", :year => 2011 }
  end

  x.report "Create: Redpear" do
    1000.times { Pear.save :name => "Gala", :year => 2011 }
  end

  x.report "Find all: Ohm" do
    20.times { Apple.all.to_a.size }
  end

  x.report "Find all: Redpear" do
    20.times { Pear.all.to_a.size }
  end

  x.report "Inspect all: Ohm" do
    10.times { Apple.all.map(&:inspect) }
  end

  x.report "Inspect all: Redpear" do
    10.times { Pear.all.map(&:inspect) }
  end

  x.report "Find one: Ohm" do
    one_id = Apple.all.key.smembers.first
    1000.times { Apple[one_id].inspect }
  end

  x.report "Find one: Redpear" do
    one_id = Pear.members.first
    1000.times { Pear.find(one_id).inspect }
  end

  x.report "Destroy: Ohm" do
    assert_cycles 1000, Apple.all.each(&:delete).size
  end

  x.report "Destroy: Redpear" do
    assert_cycles 1000, Pear.all.each(&:destroy).size
  end

end
