require 'spec_helper'

describe Redpear::Store::Counter do

  subject do
    described_class.new "counter:key", connection
  end

  it { is_expected.to be_a(Redpear::Store::Value) }

  it 'should read and write methods as integers' do
    expect(subject.get).to eq(0)
    expect(subject.value).to eq(0)
    subject.set 5
    expect(subject.get).to eq(5)
    subject.set "5"
    expect(subject.get).to eq(5)
    subject.value = "1"
    expect(subject.get).to eq(1)
    expect { subject.value = "abc" }.to raise_error(ArgumentError)
  end

  it 'should increment values' do
    expect(subject.increment).to eq(1)
    expect(subject.increment(5)).to eq(6)
    expect(subject).to eq(6)
  end

  it 'should decrement values' do
    subject.set 6
    expect(subject.decrement).to eq(5)
    expect(subject.decrement(2)).to eq(3)
    expect(subject).to eq(3)
  end

  it 'should be pipelineable' do
    expect(connection.pipelined do
      subject.get
      subject.set 6
      subject.get
      subject.increment
      subject.decrement(2)
    end).to eq([0, "OK", 6, 7, 5])
  end

end
