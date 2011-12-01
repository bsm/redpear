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

  it "should have members" do
    subject.members.should == ["1", "2"].to_set
  end

  it "should have a count" do
    subject.count.should == 2
  end

  it "should be comparable" do
    subject.should == ["1", "2"]
    subject.should == ["2", "1"]
    subject.should == ["1", "2"].to_set
    subject.should_not == ["1", "3"]
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
    subject.include?(3).should be(false)
    subject.include?(2).should be(true)

    subject.to_a # load
    subject.include?(3).should be(false)
    subject.include?(2).should be(true)
  end

  it "should allow adding items" do
    subject.add(3)
    subject.include?(3).should be(true)

    subject.to_a # load
    subject.add(4)
    subject.include?(4).should be(true)
  end

  it "should allow removing items" do
    subject.remove(2)
    subject.include?(2).should be(false)

    subject.to_a # load
    subject.remove(1)
    subject.include?(1).should be(false)
  end

end