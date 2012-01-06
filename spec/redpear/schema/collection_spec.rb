require 'spec_helper'

describe Redpear::Schema::Collection do

  it { should be_a(Array) }

  let :column do
    subject.store Redpear::Column, Post, :title
  end
  alias_method :store_column, :column

  it 'should have a lookup' do
    store_column
    subject.lookup.should == { "title" => column }
    subject.lookup.to_a.flatten.map(&:class).should == [String, Redpear::Column]
  end

  it 'should store columns' do
    lambda { store_column }.should change { subject.size }.by(1)
    subject.first.should be_instance_of(Redpear::Column)
  end

  it 'should store indices' do
    lambda { subject.store Redpear::Index, Post, :foreign_id }.should change { subject.size }.by(1)
    subject.first.should be_instance_of(Redpear::Index)
  end

  it 'should have names' do
    store_column
    subject.first.should be_instance_of(Redpear::Column)
    subject.names.first.should be_instance_of(String)
  end

  it 'should allow Hash-style access' do
    store_column
    subject[:title].should be_instance_of(Redpear::Column)
  end

  it 'should indicate if a column is included' do
    store_column
    subject.include?(:title).should be(true)
    subject.include?('title').should be(true)
    subject.include?('other').should be(false)
  end

  it 'should convert column names' do
    lambda { store_column }.should change { subject.dup }.from([]).to(["title"])
  end

  it 'should scope indices' do
    subject.indices.should == []
    store_column
    subject.store Redpear::Index,  Post, :foreign_id
    subject.should == ['title', 'foreign_id']
    subject.indices.should == ['foreign_id']
  end

end