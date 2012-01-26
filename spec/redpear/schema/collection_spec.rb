require 'spec_helper'

describe Redpear::Schema::Collection do

  it { should be_a(Array) }

  let :column do
    subject.store Redpear::Schema::Column, Post, :title
  end
  alias_method :store_column, :column

  it 'should have a lookup' do
    store_column
    subject.lookup.should == { "title" => column }
    subject.lookup.to_a.flatten.map(&:class).should == [String, Redpear::Schema::Column]
  end

  it 'should store columns' do
    lambda { store_column }.should change { subject.size }.by(1)
    subject.first.should be_instance_of(Redpear::Schema::Column)
  end

  it 'should have names' do
    store_column
    subject.first.should be_instance_of(Redpear::Schema::Column)
    subject.names.first.should be_instance_of(String)
  end

  it 'should return indicies only' do
    subject.store Redpear::Schema::Column, Post, :title
    subject.store Redpear::Schema::Index, Post, :user_id
    subject.store Redpear::Schema::Score, Post, :rank

    subject.indicies.should be_instance_of(Array)
    subject.indicies.should have(2).items
    subject.indicies.map(&:name).should =~ ['user_id', 'rank']
  end

  it 'should allow Hash-style access' do
    store_column
    subject[:title].should be_instance_of(Redpear::Schema::Column)
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

end