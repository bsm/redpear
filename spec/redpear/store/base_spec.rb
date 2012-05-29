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
        target.should be_instance_of(Redpear::Store::Value)
        target.to_s.should match(/\A[0-9a-f]{40}\z/)
      end
    end

    it "should remove temporary keys after use" do
      yielded = nil
      Redpear::Store::Value.temporary connection do |store|
        yielded = store
        store.set 'a'
        store.exists?.should be(true)
      end
      yielded.should be_instance_of(Redpear::Store::Value)
      yielded.exists?.should be(false)
    end

    it "should never override existing keys" do
      record.set "present"
      SecureRandom.should_receive(:hex).twice.and_return(record.key, "next:key")
      Redpear::Store::Value.temporary connection do |store|
        store.to_s.should == "next:key"
      end
      record.should == "present"
    end

    it "should allow to specify prefixes" do
      Redpear::Store::Value.temporary connection, :prefix => "temp:" do |store|
        store.to_s.should include("temp:")
        store.to_s.size.should == 45
      end
    end

  end

  its(:value) { should be_nil }

  it 'should have a key' do
    subject.key.should == "base:key"
    subject.to_s.should == "base:key"
  end

  it 'should have a connection' do
    subject.conn.should be(connection)
  end

  it 'should have a custom inspect' do
    subject.inspect.should == %(#<Redpear::Store::Base base:key: nil>)
  end

  it 'should have a ttl' do
    subject.ttl.should be_nil
    record.ttl.should be_nil
    record.set "abcd"
    record.expire(10)
    record.ttl.should <= 10
  end

  it 'should allow to expire records via timestamps' do
    record.set "abcd"
    record.expire(Time.now + 3600).should be(true)
    record.ttl.should > 3590
    record.ttl.should <= 3600
  end

  it 'should allow to expire records via numeric periods' do
    record.set "abcd"
    record.expire(3600).should be(true)
    record.ttl.should > 3590
    record.ttl.should <= 3600
  end

  it 'should allow to expire records via period strings' do
    record.set "abcd"
    record.expire("3600").should be(true)
    record.ttl.should > 3590
    record.ttl.should <= 3600
  end

  it 'should not expire non-existing records' do
    record.expire("3600").should be(false)
    record.set "abcd"
    record.expire("3600").should be(true)
  end

  it 'should check key existence' do
    record.exists?.should be(false)
    record.set 'abcd'
    record.exists?.should be(true)
  end

  it 'should allow to watch a key' do
    record.watch.should be(true)
    record.watch {}.should be(true) # with block
  end

  it 'should allow purging records' do
    record.set 'abcd'
    record.exists?.should be(true)
    record.purge!.should be(true)
    record.purge!.should be(false)
    record.exists?.should be(false)
  end

  it 'should allow clearing records' do
    record.set 'abcd'
    record.exists?.should be(true)
    record.clear.should be_nil
    record.exists?.should be(false)
  end

  it 'should return type information' do
    subject.type.should == :none
    record.type.should == :none
    record.set 'abcd'
    record.type.should == :string
  end

end
