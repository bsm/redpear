require 'spec_helper'

describe Redpear::Connect do

  before do
    Post.master_connection = nil
    Post.slave_connection = nil
  end

  after do
    Post.master_connection = nil
    Post.slave_connection = nil
  end

  it 'should have a default master connection' do
    Post.master_connection.should be_instance_of(Redis)
    Post.master_connection.should == Redis.current
    Post.connection.should be(Post.master_connection)
  end

  it 'should have no default slave connection' do
    Post.slave_connection.should be_nil
  end

  describe "master" do

    it 'should be inheritable' do
      Post.master_connection.should be(Redpear::Model.master_connection)
      Post.master_connection.should be(Comment.master_connection)
    end

    it 'should be overridable' do
      Post.master_connection = Redis.new
      Post.master_connection.should_not be(Redpear::Model.master_connection)
    end

  end
end
