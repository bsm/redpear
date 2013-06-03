module Redpear::Store
end

%w|base value counter enumerable hash list lock set sorted_set|.each do |name|
  require "redpear/store/#{name}"
end
