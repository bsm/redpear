require 'spec_helper'

describe Redpear::Schema::Score do

  subject do
    described_class.new Comment, :rank
  end

  it { should be_a(Redpear::Schema::Index) }

  it 'should return members store for a record' do
    subject.for(nil).should be_instance_of(Redpear::Store::SortedSet)
    subject.for("ignored").key.should == "comments:+:rank"
  end

  it 'should return members store' do
    subject.members.key.should == "comments:+:rank"
    subject.members.should be_instance_of(Redpear::Store::SortedSet)
    subject.members.should be_empty
  end

end