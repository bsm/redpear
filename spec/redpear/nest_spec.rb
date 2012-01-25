require 'spec_helper'

describe Redpear::Nest do

  subject do
    described_class.new "random", connection
  end

  it { should be_a(::String) }
  it { should respond_to(:get) }
  it { should respond_to(:set) }
  it { should respond_to(:hgetall) }
  it { should respond_to(:mapped_hmset) }

  it "should create sub nests" do
    subject["sub"].should be_a(described_class)
    subject["sub"].should == "random:sub"
    subject["sub", "subsub"].should == "random:sub:subsub"
  end

  it "should have connection" do
    subject.connection.should == connection
  end

  it "should delegate correctly" do
    subject.multi do
      subject.hset "a", "1"
      subject.hset "b", "2"
    end
    subject.hgetall.should == { "a" => "1", "b" => "2" }
  end

end
