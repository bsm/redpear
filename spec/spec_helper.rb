require 'rubygems'
require 'bundler/setup'

require 'rspec'
case ENV['CONN']
when 'hiredis'
  require 'redis/connection/hiredis'
else
  require 'redis/connection/ruby'
end

require 'redpear'
require 'support/models'
require 'support/blueprints'
require 'support/factories'

count = Redis.current.dbsize
unless count.zero?
  STDERR.puts
  STDERR.puts " !! WARNING!"
  STDERR.puts " !! ========"
  STDERR.puts " !!"
  STDERR.puts " !! Your Redis (test) database at #{Redis.current.id} contains #{count} keys."
  STDERR.puts " !! Running specs would wipe your database and result in potentail data loss."
  STDERR.puts " !! Please specify a REDIS_URL environment variable to point to an empty ."
  STDERR.puts
  abort
end

module RSpec::ConnectionHelperMethods

  def connection
    @connection ||= Redpear::Connection.new
  end

end

RSpec.configure do |config|
  config.include RSpec::ConnectionHelperMethods
  config.after do
    connection.flushdb
  end
end
