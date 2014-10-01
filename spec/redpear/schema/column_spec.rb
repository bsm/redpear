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

  it { is_expected.to be_a(String) }

  it 'should have a name' do
    expect(subject).to eq("name")
    expect(counter).to eq("hits")

    expect(subject).to be_instance_of(described_class)
    expect(subject.name).to be_instance_of(String)
  end

  it 'should have a type' do
    expect(subject.type).to be_nil
    expect(counter.type).to eq(:counter)
    expect(timestamp.type).to eq(:timestamp)
  end

  it 'should determine readable status' do
    expect(subject).to be_readable
    expect(integer).to be_readable
    expect(counter).to be_readable
    expect(timestamp).to be_readable
  end

  it 'should determine writable status' do
    expect(subject).to be_writable
    expect(integer).to be_writable
    expect(counter).to be_writable
    expect(timestamp).to be_writable
  end

  it 'should type-cast values' do
    expect(subject.type_cast("a")).to eq("a")

    expect(integer.type_cast(nil)).to eq(nil)
    expect(integer.type_cast("a")).to eq(nil)
    expect(integer.type_cast("12.3")).to eq(nil)
    expect(integer.type_cast("123")).to eq(123)
    expect(integer.type_cast("-123")).to eq(-123)

    expect(float.type_cast(nil)).to eq(nil)
    expect(float.type_cast("a")).to eq(nil)
    expect(float.type_cast("123")).to eq(123.0)
    expect(float.type_cast("12.3")).to eq(12.3)
    expect(float.type_cast("-12.3")).to eq(-12.3)

    expect(counter.type_cast(nil)).to eq(0)
    expect(counter.type_cast("a")).to eq(0)
    expect(counter.type_cast("12.3")).to eq(0)
    expect(counter.type_cast("123")).to eq(123)
    expect(counter.type_cast("-123")).to eq(-123)

    expect(timestamp.type_cast(nil)).to eq(nil)
    expect(timestamp.type_cast("a")).to eq(nil)
    expect(timestamp.type_cast("1313131313")).to eq(Time.at(1313131313))
  end

  it 'should encode values' do
    expect(subject.encode_value("123")).to eq("123")
    expect(subject.encode_value(123)).to eq(123)
    expect(subject.encode_value(Time.at(1313131313))).to eq(1313131313)
  end

end