require 'spec_helper'

describe Redpear::Store::Lock do

  subject do
    described_class.new 'lock:key', connection
  end

  let :value do
    Redpear::Store::Value.new 'value:key', connection
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
      ok = subject.lock(:wait_timeout => 0) {}
      ok.should be(false)
    end

  end

end
