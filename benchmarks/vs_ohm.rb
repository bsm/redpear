$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'benchmark'
require 'ohm'
require 'redpear'
# require 'redis/connection/hiredis'

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


=begin

# ruby-1.9.3-rc1  <----------------------------------------
                           user     system      total        real
Create: Ohm            0.980000   0.180000   1.160000 (  1.274330)
Create: Redpear        0.190000   0.050000   0.240000 (  0.243894)
Find all: Ohm          0.900000   0.300000   1.200000 (  1.374696)
Find all: Redpear      0.810000   0.210000   1.020000 (  1.136441)
Inspect all: Ohm       1.650000   0.660000   2.310000 (  2.656132)
Inspect all: Redpear   1.160000   0.290000   1.450000 (  1.639389)
Find one: Ohm          0.730000   0.220000   0.950000 (  1.085908)
Find one: Redpear      0.430000   0.120000   0.550000 (  0.633093)
Destroy: Ohm           0.570000   0.200000   0.770000 (  0.884628)
Destroy: Redpear       0.190000   0.030000   0.220000 (  0.217921)

# ruby-1.9.2-p290 <----------------------------------------
                          user     system      total        real
Create: Ohm           0.880000   0.270000   1.150000 (  1.291655)
Create: Redpear       0.240000   0.010000   0.250000 (  0.254707)
Find all: Ohm         0.930000   0.390000   1.320000 (  1.534709)
Find all: Redpear     0.880000   0.270000   1.150000 (  1.305111)
Inspect all: Ohm      2.010000   0.520000   2.530000 (  2.938412)
Inspect all: Redpear  1.080000   0.240000   1.320000 (  1.511978)
Find one: Ohm         0.520000   0.170000   0.690000 (  0.801703)
Find one: Redpear     0.480000   0.130000   0.610000 (  0.708345)
Destroy: Ohm          0.560000   0.090000   0.650000 (  0.755053)
Destroy: Redpear      0.190000   0.020000   0.210000 (  0.214726)

=end