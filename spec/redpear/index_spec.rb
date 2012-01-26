require 'spec_helper'

describe Redpear::Index do

  subject do
    described_class.new Comment, :post_id
  end

  it { should be_a(Redpear::Column) }
  it { should be_index }

  it 'should return members for a value' do
    subject.members(123).key.should == "comments:[post_id]:123"
    subject.members(123).should be_instance_of(Redpear::Store::Set)
    subject.members(123).should == []
    subject.members(123).add 1
    subject.members(123).should == ["1"]
    subject.members(nil).should == []
  end

end