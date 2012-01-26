require 'spec_helper'

describe Redpear::Store::Enumerable do

  subject do
    Redpear::Store::List.new('lkey', connection)
  end

  it { should be_a(Redpear::Store::Base) }
  it { should be_a(::Enumerable) }
  its(:value) { should == [] }

  it 'should have a custom inspect' do
    subject << 'a' << 'b' << 'c'
    subject.inspect.should == %(#<Redpear::Store::List lkey: ["a", "b", "c"]>)
  end

  it 'should have a #delete_all alias' do
    subject << 'a' << 'b' << 'c'
    subject.exists?.should be(true)
    subject.delete_all
    subject.exists?.should be(false)
  end

end
