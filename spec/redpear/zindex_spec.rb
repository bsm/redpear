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
    subject.members(123).should be_instance_of(Redpear::ZMembers)
    subject.members(123).should == []
    subject.nest(123).zadd 1, "A"
    subject.members(123).should == ["A"]
  end

end
