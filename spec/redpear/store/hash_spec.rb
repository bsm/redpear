require 'spec_helper'

describe Redpear::Store::Hash do

  subject do
    described_class.new "hkey", connection
  end

  it { should be_a(Enumerable) }
  it { should be_a(Redpear::Store::Base) }

  it 'should return all pairs' do
    subject.all.should == {}
    subject.store('a', 'b')
    subject.all.should == { 'a' => 'b' }
    subject.to_hash.should == { 'a' => 'b' }
  end

  it 'should yield over pairs' do
    yielded = []
    subject.each {|k, v| yielded << [k,v] }
    yielded.should == []

    subject.store('a', 'b')
    subject.each {|k, v| yielded << [k,v] }
    yielded.should == [['a', 'b']]
  end

  it 'should yield over pairs' do
    subject.delete('a').should be_nil
    subject.store('a', 'b')
    subject.delete('a').should == "b"
    subject.delete('a').should be_nil
  end

  it 'should check if key exists' do
    subject.key?('a').should be(false)
    subject.store('a', 'b')
    subject.key?('a').should be(true)
  end

  it 'should check if hash is empty' do
    subject.empty?.should be(true)
    subject.store('a', 'b')
    subject.empty?.should be(false)
  end

  it 'should clear all pairs' do
    subject.clear.should == {}
    subject.store('a', 'b')
    subject.size.should be(1)
    subject.clear.should == {}
    subject.size.should be(0)
  end

  it 'should fetch values' do
    subject.fetch('a').should be_nil
    subject['a'].should be_nil
    subject.store('a', 'b')
    subject.fetch('a').should == 'b'
    subject['a'].should == 'b'
  end

  it 'should store values' do
    subject.store('a', 'b')
    subject['a'].should == 'b'
    subject['a'] = 'c'
    subject['a'].should == 'c'
  end

  it 'should increment values' do
    subject.increment('a').should == 1
    subject['a'].should == '1'
    subject.increment('a', 5).should == 6
    subject['a'].should == '6'
  end

  it 'should return all keys' do
    subject.keys.should == []
    subject.store('a', 'b')
    subject.keys.should == ['a']
    subject.store('b', 'c')
    subject.keys.should =~ ['a', 'b']
  end

  it 'should return all values' do
    subject.values.should == []
    subject.store('a', 'b')
    subject.values.should == ['b']
    subject.store('b', 'c')
    subject.values.should =~ ['b', 'c']
  end

  it 'should return the length' do
    subject.length.should == 0
    subject.store('a', 'b')
    subject.length.should == 1
  end

  it 'should return values for specific keys' do
    subject.values_at('a', 'b', 'c').should == [nil, nil, nil]
    subject.store('a', 'b')
    subject.store('c', 'd')
    subject.values_at('a', 'b', 'c').should == ['b', nil, 'd']
  end

  it 'should update specific keys' do
    subject.update('a' => 'b').should == {'a' => 'b'}
    subject.store('c', 'd')
    subject.to_hash.should == {'a' => 'b', 'c' => 'd'}
    subject.update('c' => 'x', 'e' => 'f').should == {'a' => 'b', 'c' => 'x', 'e' => 'f'}
  end

end
