require 'spec_helper'

describe Redpear::Store::Set do

  subject do
    described_class.new "set:key", connection
  end

  let :other do
    described_class.new 'other', connection
  end

  it { is_expected.to be_a(Redpear::Store::Enumerable) }

  it 'should return all members' do
    expect(subject.members).to eq([])
    expect(subject.all).to eq(Set.new)

    subject.add('a')
    expect(subject.to_set).to eq(['a'].to_set)
    expect(subject.to_a).to eq(['a'])
  end

  it 'should have a value' do
    expect(subject.value).to eq(subject.all)
  end

  it 'should return the length' do
    expect(subject.length).to eq(0)
    subject.add('a')
    expect(subject.length).to eq(1)
  end

  it 'should add values' do
    expect(subject.length).to eq(0)
    subject.add('a')
    subject.add('b')
    expect(subject.length).to eq(2)
  end

  it 'should delete values' do
    subject.add('a')
    expect(subject.length).to eq(1)
    subject.delete('a')
    expect(subject.length).to eq(0)
  end

  it 'should check if empty' do
    expect(subject).to be_empty
    subject.add('a')
    expect(subject).not_to be_empty
  end

  it 'should check if value is included' do
    expect(subject.include?('a')).to be(false)
    subject.add('a')
    expect(subject.include?('a')).to be(true)
  end

  it 'should pop random values' do
    expect(subject.pop).to be_nil
    subject.add('a')
    expect(subject.pop).to eq('a')
    expect(subject).to be_empty
  end

  it 'should be comparable' do
    subject << 'a' << 'b' << 'c'
    expect(subject).to eq(['a', 'b', 'c'])
    expect(subject).to eq(['a', 'b', 'c'].to_set)
  end

  it 'should return random members' do
    expect(subject.random).to be_nil
    subject << 'a'
    expect(subject.random).to eq('a')
    expect(subject).to eq(['a'])
  end

  it 'should subtract sets' do
    subject << 'a' << 'b'
    other   << 'a' << 'c'
    expect(subject - other).to eq(['b'])
    expect(subject - "other").to eq(['b'])
  end

  it 'should subtract sets and store results' do
    subject << 'a' << 'b'
    other   << 'a' << 'c'
    result = subject.diffstore('target', other)
    expect(result).to be_a(described_class)
    expect(result.key).to eq("target")
    expect(result).to eq(['b'])
  end

  it 'should union sets' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'd'
    expect(subject + other).to match_array(['a', 'b', 'c', 'd'])
  end

  it 'should build union and store results' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'd'
    result = subject.unionstore('target', other)
    expect(result).to be_a(described_class)
    expect(result.key).to eq("target")
    expect(result).to eq(['a', 'b', 'c', 'd'])
  end

  it 'should build intersections' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'c' << 'd'
    expect(subject & other).to match_array(['a', 'c'])
  end

  it 'should build intersections and store results' do
    subject << 'a' << 'b' << 'c'
    other   << 'a' << 'c' << 'd'
    result = subject.interstore('target', other)
    expect(result).to be_a(described_class)
    expect(result.key).to eq("target")
    expect(result).to eq(['a', 'c'])
  end

  it 'should move members from one set to another' do
    subject.move('other', 'a')
    expect(other).to eq([])
    subject << 'a' << 'b'
    subject.move('other', 'a')
    expect(other).to eq(['a'])
    expect(subject).to eq(['b'])
  end

  it 'should be pipelineable' do
    res = connection.pipelined do
      subject << 'a' << 'b'
      subject.all
      subject.to_a
      subject.length

      subject.empty?
      subject.include?("a")
      subject.include?("c")
      subject.delete("b")
      subject.random
      subject.pop
    end
    res[3].sort!
    expect(res).to eq([
      true, true, ["a", "b"].to_set, ["a", "b"], 2,
      false, true, false, true, "a", "a"
    ])
  end

end
