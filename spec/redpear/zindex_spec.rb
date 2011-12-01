require 'spec_helper'

describe Redpear::ZIndex do

  subject do
    described_class.new Comment, :post_id
  end

  it { should be_a(Redpear::Index) }

  it 'should return members for a value' do
    subject.members(123).should be_a(Redpear::Members)
    subject.members(123).should == []
    subject.nest(123).zadd 1, "A"
    subject.members(123).should == ["A"]
  end

end