require 'benchmark'

CYCLES   = 1_000_000

Benchmark.bmbm do |x|

  x.report "Assign single" do
    h = {}
    CYCLES.times { h["a"] = 1 }
  end

  x.report "Update new" do
    h = {}
    CYCLES.times { h.update "a" => 1 }
  end

  x.report "Update predefined" do
    h, i = {}, { "a" => 1 }
    CYCLES.times { h.update i }
  end

end
