require 'spec_helper'

describe Redpear::ZIndex do

  subject do
    described_class.new Post, :user_id, :votes
  end

  it { should be_a(Redpear::Index) }

  it 'should have a score method' do
    subject.callback.should == :votes
  end

  it 'should return members for a value' do
    subject.members(123).key.should == "posts:[user_id]:123"
    subject.members(123).should be_instance_of(Redpear::Store::SortedSet)
    subject.members(123).should == []
    subject.members(123).add "A", 1
    subject.members(123).should == [["A", 1]]
  end

end
