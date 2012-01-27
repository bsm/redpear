require 'spec_helper'

describe Redpear::Store::Lock do

  subject do
    described_class.new('lock:key', connection)
  end

  let :lock do
    Redpear::Store::Value.new('lock:key', connection)
  end

  let :value do
    Redpear::Store::Value.new('value:key', connection)
  end

  before do
    subject.stub! :sleep
  end

  it { should be_a(Redpear::Store::Base) }

  it 'should have a locked indicator' do
    subject.should_not be_locked
    subject.lock do
      subject.should be_locked
    end
    subject.should_not be_locked
  end

  it 'should expire orphaned locks' do
    lock.value = "anything"
    subject.lock do
      value.set "x"
    end
    value.should == "x"
    lock.value.should be_nil
  end

  it 'should expire orphaned locks' do
    lock.value = "anything"
    subject.lock do
      value.set "x"
    end
    value.should == "x"
    lock.value.should be_nil
  end

  it 'should use random/unique lock values' do
    subject.lock do
      lock.value.should match(/\A[a-f0-9]{32}\z/)
    end
  end

  it 'should wait if already locked' do
    thread = Thread.new do
      subject.lock { sleep 0.01; value.set "A" }
    end
    sleep(0.001) until subject.locked?

    value.should be_nil
    subject.should be_locked
    subject.lock do
      value.should == "A"
    end
    thread.join
  end

  it 'should raise an error when lock cannot be acquired in time' do
    lambda do
      subject.lock(:wait => (Time.now - 1)) {}
    end.should raise_error(described_class::LockTimeout)
  end

  it 'should raise an error when lock is lost' do
    lambda do
      subject.lock { lock.value = "broken" }
    end.should raise_error(described_class::UnlockError)
  end

end
