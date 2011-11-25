require 'spec_helper'

describe Redpear::Index do

  subject do
    described_class.new Comment, :post_id
  end

  it { should be_a(Redpear::Column) }
  it { should be_index }

  it 'should have a namespace' do
    subject.namespace.should == "comments:[post_id]"
  end

  it 'should build nests by values' do
    subject.nest(nil).should be_nil
    subject.nest("").should be_nil
    subject.nest(123).should == "comments:[post_id]:123"
  end

  it 'should return members for a value' do
    subject.members(nil).should == []
    subject.members(123).should == []
    subject.nest(123).sadd 1
    subject.members(123).should == ["1"]
    subject.members(123).should be_a(Redpear::Set)
  end

end