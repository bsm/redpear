require 'spec_helper'

describe Redpear::Model::Expiration do

  subject { Post.new :title => 'Any' }

  it 'should ignore invalid expire values' do
    expect(subject.expire(nil)).to be(false)
    expect(subject.expire(false)).to be(false)
    expect(subject.expire("ABC")).to be(false)
  end

  it 'should allow to expire records via timestamps' do
    expect(subject.expire(Time.now + 3600)).to be(true)
    expect(subject.ttl).to be > 0
    expect(subject.ttl).to be <= 3600
  end

  it 'should allow to expire records via numeric periods' do
    expect(subject.expire(3600)).to be(true)
    expect(subject.ttl).to be > 0
    expect(subject.ttl).to be <= 3600
  end

  it 'should return negative ttl for non-expiring records' do
    expect(subject.ttl).to be_nil
  end

  it 'should return a positive ttl for expiring records' do
    subject.expire(30)
    expect(subject.ttl).to be > 0
  end

end
