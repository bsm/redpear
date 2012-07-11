require 'spec_helper'

describe Redpear::Store::Lock do

  subject do
    described_class.new 'lock:key', connection
  end

  let :value do
    Redpear::Store::Value.new 'value:key', connection
  end

  let :counter do
    Redpear::Store::Counter.new 'counter:key', connection
  end

  before do
    subject.stub! :sleep
  end

  def set_current(offset = 0)
    connection.set subject.key, (Time.now + offset).to_f
  end

  it { should be_a(Redpear::Store::Base) }

  describe "if empty" do
    it { should_not be_exists }
    its(:value) { should be_nil }
    its(:current) { should be_instance_of(Float) }
    its(:current) { should == 0.0 }
  end

  describe "if set" do
    before { set_current(60) }

    it { should be_exists }
    its(:value) { should be_instance_of(String) }
    its(:current) { should be_instance_of(Float) }
    its(:current) { should > Time.now.to_f }
  end

  describe "locking" do

    it 'should lock with a timestamp and remove it on release' do
      subject.should_not_receive(:sleep)
      subject.exists?.should be(false)
      subject.lock do
        value.set "true"
        subject.exists?.should be(true)
        subject.current.should > Time.now.to_f
        subject.current.should < (Time.now.to_f + 3)
      end
      value.get.should == "true"
      subject.exists?.should be(false)
    end

    it 'should not remove timestamp of task took longer than anticipated' do
      ts = Time.now
      subject.lock :lock_timeout => ts do
        subject.current.should == ts.to_f
      end
      subject.current.should == ts.to_f
    end

    it 'should wait for lock if locked by another process' do
      subject.should_receive(:sleep).at_least(:once)
      set_current(0.01)
      subject.lock {}
    end

    it 'should timeout if waiting for lock takes too long' do
      set_current(0.01)
      lambda {
        subject.lock(:wait_timeout => 0) {}
      }.should raise_error(described_class::LockTimeout)
    end

    it 'should expire orphaned locks' do
      subject.should_not_receive(:sleep)
      set_current(-5)
      subject.lock { value.set "true" }
      value.get.should == "true"
    end

  end

  describe "conditional locking" do

    it 'should return success status' do
      ok = subject.lock? { value.set "true" }
      ok.should be(true)
      value.get.should == "true"
    end

    it 'should not fail if lock cannot be obtained' do
      set_current(0.01)
      ok = subject.lock?(:wait_timeout => 0) {}
      ok.should be(false)
    end

  end

  describe "reservations" do

    it 'should reserve and execute a block' do
      ts = Time.now.to_f
      subject.reserve(10) { value.set "true" }.should == "OK"
      value.get.should == "true"
      subject.value.to_f.should be_within(1).of(ts + 10)
    end

    it 'should clear after execution if requested' do
      ts = Time.now.to_f
      subject.reserve(10, :clear => true) { value.set "true" }.should == "OK"
      value.get.should == "true"
      subject.should_not be_exists
    end

    it 'should not execute of already reserved' do
      set_current(10)
      subject.reserve(20) { value.set "true" }.should be_nil
      value.get.should be_nil
    end

    it 'should prevent parallel execution' do
      t1 = Thread.new { subject.reserve(5) { counter.increment } }
      t2 = Thread.new { subject.reserve(5) { counter.increment } }
      [t1, t2].each(&:join)
      counter.get.should == 1
    end

  end
end
