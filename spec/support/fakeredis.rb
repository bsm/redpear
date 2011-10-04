require 'fakeredis'

RSpec.configure do |c|
  c.after { Redpear::Model.connection.flushall }
end
