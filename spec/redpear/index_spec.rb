require 'spec_helper'

describe Redpear::Index do

  subject do
    described_class.new Comment, :post_id
  end

  it { should be_a(Redpear::Column) }
  it { should be_index }

  it 'should have a namespace' do
    subject.namespace.should == "comments:post_id"
  end

  it 'should build nests by values' do
    subject.nest(nil).should be_nil
    subject.nest("").should be_nil
    subject.nest(123).should == "comments:post_id:123"
  end

end