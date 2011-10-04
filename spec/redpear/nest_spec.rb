require 'spec_helper'

describe Redpear::Nest do

  subject do
    described_class.new "random", connection
  end

  it  { should be_a(::Nest) }

  it "should readl/write hashes" do
    subject.mapped_hmset :a => 1, :b => 'x'
    subject.mapped_hmget('a').should == { 'a' => '1' }
  end

  it "should read full hashes" do
    subject.mapped_hmset :a => 1, :b => 'x'
    subject.mapped_hmget_all.should == { 'a' => '1', 'b' => 'x' }
  end

end