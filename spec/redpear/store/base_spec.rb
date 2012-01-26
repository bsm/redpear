require 'spec_helper'

describe Redpear::Store::Base do

  subject do
    described_class.new "bkey", connection
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

end
