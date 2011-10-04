require 'spec_helper'

describe Redpear::Expiration do

  let :new_instance do
    Post.new :title => 'A'
  end

  subject do
    new_instance.save
    new_instance
  end

  it 'should ignore invalid expire values' do
    subject.expire(nil).should be(false)
    subject.expire(false).should be(false)
    subject.expire("ABC").should be(false)
  end

  it 'should not allow expiring non-persisted records' do
    new_instance.expire(300).should be(false)
  end

  it 'should allow to expire records via timestamps' do
    subject.expire(Time.now + 3600).should be(true)
    subject.ttl.should > 0
    subject.ttl.should <= 3600
  end

  it 'should allow to expire records via numeric periods' do
    subject.expire(3600).should be(true)
    subject.ttl.should > 0
    subject.ttl.should <= 3600
  end

  it 'should allow to expire records via period strings' do
    subject.expire("3600").should be(true)
    subject.ttl.should > 0
    subject.ttl.should <= 3600
  end

  it 'should NOT return a ttl for new instances' do
    new_instance.ttl.should be_nil
  end

  it 'should return negative ttl for non-expiring records' do
    subject.ttl.should == -1
  end

  it 'should return a positive ttl for expiring records' do
    subject.expire(30)
    subject.ttl.should > 0
  end

end