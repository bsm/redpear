require 'spec_helper'

describe Redpear::Store::Base do

  subject do
    described_class.new "bkey", connection
  end

  let :record do
    Redpear::Store::Value.new 'vkey', connection
  end

  its(:value) { should be_nil }

  it 'should have a key' do
    subject.key.should == "bkey"
    subject.to_s.should == "bkey"
  end

  it 'should have a connection' do
    subject.conn.should be(connection)
  end

  it 'should have a custom inspect' do
    subject.inspect.should == %(#<Redpear::Store::Base bkey: nil>)
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

  it 'should allow purging records' do
    record.set 'abcd'
    record.exists?.should be(true)
    record.purge!
    record.exists?.should be(false)
  end

end
