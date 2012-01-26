require 'spec_helper'

describe Redpear::Store::Value do

  subject do
    described_class.new "vkey", connection
  end

  it { should be_a(Redpear::Store::Base) }

  it 'should have a custom inspect' do
    subject.inspect.should == "#<Redpear::Store::Value vkey: nil>"
    subject.value = "abcd"
    subject.inspect.should == %(#<Redpear::Store::Value vkey: "abcd">)
  end

  it 'should delete values' do
    subject.exists?.should be(false)
    subject.value = "abcd"
    subject.exists?.should be(true)
    subject.delete
    subject.exists?.should be(false)
  end

  pending
end
