require 'spec_helper'

describe Redpear::Counters do

  let :new_instance do
    Post.new :votes => 6
  end

  subject do
    new_instance.save
    new_instance
  end

  it 'should not be permitted on non-persisted records' do
    new_instance.increment!(:votes).should be(false)
    new_instance.decrement!(:votes).should be(false)
  end

  it 'should not allow modifying non-counters' do
    new_instance.increment!(:created_at).should be(false)
    new_instance.decrement!(:created_at).should be(false)
  end

  it 'should allow to increment' do
    subject.increment!(:votes).should == 7
    subject.increment!(:votes, 3).should == 10
  end

  it 'should allow to decrement' do
    subject.decrement!(:votes).should == 5
    subject.decrement!(:votes, 2).should == 3
  end

end