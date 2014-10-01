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
    allow(described_class).to receive(:sleep)
  end

  def set_current(offset = 0)
    connection.set subject.key, (Time.now + offset).to_f
  end

  it { is_expected.to be_a(Redpear::Store::Base) }

  describe "if empty" do
    it { is_expected.not_to be_exists }

    describe '#value' do
      subject { super().value }
      it { is_expected.to be_nil }
    end

    describe '#current' do
      subject { super().current }
      it { is_expected.to be_instance_of(Float) }
    end

    describe '#current' do
      subject { super().current }
      it { is_expected.to eq(0.0) }
    end
  end

  describe "if set" do
    before { set_current(60) }

    it { is_expected.to be_exists }

    its("value")   { is_expected.to be_instance_of(String) }
    its("current") { is_expected.to be_instance_of(Float) }
    its("current") { is_expected.to be > Time.now.to_f }
  end

  describe "locking" do

    it 'should lock with a timestamp and remove it on release' do
      expect(subject).not_to receive(:sleep)
      expect(subject.exists?).to be(false)
      subject.lock do
        value.set "true"
        expect(subject.exists?).to be(true)
        expect(subject.current).to be > Time.now.to_f
        expect(subject.current).to be < (Time.now.to_f + 3)
      end
      expect(value.get).to eq("true")
      expect(subject.exists?).to be(false)
    end

    it 'should not remove timestamp of task took longer than anticipated' do
      ts = Time.now
      subject.lock :lock_timeout => ts do
        expect(subject.current).to eq(ts.to_f)
      end
      expect(subject.current).to eq(ts.to_f)
    end

    it 'should wait for lock if locked by another process' do
      expect(subject).to receive(:sleep).at_least(:once)
      set_current(0.01)
      subject.lock {}
    end

    it 'should timeout if waiting for lock takes too long' do
      set_current(0.01)
      expect {
        subject.lock(:wait_timeout => 0) {}
      }.to raise_error(described_class::LockTimeout)
    end

    it 'should expire orphaned locks' do
      expect(subject).not_to receive(:sleep)
      set_current(-5)
      subject.lock { value.set "true" }
      expect(value.get).to eq("true")
    end

  end

  describe "conditional locking" do

    it 'should return success status' do
      ok = subject.lock? { value.set "true" }
      expect(ok).to be(true)
      expect(value.get).to eq("true")
    end

    it 'should not fail if lock cannot be obtained' do
      set_current(0.01)
      ok = subject.lock?(:wait_timeout => 0) {}
      expect(ok).to be(false)
    end

  end

  describe "reservations" do
    after { subject.purge! }

    it 'should attempt reservations' do
      expect(subject.reserve?(10)).to eq(true)
      expect(subject.reserve?(10)).to eq(false)
    end

    it 'should reserve and execute a block' do
      ts = Time.now.to_f
      expect(subject.reserve(10) { value.set "true" }).to eq("OK")
      expect(value.get).to eq("true")
      expect(subject.value.to_f).to be_within(1).of(ts + 10)
    end

    it 'should clear after execution if requested' do
      ts = Time.now.to_f
      expect(subject.reserve(10, :clear => true) { value.set "true" }).to eq("OK")
      expect(value.get).to eq("true")
      expect(subject).not_to be_exists
    end

    it 'should not execute of already reserved' do
      set_current(10)
      expect(subject.reserve(20) { value.set "true" }).to be_nil
      expect(value.get).to be_nil
    end

    it 'should prevent parallel execution' do
      t1 = Thread.new { subject.reserve(5) { counter.increment } }
      t2 = Thread.new { subject.reserve(5) { counter.increment } }
      [t1, t2].each(&:join)
      expect(counter.get).to eq(1)
    end

  end
end
