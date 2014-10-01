require 'spec_helper'

describe Redpear::Store::SortedSet do

  subject do
    described_class.new "zset:key", connection
  end

  let :other do
    described_class.new "other", connection
  end

  it { is_expected.to be_a(Redpear::Store::Enumerable) }

  it 'should return all members' do
    expect(subject.to_a).to  eq([])
    expect(subject.to_a(:with_scores => false)).to eq([])
    subject.add('a', 1)
    expect(subject.to_a).to eq([['a', 1]])
    expect(subject.to_a(:with_scores => false)).to eq(['a'])
  end

  it 'should return scores as floats' do
    subject.add('a', 1)
    expect(subject.to_a.first.last).to eq(1.0)
    expect(subject.to_a.first.last).to be_instance_of(Float)
  end

  it 'should yield all each member' do
    subject.add('a', 1)
    yielded = []
    subject.each {|v, s| yielded << [v, s] }
    expect(yielded).to eq([['a', 1]])
  end

  it 'should return the length' do
    expect(subject.length).to eq(0)
    subject.add('a', 1)
    expect(subject.length).to eq(1)
  end

  it 'should count items within a score range' do
    expect(subject.count(0..5)).to be(0)
    subject.add('a', 1)
    subject.add('b', 2)
    subject.add('c', 3)
    expect(subject.count(1..2)).to be(2)
    expect(subject.count(1...2)).to be(1)
    expect(subject.count([2, "+inf"])).to be(2)
    expect(subject.count(["-inf", "+inf"])).to be(3)
  end

  it 'should add values' do
    expect(subject.length).to eq(0)
    subject.add('a', 1)
    subject['b'] = 1
    expect(subject.length).to eq(2)
  end

  it 'should delete values' do
    subject.add('a', 1)
    expect(subject.length).to eq(1)
    subject.delete('a')
    expect(subject.length).to eq(0)
  end

  it 'should clear all values' do
    subject.add('a', 1)
    expect(subject.length).to eq(1)
    expect(subject.clear).to eq([])
    expect(subject.length).to eq(0)
  end

  it 'should check if empty' do
    expect(subject).to be_empty
    subject.add('a', 1)
    expect(subject).not_to be_empty
  end

  it 'should check if value is included' do
    expect(subject.include?('a')).to be(false)
    subject.add('a', 1)
    expect(subject.include?('a')).to be(true)
  end

  it 'should be comparable' do
    subject.add('a', 1)
    subject.add('b', 2)
    expect(subject).to eq([['a', 1], ['b', 2]])
    expect(subject).to eq({ 'a' => 1, 'b' => 2 })
  end

  it 'should return scores for values' do
    subject.add('a', 20)
    subject.add('b', 10)
    expect(subject.score('a')).to eq(20)
    expect(subject.score('a')).to be_instance_of(Float)
    expect(subject['b']).to eq(10)
    expect(subject['c']).to be_nil
  end

  it 'should return indicies for values' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.index('a')).to eq(2)
    expect(subject.index('c')).to eq(0)
    expect(subject.rindex('a')).to eq(0)
    expect(subject.rindex('c')).to eq(2)
  end

  it 'should return slices' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.top(1..-1)).to be_instance_of(Array)
    expect(subject.top(1..-1).to_a).to eq([['b', 20], ['a', 30]])
    expect(subject.bottom(1..-1).to_a).to eq([['b', 20], ['c', 10]])
  end

  it 'should select values between scores' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.select(5..25)).to be_instance_of(Array)
    expect(subject.select(5..25).to_a).to eq([['c', 10], ['b', 20]])
    expect(subject.select([15, "+inf"]).to_a).to eq([["b", 20.0], ["a", 30.0]])
    expect(subject.rselect(5..25).to_a).to eq([['b', 20], ['c', 10]])
    expect(subject.rselect([20, "-inf"]).to_a).to eq([["b", 20.0], ["c", 10.0]])
    expect(subject.select(5..25, :with_scores => false, :limit => 1).to_a).to eq(['c'])
  end

  it 'should return values at a certain index' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.at(1)).to eq(['b', 20.0])
    expect(subject.at(2, :with_scores => false)).to eq('a')
    expect(subject.at(3)).to be_nil
  end

  it 'should return the first and last member(s)' do
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.first).to eq('c')
    expect(subject.last).to eq('a')
    expect(subject.first(1)).to eq(['c'])
    expect(subject.first(2)).to eq(['c', 'b'])
  end

  it 'should return the minimum and the maximum score(s)' do
    expect(subject.minimum).to be_nil
    expect(subject.maximum).to be_nil
    subject.add('a', 30)
    subject.add('b', 20)
    subject.add('c', 10)
    expect(subject.minimum).to be_instance_of(Float)
    expect(subject.maximum).to be_instance_of(Float)
    expect(subject.minimum).to eq(10.0)
    expect(subject.maximum).to eq(30.0)
  end

  it 'should build union and store results' do
    subject.add('a', 30).add('b', 20).add('c', 10)
    other.add('a', 40).add('d', 5)

    result = subject.unionstore('target', other, :aggregate => :sum)
    expect(result).to be_instance_of(described_class)
    expect(result.key).to eq("target")
    expect(result).to eq([["d", 5], ["c", 10], ["b", 20], ["a", 70]])
  end

  it 'should build intersections and store results' do
    subject.add('a', 30).add('b', 20).add('c', 10)
    other.add('a', 40).add('d', 5)

    result = subject.interstore('target', other, :aggregate => :max)
    expect(result).to be_instance_of(described_class)
    expect(result.key).to eq("target")
    expect(result).to eq([["a", 40]])
  end

  it 'should increment values' do
    subject.add('a', 30)
    expect(subject.increment('a')).to eq(31)
    expect(subject['a']).to eq(31)
    expect(subject.increment('a', 5)).to eq(36)
    expect(subject['a']).to eq(36)
  end

  it 'should decrement values' do
    expect(subject.increment('a', 5)).to eq(5)
    expect(subject['a']).to eq(5)
    expect(subject.decrement('a')).to eq(4)
    expect(subject.decrement('a', 2)).to eq(2)
    expect(subject['a']).to eq(2)
  end

  it 'should be pipelineable' do
    expect(connection.pipelined do
      subject.add('a', 10)
      subject['b'] = 20
      subject.to_a
      subject.size
      subject.count(5..15)

      subject.select(5..15)      
      subject.score('a')
      subject.score('c')
      subject.index('b')
      subject.rindex('c')
      subject.minimum
      subject.maximum
      subject.delete('b')

      subject.include?('a')
      subject.include?('b')
      subject.empty?
      subject.slice(0..1)
      subject.at(0)
      subject.increment("a", 4)
    end).to eq([
      true, true, [["a", 10.0], ["b", 20.0]], 2, 1, 
      [["a", 10.0]], 10.0, nil, 1, nil, "a", "b", true, 
      true, false, false, [["a", 10.0]], "a", 14.0
    ])
  end

end
