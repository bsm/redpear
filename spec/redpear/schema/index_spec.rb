require 'spec_helper'

describe Redpear::Schema::Index do

  subject do
    described_class.new Comment, :post_id
  end

  it { should be_a(Redpear::Schema::Column) }

  it 'should return members store for a record' do
    comment = Comment.new :post_id => 100
    subject.for(comment).should be_instance_of(Redpear::Store::Set)
    subject.for(comment).key.should == "comments:+:post_id:100"
  end

  it 'should return members store for a value' do
    subject.members(200).key.should == "comments:+:post_id:200"
    subject.members(200).should be_instance_of(Redpear::Store::Set)
    subject.members(200).should == []
    subject.members(200).add 1
    subject.members(200).should == ["1"]
    subject.members(nil).should == []
  end

end