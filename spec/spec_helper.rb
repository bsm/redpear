require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'redpear'

count = Redis.current.keys.size
unless count.zero?
  STDERR.puts
  STDERR.puts " ! -----> WARNING! <-----"
  STDERR.puts " ! Your Redis (test) database at #{Redis.current.id} contains #{count} keys."
  STDERR.puts " ! Running specs would wipe your database and result in potentail data loss."
  STDERR.puts " ! Please specify a REDIS_URL environment variable to point to another, empty instance."
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

class Post < Redpear::Model
  column :title
  column :body
  column :votes, :counter
  column :created_at, :timestamp
  zindex :user_id, :votes
end

class Comment < Redpear::Model
  column  :content
  index   :post_id
end

class User < Redpear::Model
  column :name
end

class ManagerConnection < Redpear::Connection
end

class Employee < User
end

class Manager < Employee
  self.connection = ManagerConnection.new
end
