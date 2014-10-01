require 'spec_helper'

describe Redpear::Store::List do

  subject do
    described_class.new "list:key", connection
  end

  let :other do
    described_class.new 'other', connection
  end

  it { is_expected.to be_a(Redpear::Store::Enumerable) }

  it 'should return all items' do
    expect(subject.all).to eq([])

    subject << 'a' << 'b' << 'c'
    expect(subject.to_a).to eq(['a', 'b', 'c'])
  end

  it 'should return the length' do
    expect(subject.length).to eq(0)
    subject.push('a')
    expect(subject.length).to eq(1)
  end

  it 'should return slices' do
    expect(subject.slice(0)).to eq(nil)
    expect(subject.slice(0, 1)).to eq([])
    expect(subject.slice(0..2)).to eq([])

    subject << 'a' << 'b' << 'c' << 'd' << 'e'
    expect(subject[0]).to eq('a')
    expect(subject[-1]).to eq('e')
    expect(subject[1, 2]).to eq(['b', 'c'])
    expect(subject[1..3]).to eq(['b', 'c', 'd'])
    expect(subject[1...3]).to eq(['b', 'c'])
    expect(subject[2..10]).to eq(['c', 'd', 'e'])
  end

  it 'should push items' do
    expect(subject.length).to eq(0)
    subject << 'a' << 'b' << 'c'
    expect(subject.length).to eq(3)
    expect(subject[-1]).to eq('c')
  end

  it 'should pop items' do
    subject << 'a' << 'b' << 'c'
    expect(subject.length).to eq(3)
    expect(subject.pop).to eq('c')
    expect(subject.length).to eq(2)
  end

  it 'should unshift items' do
    expect(subject.length).to eq(0)
    subject.unshift('a').unshift('b').unshift('c')
    expect(subject.length).to eq(3)
    expect(subject[-1]).to eq('a')
  end

  it 'should shift items' do
    subject << 'a' << 'b' << 'c'
    expect(subject.length).to eq(3)
    expect(subject.shift).to eq('a')
    expect(subject.length).to eq(2)
  end

  it 'should delete items' do
    subject << 'a' << 'a' << 'a' << 'b' << 'c' << 'a' << 'a'
    subject.delete('a', 2)
    expect(subject).to eq(['a', 'b', 'c', 'a', 'a'])
    subject.delete('a', -1)
    expect(subject).to eq(['a', 'b', 'c', 'a'])
    subject.delete('a')
    expect(subject).to eq(['b', 'c'])
  end

  it 'should pop and prepend items to other lists' do
    subject << 'a' << 'b' << 'c'
    other   << 'e' << 'f'
    subject.pop_unshift(other)
    expect(subject).to eq(['a', 'b'])
    expect(other).to eq(['c', 'e', 'f'])
  end

  it 'should insert items' do
    subject << 'a' << 'b' << 'c'
    subject.insert_before 'b', 'e'
    expect(subject).to eq(['a', 'e', 'b', 'c'])
    subject.insert_after 'b', 'f'
    expect(subject).to eq(['a', 'e', 'b', 'f', 'c'])
  end

  it 'should destructively slice items' do
    subject << 'a' << 'b' << 'c' << 'd'
    expect(subject.slice!(1..-1)).to eq(['b', 'c', 'd'])
    expect(subject).to eq(['b', 'c', 'd'])
    expect(subject.slice!(0, 2)).to eq(['b', 'c'])
    expect(subject).to eq(['b', 'c'])
  end

  it 'should be pipelineable' do
    expect(connection.pipelined do
      subject.all
      subject << 'a' << 'b'
      subject.to_a
      subject.insert_after('a', 'c')
      subject.insert_before('c', 'd')
      subject.length

      subject[1, 2]
      subject.slice!(1, 3)
      subject.pop
      subject.unshift('e')
      subject.shift
    end).to eq([
      [], 1, 2, ["a", "b"], 3, 4, 4, 
      ["d", "c"], "OK", "b", 3, "e"
    ])
  end

end
