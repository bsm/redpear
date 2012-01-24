require 'spec_helper'

describe Redpear::Store::Base do

  subject do
    described_class.new "bkey", connection
  end

  it 'should have a key' do
    subject.key.should == "bkey"
    subject.to_s.should == "bkey"
  end

  it 'should have a connection' do
    subject.conn.should be(connection)
  end

end
