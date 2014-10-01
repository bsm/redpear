require 'spec_helper'

describe Redpear::Store::Hash do

  subject do
    described_class.new "hash:key", connection
  end

  it { is_expected.to be_a(Redpear::Store::Enumerable) }

  it 'should return all pairs' do
    expect(subject.all).to eq({})
    subject.store('a', 'b')
    expect(subject.all).to eq({ 'a' => 'b' })
    expect(subject.to_hash).to eq({ 'a' => 'b' })
  end

  it 'should yield over pairs' do
    yielded = []
    subject.each {|k, v| yielded << [k,v] }
    expect(yielded).to eq([])

    subject.store('a', 'b')
    subject.each {|k, v| yielded << [k,v] }
    expect(yielded).to eq([['a', 'b']])
  end

  it 'should delete fields' do
    subject.store('a', '1')
    subject.store('b', '2')
    expect(subject).to eq({ 'a' => '1', 'b' => '2' })
    subject.delete('a')
    expect(subject).to eq({ 'b' => '2' })
  end

  it 'should check if key exists' do
    expect(subject.key?('a')).to be(false)
    subject.store('a', 'b')
    expect(subject.key?('a')).to be(true)
  end

  it 'should check if hash is empty' do
    expect(subject.empty?).to be(true)
    subject.store('a', 'b')
    expect(subject.empty?).to be(false)
  end

  it 'should clear all pairs' do
    expect(subject.clear).to eq({})
    subject.store('a', 'b')
    expect(subject.size).to be(1)
    expect(subject.clear).to eq({})
    expect(subject.size).to be(0)
  end

  it 'should fetch values' do
    expect(subject.fetch('a')).to be_nil
    expect(subject['a']).to be_nil
    subject.store('a', 'b')
    expect(subject.fetch('a')).to eq('b')
    expect(subject['a']).to eq('b')
  end

  it 'should store values' do
    subject.store('a', 'b')
    expect(subject['a']).to eq('b')
    subject['a'] = 'c'
    expect(subject['a']).to eq('c')
    subject['a'] = false
    expect(subject['a']).to eq('false')
    subject['a'] = nil
    expect(subject['a']).to be_nil
    expect(subject.keys).not_to include('a')
  end

  it 'should increment values' do
    expect(subject.increment('a')).to eq(1)
    expect(subject['a']).to eq('1')
    expect(subject.increment('a', 5)).to eq(6)
    expect(subject['a']).to eq('6')
  end

  it 'should decrement values' do
    expect(subject.increment('a', 5)).to eq(5)
    expect(subject.decrement('a')).to eq(4)
    expect(subject.decrement('a', 2)).to eq(2)
    expect(subject['a']).to eq('2')
  end

  it 'should return all keys' do
    expect(subject.keys).to eq([])
    subject.store('a', 'b')
    expect(subject.keys).to eq(['a'])
    subject.store('b', 'c')
    expect(subject.keys).to match_array(['a', 'b'])
  end

  it 'should return all values' do
    expect(subject.values).to eq([])
    subject.store('a', 'b')
    expect(subject.values).to eq(['b'])
    subject.store('b', 'c')
    expect(subject.values).to match_array(['b', 'c'])
  end

  it 'should return the length' do
    expect(subject.length).to eq(0)
    subject.store('a', 'b')
    expect(subject.length).to eq(1)
  end

  it 'should return values for specific keys' do
    expect(subject.values_at('a', 'b', 'c')).to eq([nil, nil, nil])
    subject.store('a', 'b')
    subject.store('c', 'd')
    expect(subject.values_at('a', 'b', 'c')).to eq(['b', nil, 'd'])
  end

  it 'should update specific keys' do
    expect(subject.update('a' => 'b')).to eq({'a' => 'b'})
    subject.store('c', 'd')
    expect(subject.to_hash).to eq({'a' => 'b', 'c' => 'd'})
    expect(subject.update('c' => 'x', 'e' => 'f')).to eq({'a' => 'b', 'c' => 'x', 'e' => 'f'})
    expect(subject.update('a' => nil, 'e' => 'y')).to eq({'c' => 'x', 'e' => 'y'})
  end

  it 'should not fail on empty updates' do
    subject.store('c', 'd')
    expect(subject.update({})).to eq({'c' => 'd'})
  end

  it 'should have a custom inspect' do
    expect(subject.inspect).to eq(%(#<Redpear::Store::Hash hash:key: {}>))
    subject.update('a' => 'b')
    expect(subject.inspect).to eq(%(#<Redpear::Store::Hash hash:key: {"a"=>"b"}>))
  end

  it 'should be pipelineable' do
    expect(connection.pipelined do
      subject.all
      subject.store('a', 'b')
      subject.keys
      subject.values
      subject.length
      subject.key?('a')
      subject.key?('b')
      
      subject.delete('a')
      subject.empty?
      subject.update('b' => 1, 'c' => 2)
      subject.increment('b')
      subject.decrement('c')
      subject.values_at("b", "c")
    end).to eq([
      {}, true, ["a"], ["b"], 1, true, false, 
      1, true, "OK", 2, 1, ["2", "1"]
    ])
  end

end
