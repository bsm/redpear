require 'spec_helper'

describe Redpear::Schema::Collection do

  it { is_expected.to be_a(Array) }

  let :column do
    subject.store Redpear::Schema::Column, Post, :title
  end
  alias_method :store_column, :column

  it 'should have a lookup' do
    store_column
    expect(subject.lookup).to eq({ "title" => column })
    expect(subject.lookup.to_a.flatten.map(&:class)).to eq([String, Redpear::Schema::Column])
  end

  it 'should store columns' do
    expect { store_column }.to change { subject.size }.by(1)
    expect(subject.first).to be_instance_of(Redpear::Schema::Column)
  end

  it 'should have names' do
    store_column
    expect(subject.first).to be_instance_of(Redpear::Schema::Column)
    expect(subject.names.first).to be_instance_of(String)
  end

  it 'should return indicies only' do
    subject.store Redpear::Schema::Column, Post, :title
    subject.store Redpear::Schema::Index, Post, :user_id
    subject.store Redpear::Schema::Score, Post, :rank

    expect(subject.indicies).to be_instance_of(Array)
    expect(subject.indicies.size).to eq(2)
    expect(subject.indicies.map(&:name)).to match_array(['user_id', 'rank'])
  end

  it 'should allow Hash-style access' do
    store_column
    expect(subject[:title]).to be_instance_of(Redpear::Schema::Column)
  end

  it 'should indicate if a column is included' do
    store_column
    expect(subject.include?(:title)).to be(true)
    expect(subject.include?('title')).to be(true)
    expect(subject.include?('other')).to be(false)
  end

  it 'should convert column names' do
    expect { store_column }.to change { subject.dup }.from([]).to(["title"])
  end

end