require 'spec_helper'

describe Redpear::Store::Base do

  subject do
    described_class.new "base:key", connection
  end

  let :record do
    Redpear::Store::Value.new 'value:key', connection
  end

  describe "class" do

    it "should create temporary keys" do
      Redpear::Store::Value.temporary connection do |target|
        expect(target).to be_instance_of(Redpear::Store::Value)
        expect(target.to_s).to match(/\A[0-9a-f]{40}\z/)
      end
    end

    it "should remove temporary keys after use" do
      yielded = nil
      Redpear::Store::Value.temporary connection do |store|
        yielded = store
        store.set 'a'
        expect(store.exists?).to be(true)
      end
      expect(yielded).to be_instance_of(Redpear::Store::Value)
      expect(yielded.exists?).to be(false)
    end

    it "should never override existing keys" do
      record.set "present"
      expect(SecureRandom).to receive(:hex).twice.and_return(record.key, "next:key")
      Redpear::Store::Value.temporary connection do |store|
        expect(store.to_s).to eq("next:key")
      end
      expect(record).to eq("present")
    end

    it "should allow to specify prefixes" do
      Redpear::Store::Value.temporary connection, :prefix => "temp:" do |store|
        expect(store.to_s).to include("temp:")
        expect(store.to_s.size).to eq(45)
      end
    end

  end

  describe '#value' do
    subject { super().value }
    it { is_expected.to be_nil }
  end

  it 'should have a key' do
    expect(subject.key).to eq("base:key")
    expect(subject.to_s).to eq("base:key")
  end

  it 'should have a connection' do
    expect(subject.conn).to be(connection)
  end

  it 'should have a custom inspect' do
    expect(subject.inspect).to eq(%(#<Redpear::Store::Base base:key: nil>))
  end

  it 'should have a ttl' do
    expect(subject.ttl).to be_nil
    expect(record.ttl).to be_nil
    record.set "abcd"
    record.expire(10)
    expect(record.ttl).to be <= 10
  end

  it 'should allow to expire records via timestamps' do
    record.set "abcd"
    expect(record.expire(Time.now + 3600)).to be(true)
    expect(record.ttl).to be > 3590
    expect(record.ttl).to be <= 3600
  end

  it 'should allow to expire records via numeric periods' do
    record.set "abcd"
    expect(record.expire(3600)).to be(true)
    expect(record.ttl).to be > 3590
    expect(record.ttl).to be <= 3600
  end

  it 'should allow to expire records via period strings' do
    record.set "abcd"
    expect(record.expire("3600")).to be(true)
    expect(record.ttl).to be > 3590
    expect(record.ttl).to be <= 3600
  end

  it 'should not expire non-existing records' do
    expect(record.expire("3600")).to be(false)
    record.set "abcd"
    expect(record.expire("3600")).to be(true)
  end

  it 'should check key existence' do
    expect(record.exists?).to be(false)
    record.set 'abcd'
    expect(record.exists?).to be(true)
  end

  it 'should allow to watch a key' do
    expect(record.watch).to be(true)
    expect(record.watch { }).to be(true) # with block
  end

  it 'should allow purging records' do
    record.set 'abcd'
    expect(record.exists?).to be(true)
    expect(record.purge!).to be(true)
    expect(record.purge!).to be(false)
    expect(record.exists?).to be(false)
  end

  it 'should allow clearing records' do
    record.set 'abcd'
    expect(record.exists?).to be(true)
    expect(record.clear).to be_nil
    expect(record.exists?).to be(false)
  end

  it 'should return type information' do
    expect(subject.type).to eq(:none)
    expect(record.type).to eq(:none)
    record.set 'abcd'
    expect(record.type).to eq(:string)
  end

end
