require 'spec_helper'

describe Redpear::Store::Enumerable do

  subject do
    Redpear::Store::List.new('enum:key', connection)
  end

  it { should be_a(Redpear::Store::Base) }
  it { should be_a(::Enumerable) }
  its(:value) { should == [] }

  it 'should have a custom inspect' do
    subject << 'a' << 'b' << 'c'
    subject.inspect.should == %(#<Redpear::Store::List enum:key: ["a", "b", "c"]>)
  end

  it 'should have a #clear alias' do
    subject << 'a' << 'b' << 'c'
    subject.clear.should == []
    subject.exists?.should be(false)
  end

end
