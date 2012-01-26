require 'spec_helper'

describe Redpear::Schema do

  subject do
    klass = Class.new(Hash)
    klass.send :include, described_class
    klass
  end

  let :instance do
    subject.new
  end

  it 'should maintain a column registry' do
    subject.columns.should be_a(described_class::Collection)
  end

  it 'should define/store columns' do
    lambda {
      subject.column "name"
    }.should change { subject.columns.dup }.from([]).to(["name"])
    subject.columns.first.should be_instance_of(Redpear::Schema::Column)
  end

  it 'should define/store indicies' do
    lambda {
      subject.index "name"
    }.should change { subject.columns.dup }.from([]).to(["name"])
    subject.columns.first.should be_instance_of(Redpear::Schema::Index)
  end

  it 'should define/store scores' do
    lambda {
      subject.score "name"
    }.should change { subject.columns.dup }.from([]).to(["name"])
    subject.columns.first.should be_instance_of(Redpear::Schema::Score)
  end

  it 'should create attribute accessor methods' do
    subject.column "some_col"
    subject.instance_methods.should include(:some_col)
    subject.instance_methods.should include(:some_col=)
    instance.some_col = 'ABC'
    instance.some_col.should == 'ABC'
  end

end