require 'spec_helper'

describe Redpear::Schema::Column do

  subject do
    described_class.new Post, :name
  end

  let :integer do
    described_class.new Post, :age, :integer
  end

  let :float do
    described_class.new Post, :score, :float
  end

  let :timestamp do
    described_class.new Post, :created_at, :timestamp
  end

  let :counter do
    described_class.new Post, :hits, 'counter'
  end

  it { should be_a(String) }

  it 'should have a name' do
    subject.should == "name"
    counter.should == "hits"

    subject.should be_instance_of(described_class)
    subject.name.should be_instance_of(String)
  end

  it 'should have a type' do
    subject.type.should be_nil
    counter.type.should == :counter
    timestamp.type.should == :timestamp
  end

  it 'should determine readable status' do
    subject.should be_readable
    integer.should be_readable
    counter.should be_readable
    timestamp.should be_readable
  end

  it 'should determine writable status' do
    subject.should be_writable
    integer.should be_writable
    counter.should be_writable
    timestamp.should be_writable
  end

  it 'should type-cast values' do
    subject.type_cast("a").should == "a"

    integer.type_cast(nil).should == nil
    integer.type_cast("a").should == nil
    integer.type_cast("12.3").should == nil
    integer.type_cast("123").should == 123
    integer.type_cast("-123").should == -123

    float.type_cast(nil).should == nil
    float.type_cast("a").should == nil
    float.type_cast("123").should == 123.0
    float.type_cast("12.3").should == 12.3
    float.type_cast("-12.3").should == -12.3

    counter.type_cast(nil).should == 0
    counter.type_cast("a").should == 0
    counter.type_cast("12.3").should == 0
    counter.type_cast("123").should == 123
    counter.type_cast("-123").should == -123

    timestamp.type_cast(nil).should == nil
    timestamp.type_cast("a").should == nil
    timestamp.type_cast("1313131313").should == Time.at(1313131313)
  end

  it 'should encode values' do
    subject.encode_value("123").should == "123"
    subject.encode_value(123).should == 123
    subject.encode_value(Time.at(1313131313)).should == 1313131313
  end

end