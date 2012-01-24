require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'redpear'
require 'fakeredis'


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
