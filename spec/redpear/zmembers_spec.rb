require 'spec_helper'

describe Redpear::ZMembers do

  let :nest do
    n = Redpear::Nest.new "random", connection
    n.zadd 10, "A"
    n.zadd 20, "B"
    n
  end

  subject do
    described_class.new nest, :votes
  end

  it "should have members" do
    subject.members.should == ["A", "B"].to_set
  end

  it "should have a count" do
    subject.count.should == 2
  end

  it "should return scores for values" do
    subject.score("C").should be_nil
    subject.score("B").should == 20
  end

  it "should check if record exists" do
    subject.include?("C").should be(false)
    subject.include?("B").should be(true)

    subject.to_a # load
    subject.include?("C").should be(false)
    subject.include?("A").should be(true)
  end

  it "should allow adding items" do
    subject.add(Post.new(:id => "C", :votes => 50))
    subject.include?("C").should be(true)
    subject.score("C").should == 50

    subject.to_a # load
    subject.add(Post.new(:id => "D", :votes => 60))
    subject.include?("D").should be(true)
    subject.score("D").should == 60
  end

  it "should allow removing items" do
    subject.remove(Post.new(:id => "B"))
    subject.include?("B").should be(false)

    subject.to_a # load
    subject.remove(Post.new(:id => "A"))
    subject.include?("A").should be(false)
  end

end