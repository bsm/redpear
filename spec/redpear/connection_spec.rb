require 'spec_helper'

describe Redpear::Connection do

  before do
    Post.connection = nil
  end

  after do
    Post.connection = nil
  end

  it 'should have a default connection' do
    Post.connection.should be_instance_of(Redis)
  end

  it 'should be inheritable' do
    Post.connection.should be(Redpear::Model.connection)
    Post.connection.should be(Comment.connection)
  end

  it 'should be overridable' do
    Post.connection = Redis.new
    Post.connection.should_not be(Redpear::Model.connection)
  end

end