require 'spec_helper'

describe Redpear::Members do

  let :nest do
    n = Redpear::Nest.new "random", connection
    n.sadd 1
    n.sadd 2
    n
  end

  subject do
    described_class.new(nest)
  end

  it 'should deal with non existing nests' do
    s = described_class.new(nil)
    s.exists?(1).should be(false)
    s.to_a.should == []
  end

  it "should have members" do
    subject.members.should == ["1", "2"].to_set
  end

  it "should have a count" do
    subject.count.should == 2
  end

  it "should be comparable" do
    subject.sort.should == ["1", "2"]
    subject.sort.should_not == ["2", "1"]
  end

  it "should behave like an enumerable" do
    subject.to_a.should =~ ["1", "2"]
    subject.map {|i| i.to_i ** 3 }.should =~ [1, 8]
    subject.sort.join.should == "12"
  end

  it "should have a loaded? indicator" do
    subject.should_not be_loaded
    subject.members
    subject.should be_loaded
  end

  it "should check if record exists" do
    subject.exists?(3).should be(false)
    subject.exists?(2).should be(true)

    subject.to_a # load
    subject.exists?(3).should be(false)
    subject.exists?(2).should be(true)
  end

end