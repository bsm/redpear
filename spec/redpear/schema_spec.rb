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
    expect(subject.columns).to be_a(described_class::Collection)
  end

  it 'should define/store columns' do
    expect {
      subject.column "name"
    }.to change { subject.columns.dup }.from([]).to(["name"])
    expect(subject.columns.first).to be_instance_of(Redpear::Schema::Column)
  end

  it 'should define/store indicies' do
    expect {
      subject.index "name"
    }.to change { subject.columns.dup }.from([]).to(["name"])
    expect(subject.columns.first).to be_instance_of(Redpear::Schema::Index)
  end

  it 'should define/store scores' do
    expect {
      subject.score "name"
    }.to change { subject.columns.dup }.from([]).to(["name"])
    expect(subject.columns.first).to be_instance_of(Redpear::Schema::Score)
  end

  it 'should create attribute accessor methods' do
    subject.column "some_col"
    expect(subject.instance_methods).to include(:some_col)
    expect(subject.instance_methods).to include(:some_col=)
    instance.some_col = 'ABC'
    expect(instance.some_col).to eq('ABC')
  end

end