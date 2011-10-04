require 'spec_helper'

describe Redpear::Schema::Collection do

  it { should be_a(Array) }

  it 'should have a lookup' do
    col = subject.column Post, :title
    subject.lookup.should == { "title" => col }
    subject.lookup.to_a.flatten.map(&:class).should == [String, Redpear::Column]
  end

  it 'should store columns' do
    lambda { subject.column Post, :title }.should change { subject.size }.by(1)
    subject.first.should be_instance_of(Redpear::Column)
  end

  it 'should store indices' do
    lambda { subject.index Post, :foreign_id }.should change { subject.size }.by(1)
    subject.first.should be_instance_of(Redpear::Index)
  end

  it 'should have names' do
    subject.column Post, :title
    subject.first.should be_instance_of(Redpear::Column)
    subject.names.first.should be_instance_of(String)
  end

  it 'should allow Hash-style access' do
    subject.column Post, :title
    subject[:title].should be_instance_of(Redpear::Column)
  end

  it 'should convert column names' do
    lambda {
      subject.column Post, :title
    }.should change { subject.dup }.from([]).to(["title"])
  end

  it 'should scope indices' do
    subject.indices.should == []
    subject.column Post, :title
    subject.index  Post, :foreign_id
    subject.should == ['title', 'foreign_id']
    subject.indices.should == ['foreign_id']
  end

end