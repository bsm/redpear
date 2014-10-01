require 'spec_helper'

describe Redpear::Store::Enumerable do

  subject do
    Redpear::Store::List.new('enum:key', connection)
  end

  it { is_expected.to be_a(Redpear::Store::Base) }
  it { is_expected.to be_a(::Enumerable) }

  describe '#value' do
    subject { super().value }
    it { is_expected.to eq([]) }
  end

  it 'should have a custom inspect' do
    subject << 'a' << 'b' << 'c'
    expect(subject.inspect).to eq(%(#<Redpear::Store::List enum:key: ["a", "b", "c"]>))
  end

  it 'should have a #clear alias' do
    subject << 'a' << 'b' << 'c'
    expect(subject.clear).to eq([])
    expect(subject.exists?).to be(false)
  end

end
