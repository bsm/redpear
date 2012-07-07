require 'spec_helper'

describe Redpear::Store::List do

  subject do
    described_class.new "list:key", connection
  end

  let :other do
    described_class.new 'other', connection
  end

  it { should be_a(Redpear::Store::Enumerable) }

  it 'should return all items' do
    subject.all.should == []

    subject << 'a' << 'b' << 'c'
    subject.to_a.should == ['a', 'b', 'c']
  end

  it 'should return the length' do
    subject.length.should == 0
    subject.push('a')
    subject.length.should == 1
  end

  it 'should return slices' do
    subject.slice(0).should == nil
    subject.slice(0, 1).should == []
    subject.slice(0..2).should == []

    subject << 'a' << 'b' << 'c' << 'd' << 'e'
    subject[0].should == 'a'
    subject[-1].should == 'e'
    subject[1, 2].should == ['b', 'c']
    subject[1..3].should == ['b', 'c', 'd']
    subject[1...3].should == ['b', 'c']
    subject[2..10].should == ['c', 'd', 'e']
  end

  it 'should push items' do
    subject.length.should == 0
    subject << 'a' << 'b' << 'c'
    subject.length.should == 3
    subject[-1].should == 'c'
  end

  it 'should pop items' do
    subject << 'a' << 'b' << 'c'
    subject.length.should == 3
    subject.pop.should == 'c'
    subject.length.should == 2
  end

  it 'should unshift items' do
    subject.length.should == 0
    subject.unshift('a').unshift('b').unshift('c')
    subject.length.should == 3
    subject[-1].should == 'a'
  end

  it 'should shift items' do
    subject << 'a' << 'b' << 'c'
    subject.length.should == 3
    subject.shift.should == 'a'
    subject.length.should == 2
  end

  it 'should delete items' do
    subject << 'a' << 'a' << 'a' << 'b' << 'c' << 'a' << 'a'
    subject.delete('a', 2)
    subject.should == ['a', 'b', 'c', 'a', 'a']
    subject.delete('a', -1)
    subject.should == ['a', 'b', 'c', 'a']
    subject.delete('a')
    subject.should == ['b', 'c']
  end

  it 'should pop and prepend items to other lists' do
    subject << 'a' << 'b' << 'c'
    other   << 'e' << 'f'
    subject.pop_unshift(other)
    subject.should == ['a', 'b']
    other.should == ['c', 'e', 'f']
  end

  it 'should insert items' do
    subject << 'a' << 'b' << 'c'
    subject.insert_before 'b', 'e'
    subject.should == ['a', 'e', 'b', 'c']
    subject.insert_after 'b', 'f'
    subject.should == ['a', 'e', 'b', 'f', 'c']
  end

  it 'should destructively slice items' do
    subject << 'a' << 'b' << 'c' << 'd'
    subject.slice!(1..-1).should == ['b', 'c', 'd']
    subject.should == ['b', 'c', 'd']
    subject.slice!(0, 2).should == ['b', 'c']
    subject.should == ['b', 'c']
  end

  it 'should be pipelineable' do
    connection.pipelined do
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
    end.should == [
      [], 1, 2, ["a", "b"], 3, 4, 4, 
      ["d", "c"], "OK", "b", 3, "e"
    ]
  end

end
