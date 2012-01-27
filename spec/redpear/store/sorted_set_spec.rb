require 'spec_helper'

describe Redpear::Store::SortedSet do

  subject do
    described_class.new "zset:key", connection
  end

  let :other do
    described_class.new "other", connection
  end

  it { should be_a(Redpear::Store::Enumerable) }

  it 'should return all members' do
    subject.to_a.should  == []
    subject.add('a', 1)
    subject.to_a.should == [['a', 1]]
    subject.to_a(:with_scores => false).should == ['a']
  end

  it 'should yield all each member' do
    subject.add('a', 1)
    yielded = []
    subject.each {|v, s| yielded << [v, s] }
    yielded.should == [['a', 1]]
  end

  it 'should return the length' do
    subject.length.should == 0
    subject.add('a', 1)
    subject.length.should == 1
  end

  it 'should count items within a score range' do
    subject.count(0..5).should be(0)
    subject.add('a', 1)
    subject.add('b', 2)
    subject.add('c', 3)
    subject.count(1..2).should be(2)
    subject.count(1...2).should be(1)
  end

  it 'should add values' do
    subject.length.should == 0
    subject.add('a', 1)
    subject['b'] = 1
    subject.length.should == 2
  end

  it 'should delete values' do
    subject.add('a', 1)
    subject.length.should == 1
    subject.delete('a')
    subject.length.should == 0
  end

  it 'should clear all values' do
    subject.add('a', 1)
    subject.length.should == 1
    subject.clear.should == []
    subject.length.should == 0
  end

  it 'should check if empty' do
    subject.should be_empty
    subject.add('a', 1)
    subject.should_not be_empty
  end

  it 'should check if value is included' do
    subject.include?('a').should be(false)
    subject.add('a', 1)
    subject.include?('a').should be(true)
  end

  it 'should be comparable' do
    subject.add('a', 1)
    subject.add('b', 2)
    subject.should == [['a', 1], ['b', 2]]
    subject.should == { 'a' => 1, 'b' => 2 }
  end

  it 'should return scores for values' do
    subject.add('a', 20)
    subject.add('b', 10)
    subject.score('a').should == 20
    subject['b'].should == 10
    subject['c'].should be_nil
  end

  it 'should return indicies for values' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    subject.index('a').should == 2
    subject.index('c').should == 0
    subject.rindex('a').should == 0
    subject.rindex('c').should == 2
  end

  it 'should return slices' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    subject.top(1..-1).should be_instance_of(Array)
    subject.top(1..-1).to_a.should == [['b', 20], ['a', 30]]
    subject.bottom(1..-1).to_a.should == [['b', 20], ['c', 10]]
  end

  it 'should select values between scores' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    subject.select(5..25).should be_instance_of(Array)
    subject.select(5..25).to_a.should == [['c', 10], ['b', 20]]
    subject.rselect(5..25).to_a.should == [['b', 20], ['c', 10]]
    subject.select(5..25, :with_scores => false, :limit => 1).to_a.should == ['c']
  end

  it 'should return values at a certain index' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    subject.at(1).should == 'b'
    subject.at(2).should == 'a'
    subject.at(3).should be_nil
  end

  it 'should return the first and last value(s)' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    subject.first.should == 'c'
    subject.last.should == 'a'
    subject.first(1).should == ['c']
    subject.first(2).should == ['c', 'b']
  end

  it 'should build union and store results' do
    subject.add('a', 30).add('b', 20).add('c', 10)
    other.add('a', 40).add('d', 5)

    result = subject.unionstore('target', other, :aggregate => :sum)
    result.should be_a(described_class)
    result.key.should == "target"
    result.should == [["d", 5], ["c", 10], ["b", 20], ["a", 70]]
  end

  it 'should build intersections and store results' do
    subject.add('a', 30).add('b', 20).add('c', 10)
    other.add('a', 40).add('d', 5)

    result = subject.interstore('target', other, :aggregate => :max)
    result.should be_a(described_class)
    result.key.should == "target"
    result.should == [["a", 40]]
  end

  it 'should increment values' do
    subject.add('a', 30)
    subject.increment('a').should == 31
    subject['a'].should == 31
    subject.increment('a', 5).should == 36
    subject['a'].should == 36
  end

  it 'should decrement values' do
    subject.increment('a', 5).should == 5
    subject['a'].should == 5
    subject.decrement('a').should == 4
    subject.decrement('a', 2).should == 2
    subject['a'].should == 2
  end

end
