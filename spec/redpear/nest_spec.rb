require 'spec_helper'

describe Redpear::Nest do

  subject do
    described_class.new "random", connection
  end

  it { should be_a(::String) }
  it { should respond_to(:get) }
  it { should respond_to(:set) }
  it { should respond_to(:hgetall) }
  it { should respond_to(:mapped_hmset) }

  it "should create sub nests" do
    subject["sub"].should be_a(described_class)
    subject["sub"].should == "random:sub"
    subject["sub", "subsub"].should == "random:sub:subsub"
  end

  it "should use master for everything, unless slave specified" do
    subject.master.should == connection
    subject.slave.should == connection
  end
  
  describe "sharding" do
    let(:master) { mock("MASTER") }
    let(:slave)  { mock("SLAVE") }    
    subject      { described_class.new "random", master, slave }
    
    it 'should delegate reads to slaves' do
      slave.should_receive(:get).with('random')
      subject.get

      slave.should_receive(:hmget).with('random', 'a', 'b', 'c')
      subject.hmget 'a', 'b', 'c'
    end

    it 'should delegate writes to master' do
      master.should_receive(:set).with('random', 'value')
      subject.set 'value'

      master.should_receive(:hmset).with('random', 'k1', 'a', 'k2', 'b')
      subject.hmset 'k1', 'a', 'k2', 'b'
    end

    it 'should allow block operations to a single connection' do
      master.should_receive(:set).with('random', 'value')
      master.should_receive(:get).with('random')

      subject.with(:master) do
        subject.set 'value'
        subject.get
      end
      
      slave.should_receive(:get).with('random')
      subject.get
    end
    
  end

end