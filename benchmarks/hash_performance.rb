require 'tach'

Tach.meter(5_000_000) do |x|

  a = {}
  x.tach "Assign single" do
    a["a"] = 1
  end

  b = {}
  x.tach "Update new" do
    b.update "a" => 1
  end

  c, h = {}, { "a" => 1 }
  x.tach "Update predefined" do
    c.update h
  end

end
