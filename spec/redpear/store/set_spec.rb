require 'spec_helper'

describe Redpear::Store::Set do

  subject do
    described_class.new "skey", connection
  end

  let :other do
    described_class.new 'other', connection
  end

  it { should be_a(Redpear::Store::Enumerable) }

  it 'should return all members' do
    subject.members.should == []
    subject.all.should == Set.new

    subject.add('a')
    subject.to_set.should == ['a'].to_set
    subject.to_a.should == ['a']
  end

  it 'should return the length' do
    subject.length.should == 0
    subject.add('a')
    subject.length.should == 1
  end

  it 'should add values' do
    subject.length.should == 0
    subject.add('a')
    subject.add('b')
    subject.length.should == 2
  end

  it 'should delete values' do
    subject.add('a')
    subject.length.should == 1
    subject.delete('a')
    subject.length.should == 0
  end

  it 'should clear all values' do
    subject.add('a')
    subject.length.should == 1
    subject.clear.should == []
    subject.length.should == 0
  end

  it 'should check if empty' do
    subject.should be_empty
    subject.add('a')
    subject.should_not be_empty
  end

  it 'should check if value is included' do
    subject.include?('a').should be(false)
    subject.add('a')
    subject.include?('a').should be(true)
  end

  it 'should pop random values' do
    subject.pop.should be_nil
    subject.add('a')
    subject.pop.should == 'a'
    subject.should be_empty
  end

  it 'should be comparable' do
    subject << 'a' << 'b' << 'c'
    subject.should == ['a', 'b', 'c']
    subject.should == ['a', 'b', 'c'].to_set
  end

  it 'should return random members' do
    subject.random.should be_nil
    subject << 'a'
    subject.random.should == 'a'
    subject.should == ['a']
  end

  it 'should subtract sets' do
    subject << 'a' << 'b'
    other   << 'a' << 'c'
    (subject - other).should == ['b']
    (subject - "other").should == ['b']
  end

  it 'should subtract sets and store results' do
    subject << 'a' << 'b'
    other   << 'a' << 'c'
    result = subject.diffstore('target', other)
    result.should be_a(described_class)
    result.key.should == "target"
    result.should == ['b']
  end

  it 'should union sets' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'd'
    (subject + other).should =~ ['a', 'b', 'c', 'd']
  end

  it 'should build union and store results' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'd'
    result = subject.unionstore('target', other)
    result.should be_a(described_class)
    result.key.should == "target"
    result.should == ['a', 'b', 'c', 'd']
  end

  it 'should build intersections' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'c' << 'd'
    (subject & other).should =~ ['a', 'c']
  end

  it 'should build intersections and store results' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'c' << 'd'
    result = subject.interstore('target', other)
    result.should be_a(described_class)
    result.key.should == "target"
    result.should == ['a', 'c']
  end

  it 'should move members from one set to another' do
    subject.move('other', 'a')
    other.should == []
    subject << 'a' << 'b'
    subject.move('other', 'a')
    other.should == ['a']
    subject.should == ['b']
  end

end
