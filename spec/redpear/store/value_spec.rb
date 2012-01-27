require 'spec_helper'

describe Redpear::Store::Value do

  subject do
    described_class.new "value:key", connection
  end

  it { should be_a(Redpear::Store::Base) }

  it 'should have a custom inspect' do
    subject.inspect.should == "#<Redpear::Store::Value value:key: nil>"
    subject.value = "abcd"
    subject.inspect.should == %(#<Redpear::Store::Value value:key: "abcd">)
  end

  it 'should delete values' do
    subject.exists?.should be(false)
    subject.value = "abcd"
    subject.exists?.should be(true)
    subject.delete
    subject.exists?.should be(false)
  end

  it 'should read values' do
    subject.get.should be_nil
    subject.value = "abcd"
    subject.value.should == "abcd"
    subject.get.should == "abcd"
  end

  it 'should write values' do
    subject.value = "abcd"
    subject.should == "abcd"
    subject.set "dcab"
    subject.should == "dcab"
    subject.replace "aaa"
    subject.should == "aaa"
  end

  it 'should append values' do
    subject.value = "abcd"
    subject.append 'e'
    subject << 'f'
    subject.should == "abcdef"
  end

  it 'should be comparable' do
    subject.should == nil
    subject.set "ab"
    subject.should == "ab"
    subject.should_not == "ba"
  end

  it 'should check if nil' do
    subject.should be_nil
    subject.value = "abcd"
    subject.should_not be_nil
  end

  it 'should delegate to the actual value' do
    subject.size.should == 0
    subject.value = "abcd"
    subject.size.should == 4
    subject.reverse.should == "dcba"
  end

end
