require 'spec_helper'

describe Redpear::Connection do

  it { should respond_to(:get) }
  it { should respond_to(:set) }
  it { should respond_to(:hgetall) }
  it { should respond_to(:mapped_hmset) }

  it "should use master for everything, unless slave specified" do
    subject.master.should be(Redis.current)
    subject.slave.should be(subject.master)
  end

  it "can connect via URLs" do
    url = Redis.current.id
    url.should include('redis://')
    ms = described_class.new url, url
    ms.master.should_not be(ms.slave)
  end

  it "should accept transaction" do
    subject.transaction do
      subject.hset 'hash', 'a', 1
      subject.hset 'hash', 'b', 2
    end
    subject.hgetall('hash').should == { 'a' => '1', 'b' => '2' }
  end

  it "should prevent transaction nesting" do
    subject.transaction do
      subject.hset 'hash', 'a', 1
      subject.hset 'hash', 'b', 2
      subject.transaction do
        subject.hset 'hash', 'c', 3
        subject.transaction do
          subject.hset 'hash', 'd', 4
        end
      end
    end
    subject.hgetall('hash').should == { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' }
  end


  it 'should have master methods' do
    described_class::MASTER_METHODS.size.should == 63
  end

  it 'should have slave methods' do
    described_class::SLAVE_METHODS.size.should == 68
  end

  it 'should have no clashes between methods' do
    (described_class::MASTER_METHODS & described_class::SLAVE_METHODS).should == []
  end

  it 'should provide a complete set of methods' do
    irrelevant = [:client, :without_reconnect, :id, :inspect, :method_missing]
    (Redis.public_instance_methods(false) - described_class::MASTER_METHODS - described_class::SLAVE_METHODS).should =~ irrelevant
  end

  (described_class::MASTER_METHODS + described_class::SLAVE_METHODS).each do |method|
    let :redis_methods do
      Redis.instance_methods.map(&:to_sym)
    end

    it "should delegate '#{method}' to client" do
      subject.master.should respond_to(method)
      redis_methods.should include(method.to_sym)
    end
  end

  it "should delegate correctly" do
    subject.multi do
      subject.hset "field", "a", "1"
      subject.hset "field", "b", "2"
    end
    subject.hgetall("field").should == { "a" => "1", "b" => "2" }
  end

  describe "sharding" do
    let(:master) { mock("MASTER") }
    let(:slave)  { mock("SLAVE") }
    subject      { described_class.new master, slave }

    it 'should delegate reads to slaves' do
      slave.should_receive(:get).with('field')
      subject.get 'field'

      slave.should_receive(:hmget).with('field', 'a', 'b', 'c')
      subject.hmget 'field', 'a', 'b', 'c'
    end

    it 'should delegate writes to master' do
      master.should_receive(:set).with('field', 'value')
      subject.set 'field', 'value'

      master.should_receive(:hmset).with('field', 'k1', 'a', 'k2', 'b')
      subject.hmset 'field', 'k1', 'a', 'k2', 'b'
    end

    it 'should allow block operations to a single connection' do
      master.should_receive(:set).with('field', 'value')
      master.should_receive(:get).with('field')

      subject.on(:master) do
        subject.set 'field', 'value'
        subject.get 'field'
      end

      slave.should_receive(:get).with('field')
      subject.get 'field'
    end

  end

end
