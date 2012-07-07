require 'spec_helper'

describe Redpear::Store::Counter do

  subject do
    described_class.new "counter:key", connection
  end

  it { should be_a(Redpear::Store::Value) }

  it 'should read and write methods as integers' do
    subject.get.should == 0
    subject.value.should == 0
    subject.set 5
    subject.get.should == 5
    subject.set "5"
    subject.get.should == 5
    subject.value = "1"
    subject.get.should == 1
    lambda { subject.value = "abc" }.should raise_error(ArgumentError)
  end

  it 'should increment values' do
    subject.increment.should == 1
    subject.increment(5).should == 6
    subject.should == 6
  end

  it 'should decrement values' do
    subject.set 6
    subject.decrement.should == 5
    subject.decrement(2).should == 3
    subject.should == 3
  end

  it 'should be pipelineable' do
    connection.pipelined do
      subject.get
      subject.set 6
      subject.get
      subject.increment
      subject.decrement(2)
    end.should == [0, "OK", 6, 7, 5]
  end

end
