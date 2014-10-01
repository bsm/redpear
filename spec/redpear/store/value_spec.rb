require 'spec_helper'

describe Redpear::Store::Value do

  subject do
    described_class.new "value:key", connection
  end

  it { is_expected.to be_a(Redpear::Store::Base) }

  it 'should have a custom inspect' do
    expect(subject.inspect).to eq("#<Redpear::Store::Value value:key: nil>")
    subject.value = "abcd"
    expect(subject.inspect).to eq(%(#<Redpear::Store::Value value:key: "abcd">))
  end

  it 'should delete values' do
    expect(subject.exists?).to be(false)
    subject.value = "abcd"
    expect(subject.exists?).to be(true)
    subject.delete
    expect(subject.exists?).to be(false)
  end

  it 'should read values' do
    expect(subject.get).to be_nil
    subject.value = "abcd"
    expect(subject.value).to eq("abcd")
    expect(subject.get).to eq("abcd")
  end

  it 'should write values' do
    subject.value = "abcd"
    expect(subject).to eq("abcd")
    subject.set "dcab"
    expect(subject).to eq("dcab")
    subject.replace "aaa"
    expect(subject).to eq("aaa")
  end

  it 'should append values' do
    subject.value = "abcd"
    subject.append 'e'
    subject << 'f'
    expect(subject).to eq("abcdef")
  end

  it 'should be comparable' do
    expect(subject).to eq(nil)
    subject.set "ab"
    expect(subject).to eq("ab")
    expect(subject).not_to eq("ba")
  end

  it 'should check if nil' do
    expect(subject).to be_nil
    subject.value = "abcd"
    expect(subject).not_to be_nil
  end

  it 'should delegate to the actual value' do
    expect(subject.size).to eq(0)
    subject.value = "abcd"
    expect(subject.size).to eq(4)
    expect(subject.reverse).to eq("dcba")
  end

  it 'should be pipelineable' do
    expect(connection.pipelined do
      subject.nil?
      subject.get
      subject.set "ab"
      subject.nil?
      subject.get
      subject.value = "cd"
      subject == "cd"
      subject.append 'e'
      subject == "cd"
      subject.exists?
      subject.delete
      subject.exists?
    end).to eq([
      true, nil, "OK", false,
      "ab", "OK", true, 3, false,
      true, true, false
    ])
  end

end
